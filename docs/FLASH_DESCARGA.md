# Clarão de descarga — correção 0.14.6

O clarão anterior era desenhado no pai da cena, atrás da matriz e dos personagens. As placas opacas cobriam o efeito em grande parte da tela. Além disso, o SM-G781B conectado nesta verificação ainda tinha a 0.14.3 com flashes suaves salvos; a instalação anterior da 0.14.5 havia sido feita no SM-A520F.

## Implementação

`main.gd` agora cria um `ColorRect` chamado `ShockFlash` depois da matriz e dos atores. A camada cobre a área da partida (720×1252, a partir de y=122), preservando cabeçalho e rodapé, e fica antes do resultado. Não intercepta toques. A visibilidade e o alfa vêm de `shock_flash_alpha()`, sincronizados pelos mesmos estados usados pelos personagens.

Mantidos três pulsos no modo normal, com alfa máximo de 0,18, e um brilho gradual de até 0,07 no modo suave. O esqueleto continua visível durante todo o choque; não há quadro branco opaco sobre a animação. A vibração física continua com 800 ms no início da descarga, após os 0,40 s da chave. Fases, dicas, tempo e dados do jogador não mudam.

## Verificação

- Suíte completa: 35.493 verificações da engine, 15 testes Python e 730 estados de dicas aprovados.
- Testes de execução conferem a ordem da camada, passagem dos toques, alfa/visibilidade em todos os frames, preservação do esqueleto e coincidência do clarão com a janela da vibração.
- QA com OpenGL real compara o mesmo pixel de uma placa vazia com a camada ligada e desligada. Luminância observada: 0,3364 com clarão e 0,2358 sem; a diferença supera o limite de regressão de 0,04. O desenho antigo atrás da placa não passaria nesse teste.
- Evidências: `builds/flash-render-check.json`, `builds/visual-qa.log` e `builds/previews/57-background-flash-first.png`. Apesar do nome histórico do PNG, o clarão agora está sobre a cena.

O teste de pixel converte coordenadas pelo canvas e pelo viewport antes da amostragem. Referências oficiais: [ordem e transformações de CanvasItem](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html), [transformações do Viewport](https://docs.godotengine.org/en/stable/classes/class_viewport.html).

## Instalação

APK 0.14.6/código 24 instalado e conferido no SM-G781B. Ativados flashes normais no perfil do jogo, com ajuste exclusivo de `reduced_flashes` para false, preservando todos os demais bytes. Prova em `builds/android/flash-setting-v0146-g781b.json`. O processo foi iniciado sem erros de inicialização; o efeito foi validado com o renderer real no computador, sem automatizar jogadas no aparelho.
