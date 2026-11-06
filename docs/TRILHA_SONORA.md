# Fortress After Hours — trilha original

Revisão 0.14.3: tema de mansão assombrada mais sóbrio e rápido, **120 BPM, 32 compassos e 64 segundos em loop**. Órgão de notas curtas, baixo pulsante, cordas dedilhadas sintetizadas e pequenos toques de celesta, com pausas e ecos discretos. Progressão C#m → Am → F#dim7 → G#7, melodia própria e uma seção central em registro mais grave. Referência de atmosfera: fases de fantasmas de jogos de plataforma; melodia, arranjo e gravação originais. A bateria hip-hop, o swing e o ruído de fita da versão anterior foram retirados.

Composição e síntese próprias, sem samples ou gravações de terceiros. Fonte reproduzível em `tools/create_music.py`, usando Python padrão e ffmpeg instalado no PATH. Executar `python tools/create_music.py`. Síntese determinística; as caudas dos ecos são circulares para atravessar o início do loop. A versão lo-fi anterior foi preservada em `builds/audio/v0142/` para comparação e retorno.

- Jogo: `assets/audio/fortress-after-hours.ogg`, Vorbis estéreo a 22050 Hz.
- Mestre de autoria: `builds/audio/fortress-after-hours.wav`, PCM estéreo de 16 bits; não é incluído no aplicativo.
- Medições: `builds/audio/music-metrics.json`.

O canal de música pertence ao `GameAudio`, separado do zumbido e dos efeitos. Toca no menu, seletor, partida e resultado; não reinicia a cada atualização da interface. Na revisão **0.21.4**, o volume da trilha aumentou **6 dB**, de −14 para **−8 dB**. Durante a descarga baixa para **−16 dB** (redução de 8 dB), destacando o zap. Os efeitos mantêm seu volume. O botão SOM interrompe todos os canais. Pausa e segundo plano suspendem a música; continuar retoma a posição. Uma nova partida não troca o stream nem reinicia o loop.

Verificações de integração em `tests/polish_tests.gd`: recurso em loop, canal independente, contexto sem substituição do stream, pausa/retomada, redução durante a descarga, segundo plano inclusive no menu e silêncio quando SOM está desligado. A preferência de som existente continua valendo; não foi acrescentada outra opção.

Validação de loop: `./tools/dev.ps1 audio-test` executa as verificações existentes e atravessa três ciclos de 64 s com o decoder nativo. O teste usa 8× e um perfil isolado, sem alterar a velocidade no jogo. Resultado: 39 verificações aprovadas; pausa conserva a posição e SOM encerra o stream. Logs e dados em `builds/audio-tests.log` e `builds/audio-loop-results.json`. A escuta da nova mixagem no celular ainda precisa de avaliação humana.


## Controles de volume — 0.15.0

A tela Ajustes oferece ganhos independentes de música e efeitos entre 0 e 100%. Na versão 0.21.4, o nível 100% corresponde a −8 dB normalmente e −16 dB durante a descarga. O ganho escolhido é somado a esses níveis em decibéis pela conversão nativa de amplitude; em zero, a música fica pausada e os efeitos/zumbido param. Som geral desliga tudo sem apagar os níveis escolhidos. Abrir Ajustes pela pausa mantém a música pausada. Preferências e migração: `AJUSTES.md`. Teste dedicado: controle proporcional de volume, independência dos efeitos, pausa, silêncio e três ciclos do OGG decodificados. A atualização não altera a porcentagem de volume salva pelo jogador.

## Validação da 0.21.4 — 6 de novembro de 2026

Fluxo obrigatório aprovado: 49 testes Python, 41.065 verificações da engine, 761 estados de dicas, 3.604 verificações visuais/temporais e 48 de áudio, incluindo três ciclos completos do OGG. APK/código 38 exportado e auditado, com fases idênticas às fontes e 83 texturas. Log: `builds/deploy-v0214-install.log`.

A instalação não foi realizada: o S20 FE não estava disponível no ADB. O fluxo parou na seleção do aparelho, antes de alterar sua instalação ou perfil. A escuta do novo volume no celular permanece pendente.
