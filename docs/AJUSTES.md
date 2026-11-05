# Ajustes de áudio e resposta — 0.15.0

O botão **Ajustes** no menu principal reúne música, efeitos, som geral, vibração e flashes. Na partida, acessar **Pausa → Ajustes**. Voltar retorna à pausa; Continuar retoma a tentativa, sem alterar tempo, giros ou tabuleiro.

| Controle | Comportamento |
| --- | --- |
| Música | Volume de 0–100%; zero pausa a trilha, mantendo os efeitos. |
| Efeitos | Volume de 0–100%; inclui cliques, alertas, descarga e zumbido. Zero mantém a música. |
| Som geral | Silencia tudo, preservando os dois volumes para quando for religado. |
| Vibração | Habilita ou desabilita o pulso nativo de 800 ms no início do choque. Independente do áudio e dos flashes. |
| Flashes | Normais ou suaves. Preserva a opção existente; novos perfis usam normais. |

A tela usa o cenário industrial e os botões do jogo. Controles nativos `HSlider` aceitam arrasto, clique e teclado; o Android usa a emulação nativa de mouse a partir do toque. Os controles subjacentes ficam ocultos enquanto os ajustes estão abertos.

## Persistência e implementação

- `scripts/player_profile.gd`: perfil v4, com `music_volume`, `effects_volume` e `vibration` na seção de preferências. Valores inválidos são tratados e volumes limitados a 0–1. Saves anteriores usam ganhos 1/1 e vibração ligada, preservando som geral, flashes e progresso.
- `scripts/main.gd`: acesso pelo menu/pausa, navegação de retorno e aplicação dos ganhos. Arrastar atualiza o áudio imediatamente; terminar o arrasto, mudar o foco, fechar ajustes ou enviar o aplicativo ao segundo plano grava as preferências usando o mecanismo atômico existente com backup.
- `scripts/game_audio.gd`: ganho independente nos players existentes. Em 100%, mantém a mixagem anterior; a redução da música durante a descarga continua ativa. Música em zero conserva o mesmo stream para retomar. A pausa e o segundo plano continuam suspendendo a reprodução.
- O pulso continua sendo disparado uma única vez no início do choque, condicionado à preferência de vibração. O botão não altera configurações globais do Android.

## Validação em 5 de novembro de 2026

- `./tools/dev.ps1 test`: 35.530 verificações da engine, 15 testes Python e 730 estados de dicas, todos aprovados. Inclui controles de volume, mixagem independente, navegação de retorno à pausa, persistência, recuperação e migração sem perder conquistas.
- `./tools/dev.ps1 audio-test`: 48 verificações aprovadas, incluindo três ciclos reais de 64 s do OGG decodificados a 8× apenas no teste.
- `./tools/dev.ps1 capture`: capturas da engine em `builds/previews/63-settings-menu.png` e `64-settings-paused.png`.
- Android 0.15.0/código 25 instalado no S20 FE SM-G781B. SHA-256 do APK conferido; perfil idêntico antes/depois da instalação. Registro em `builds/android/install-v0150-g781b-status.json`.
- A tela do celular estava bloqueada. A inspeção visual usa o renderer real no computador; percepção auditiva e interação com os sliders no aparelho ainda dependem de uso humano.

![Ajustes](../builds/previews/63-settings-menu.png)
