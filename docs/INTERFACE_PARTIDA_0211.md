# Interface da partida — 0.21.1

Cabeçalho e rodapé passam a usar a mesma textura de sala e o mesmo sombreamento do menu de pausa. As antigas faixas quase pretas foram removidas. O recorte da textura é fixo nessas duas áreas; o tremor continua restrito ao cenário da partida.

O cabeçalho conserva fase, objetivo/painel, tempo, giros e pausa. Tempo e giros ganharam legendas maiores, e os textos receberam contorno escuro para manter a leitura junto das luminárias. O feedback inferior passou de 26 para 28, com contorno e espaço para duas linhas. Reiniciar e Dica agora têm larguras iguais, margens simétricas e fonte 28, mantendo a altura de toque.

As regras, dicas, progresso e sequência da descarga permanecem iguais. Não foram introduzidos fios direcionais nesta entrega.

## Verificação

A comparação de pixels confirma que as áreas livres de controles no cabeçalho e rodapé usam o mesmo fundo da pausa, nas proporções 360×800, 720×1280 e 720×1600. A suíte também confere alvos de toque, leitura em duas linhas, posição dos controles, ausência de deslocamento do cabeçalho durante o tremor e preservação do flash/esqueleto.

Capturas em `builds/game-chrome/`, com pares `game` e `pause` para cada dimensão. Fluxo completo aprovado: 49 testes Python, 41.059 verificações da engine, 761 estados de dicas, 3.601 verificações visuais/temporais e 48 de áudio, sem falhas.

Versão 0.21.1/código 35 instalada no S20 FE em 6 de novembro de 2026, com perfil idêntico antes/depois e inicialização sem erros. APK conferido com fases idênticas às fontes e 83 texturas. Registro: `builds/android/install-20261106T144921398356Z/status.json`; log: `builds/deploy-v0211-install.log`. Nenhuma partida foi automatizada no aparelho.
