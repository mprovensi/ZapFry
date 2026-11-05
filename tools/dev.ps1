param(
    [ValidateSet('play', 'test', 'audio-test', 'effects-test', 'verify', 'android', 'windows', 'install', 'capture')]
    [string]$Action = 'play',
    [string]$GodotPath = $env:GODOT_BIN,
    [string]$DeviceSerial
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
if (-not $GodotPath) {
    foreach ($candidate in @('godot', 'godot4')) {
        $engineCommand = Get-Command $candidate -ErrorAction SilentlyContinue
        if ($engineCommand) {
            $GodotPath = $engineCommand.Source
            break
        }
    }
}
if (-not $GodotPath) {
    $userDirectory = [Environment]::GetFolderPath('UserProfile')
    $GodotPath = Join-Path $userDirectory 'Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
}
if (-not (Test-Path -LiteralPath $GodotPath -PathType Leaf)) {
    throw 'Godot não encontrado. Informe -GodotPath ou configure GODOT_BIN com o executável do Godot 4.7.2.'
}

New-Item -ItemType Directory -Force -Path (Join-Path $projectRoot 'builds') | Out-Null

function Get-SourceFingerprint {
    $files = @()
    foreach ($folder in @('assets', 'levels', 'scenes', 'scripts', 'tests', 'tools')) {
        $directory = Join-Path $projectRoot $folder
        if (Test-Path -LiteralPath $directory) {
            $files += Get-ChildItem -LiteralPath $directory -Recurse -File | Where-Object {
                $_.Extension -notin @('.uid', '.pyc') -and $_.FullName -notmatch '[\\/]__pycache__[\\/]'
            }
        }
    }
    foreach ($name in @('project.godot', 'export_presets.cfg')) {
        $path = Join-Path $projectRoot $name
        if (Test-Path -LiteralPath $path) { $files += Get-Item -LiteralPath $path }
    }
    $entries = foreach ($file in ($files | Sort-Object FullName)) {
        $relative = $file.FullName.Substring($projectRoot.Length).Replace('\', '/')
        $digest = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
        "$relative $digest"
    }
    $algorithm = [Security.Cryptography.SHA256]::Create()
    try {
        return [BitConverter]::ToString($algorithm.ComputeHash([Text.Encoding]::UTF8.GetBytes(($entries -join "`n")))).Replace('-', '').ToLowerInvariant()
    } finally { $algorithm.Dispose() }
}

function Invoke-Verification {
    $report = [ordered]@{ status = 'running'; startedUtc = [DateTime]::UtcNow.ToString('o'); suites = @(); sourceFingerprint = (Get-SourceFingerprint) }
    $reportPath = Join-Path $projectRoot 'builds\verification.json'
    $report | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $reportPath -Encoding utf8
    try {
        foreach ($suite in @('test', 'effects-test', 'audio-test')) {
            Write-Host "Verificação obrigatória: $suite"
            & $PSCommandPath -Action $suite -GodotPath $GodotPath
            if ($LASTEXITCODE -ne 0) { throw "A suíte $suite falhou (código $LASTEXITCODE). Entrega bloqueada." }
            $report.suites += $suite
        }
        if ((Get-SourceFingerprint) -ne $report.sourceFingerprint) {
            throw 'Os arquivos do projeto mudaram durante os testes. Entrega bloqueada; execute novamente.'
        }
        $report.status = 'passed'
    } catch {
        $report.status = 'failed'
        $report['error'] = $_.Exception.Message
        throw
    } finally {
        $report['finishedUtc'] = [DateTime]::UtcNow.ToString('o')
        $report | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $reportPath -Encoding utf8
    }
}

$engineArgs = @('--path', $projectRoot)
$exportAction = if ($Action -eq 'install') { 'android' } else { $Action }
switch ($exportAction) {
    'play' { }
    'test' {
        $engineArgs += @('--headless', '--log-file', (Join-Path $projectRoot 'builds\tests.log'),
            '--script', 'res://tests/run_tests.gd', '--', '--test')
    }
    'audio-test' {
        $engineArgs += @('--headless', '--log-file', (Join-Path $projectRoot 'builds\audio-tests.log'),
            '--script', 'res://tests/run_audio_tests.gd', '--', '--test')
    }
    'capture' {
        $engineArgs += @('--audio-driver', 'Dummy', '--log-file', (Join-Path $projectRoot 'builds\visual-qa.log'),
            '--script', 'res://tests/capture_previews.gd', '--', '--test')
    }
    'effects-test' {
        $engineArgs += @('--audio-driver', 'Dummy', '--log-file', (Join-Path $projectRoot 'builds\effects-tests.log'),
            '--script', 'res://tests/run_effect_tests.gd', '--', '--test')
    }
    'android' {
        $engineArgs += @('--headless', '--log-file', (Join-Path $projectRoot 'builds\export-android.log'),
            '--export-debug', 'Android', (Join-Path $projectRoot 'builds\zap-fry-prototype.apk'))
    }
    'windows' {
        New-Item -ItemType Directory -Force -Path (Join-Path $projectRoot 'builds\windows') | Out-Null
        $engineArgs += @('--headless', '--log-file', (Join-Path $projectRoot 'builds\export-windows.log'),
            '--export-debug', 'Windows', (Join-Path $projectRoot 'builds\windows\ZapFry.exe'))
    }
}
Push-Location $projectRoot
$deploymentLock = $null
try {
    if ($Action -in @('verify', 'android', 'windows', 'install')) {
        try {
            $deploymentLock = [IO.File]::Open((Join-Path $projectRoot 'builds\deploy.lock'), 'OpenOrCreate', 'ReadWrite', 'None')
        } catch { throw 'Outra verificação ou entrega está em execução. Aguarde sua conclusão.' }
        Invoke-Verification
        if ($Action -eq 'verify') { exit 0 }
    }
    if ($Action -eq 'test') {
        & python -m unittest discover -s tests -p 'test_*.py'
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
        & python tools/validate_levels.py
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
        & python tools/validate_hint_states.py prepare
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
    & $GodotPath @engineArgs
    $engineExitCode = $LASTEXITCODE
    if ($Action -in @('android', 'windows', 'install') -and $engineExitCode -eq 0) {
        $verified = Get-Content -LiteralPath (Join-Path $projectRoot 'builds\verification.json') -Raw | ConvertFrom-Json
        if ((Get-SourceFingerprint) -ne $verified.sourceFingerprint) {
            throw 'Os arquivos do projeto mudaram durante a exportação. Pacote não pode ser entregue.'
        }
        if ($exportAction -eq 'android') {
            & python tools/check_android_package.py builds/zap-fry-prototype.apk
            if ($LASTEXITCODE -ne 0) { throw 'Recursos do APK inválidos. Entrega bloqueada.' }
        } else {
            $smokeLog = Join-Path $projectRoot 'builds\windows-smoke.log'
            if (Test-Path -LiteralPath $smokeLog) { Remove-Item -LiteralPath $smokeLog }
            $smokeArgs = @('--headless', '--audio-driver', 'Dummy', '--quit-after', '10', '--log-file', ('"{0}"' -f $smokeLog), '--', '--test')
            $smoke = Start-Process -FilePath (Join-Path $projectRoot 'builds\windows\ZapFry.exe') -ArgumentList $smokeArgs -WorkingDirectory (Join-Path $projectRoot 'builds\windows') -WindowStyle Hidden -PassThru
            try {
                if (-not $smoke.WaitForExit(30000)) { $smoke.Kill(); throw 'Executável Windows não encerrou o teste de inicialização.' }
                if ($smoke.ExitCode -ne 0 -or -not (Test-Path -LiteralPath $smokeLog) -or (Select-String -LiteralPath $smokeLog -Pattern 'ERROR:|SCRIPT ERROR:')) {
                    throw 'Teste de inicialização Windows falhou. Entrega bloqueada.'
                }
            } finally { $smoke.Dispose() }
        }
    }
    if ($Action -eq 'test' -and $engineExitCode -eq 0) {
        & python tools/validate_hint_states.py verify
        $engineExitCode = $LASTEXITCODE
    }
    if ($Action -eq 'install' -and $engineExitCode -eq 0) {
        $installArgs = @('tools/install_android.py', '--apk', 'builds/zap-fry-prototype.apk')
        if ($DeviceSerial) { $installArgs += @('--serial', $DeviceSerial) }
        & python @installArgs
        $engineExitCode = $LASTEXITCODE
    }
} finally {
    if ($null -ne $deploymentLock) { $deploymentLock.Dispose() }
    Pop-Location
}
exit $engineExitCode
