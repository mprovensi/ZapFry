param(
    [ValidateSet('play', 'test', 'audio-test', 'effects-test', 'verify', 'android', 'windows', 'install', 'capture')]
    [string]$Action = 'play',
    [string]$GodotPath = $env:GODOT_BIN,
    [string]$DeviceSerial,
    [switch]$Release
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
if ($Release -and $Action -ne 'android') { throw '-Release é permitido somente com android.' }
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
$androidOutput = Join-Path $projectRoot 'builds\zap-fry-prototype.apk'
if ($Release) {
    New-Item -ItemType Directory -Force -Path (Join-Path $projectRoot 'builds\release') | Out-Null
    $androidOutput = Join-Path $projectRoot 'builds\release\ZapFry-release.apk'
}
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
        $exportMode = if ($Release) { '--export-release' } else { '--export-debug' }
        $engineArgs += @('--headless', '--log-file', (Join-Path $projectRoot 'builds\export-android.log'),
            $exportMode, 'Android', $androidOutput)
    }
    'windows' {
        New-Item -ItemType Directory -Force -Path (Join-Path $projectRoot 'builds\windows') | Out-Null
        $engineArgs += @('--headless', '--log-file', (Join-Path $projectRoot 'builds\export-windows.log'),
            '--export-debug', 'Windows', (Join-Path $projectRoot 'builds\windows\ZapFry.exe'))
    }
}
Push-Location $projectRoot
$deploymentLock = $null
$signingEnvironment = @{}
try {
    if ($Action -in @('verify', 'android', 'windows', 'install')) {
        try {
            $deploymentLock = [IO.File]::Open((Join-Path $projectRoot 'builds\deploy.lock'), 'OpenOrCreate', 'ReadWrite', 'None')
        } catch { throw 'Outra verificação ou entrega está em execução. Aguarde sua conclusão.' }
        if ($Release) {
            $signing = Get-Content -LiteralPath (Join-Path $projectRoot '.tools\signing\upload.json') -Raw | ConvertFrom-Json
            $values = @{
                GODOT_ANDROID_KEYSTORE_RELEASE_PATH = $signing.keystore
                GODOT_ANDROID_KEYSTORE_RELEASE_USER = $signing.alias
                GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD = $signing.password
                GRADLE_OPTS = "$env:GRADLE_OPTS -Dorg.gradle.daemon=false"
            }
            if (-not (Test-Path -LiteralPath $signing.keystore -PathType Leaf) -or -not $signing.alias -or -not $signing.password) {
                throw 'Chave de upload incompleta. Prepare .tools/signing antes da exportação.'
            }
            foreach ($name in $values.Keys) {
                $signingEnvironment[$name] = [Environment]::GetEnvironmentVariable($name, 'Process')
                [Environment]::SetEnvironmentVariable($name, $values[$name], 'Process')
            }
        }
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
    $suiteLogs = @{ 'test' = 'tests.log'; 'effects-test' = 'effects-tests.log'; 'audio-test' = 'audio-tests.log' }
    $engineLog = $null
    if ($suiteLogs.ContainsKey($Action)) {
        $engineLog = Join-Path $projectRoot ('builds\' + $suiteLogs[$Action])
        if (Test-Path -LiteralPath $engineLog) { Remove-Item -LiteralPath $engineLog }
    }
    & $GodotPath @engineArgs
    $engineExitCode = $LASTEXITCODE
    if ($engineLog -and $engineExitCode -eq 0) {
        if (-not (Test-Path -LiteralPath $engineLog) -or (Select-String -LiteralPath $engineLog -Pattern '^(ERROR:|SCRIPT ERROR:|SHADER ERROR:)')) {
            throw "A suíte $Action não gerou log válido ou registrou erros da engine. Entrega bloqueada: $engineLog"
        }
    }
    if ($Action -in @('android', 'windows', 'install') -and $engineExitCode -eq 0) {
        $verified = Get-Content -LiteralPath (Join-Path $projectRoot 'builds\verification.json') -Raw | ConvertFrom-Json
        if ((Get-SourceFingerprint) -ne $verified.sourceFingerprint) {
            throw 'Os arquivos do projeto mudaram durante a exportação. Pacote não pode ser entregue.'
        }
        if ($exportAction -eq 'android') {
            & python tools/check_android_package.py $androidOutput
            if ($LASTEXITCODE -ne 0) { throw 'Recursos do APK inválidos. Entrega bloqueada.' }
            if ($Release) {
                $bundleOutput = Join-Path $projectRoot 'builds\release\ZapFry.aab'
                $bundleArgs = @('--headless', '--path', $projectRoot, '--log-file', (Join-Path $projectRoot 'builds\export-bundle.log'))
                if (-not (Test-Path -LiteralPath (Join-Path $projectRoot 'android\build\build.gradle'))) {
                    $bundleArgs += '--install-android-build-template'
                }
                $bundleArgs += @('--export-release', 'Google Play', $bundleOutput)
                & $GodotPath @bundleArgs
                if ($LASTEXITCODE -ne 0) { throw 'Exportação do AAB falhou. Entrega bloqueada.' }
                foreach ($artifact in @($androidOutput, $bundleOutput)) {
                    if (-not (Test-Path -LiteralPath $artifact -PathType Leaf) -or
                        (Get-Item -LiteralPath $artifact).LastWriteTimeUtc -lt ([DateTime]$verified.finishedUtc).ToUniversalTime()) {
                        throw 'Pacote de release ausente ou anterior aos testes. Entrega bloqueada.'
                    }
                }
                if ((Get-SourceFingerprint) -ne $verified.sourceFingerprint) { throw 'Fontes mudaram durante a exportação do AAB.' }
                & python tools/check_android_package.py $bundleOutput
                if ($LASTEXITCODE -ne 0) { throw 'Recursos do AAB inválidos. Entrega bloqueada.' }
                & python tools/check_android_release.py $androidOutput $bundleOutput
                if ($LASTEXITCODE -ne 0) { throw 'Assinatura ou metadados de release inválidos. Entrega bloqueada.' }
            }
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
    foreach ($name in $signingEnvironment.Keys) { [Environment]::SetEnvironmentVariable($name, $signingEnvironment[$name], 'Process') }
    if ($null -ne $deploymentLock) { $deploymentLock.Dispose() }
    Pop-Location
}
exit $engineExitCode
