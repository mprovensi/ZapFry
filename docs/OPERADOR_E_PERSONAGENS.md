# Operador e personagens da cadeira — 0.12

A composição segue a referência `test_sprites/Goblin_engineer_operates_electri…_c4bcbdc7_2K.jpg`: goblin e chave geral acima, grade de fios ao centro e personagem na cadeira abaixo. Textos, temporizador e controles continuam nativos e dinâmicos. As regras das fases não mudam.

## Sequência

- Circuito fechado: inicia resolução e bloqueia novas jogadas.
- 0–0,40 s: goblin puxa a chave, com três poses (levantada, intermediária e abaixada). O ocupante se prepara; ainda não há descarga na cadeira.
- 0,40–1,75 s: chave permanece abaixada, o choque aparece e o som de eletricidade toca uma vez.
- 1,75–2,40 s: recuperação cômica.
- Ao completar 2,40 s: resultado e progressão. Esse tempo de animação não consome o cronômetro da tentativa.

Reiniciar levanta a chave. Fim do tempo mantém a chave levantada. Flashes suaves preservam a animação do goblin e, desde a 0.14.5, mostram o mesmo esqueleto do cavaleiro durante o choque; o brilho e o tremor continuam reduzidos. A pose de espera não substitui mais a eletrificação.

## Trocar o personagem em uma atualização

O recurso `assets/characters/knight.tres` é do tipo `ExecutionCharacter`, definido em `scripts/execution_character.gd`. Ele contém nome e `SpriteFrames` do ocupante, sem referência à grade, fases, operador ou save. O campo **Execution Character** da raiz da cena define quem ocupa a cadeira. O pacote `Art Pack` continua controlando os fios, fundos e o goblin.

1. Duplicar `assets/characters/knight.tres`, usando um nome próprio para o novo personagem.
2. Importar seus PNGs transparentes, com a mesma proporção, posição e canvas em todas as poses. O recurso atual usa uma composição de personagem **com cadeira**; futuras composições devem incluir a cadeira ou sua própria base.
3. No novo recurso, trocar `Display Name` e os frames de `Portrait`. Manter os estados `idle`, `worried`, `anticipation`, `zap`, `zap_soft`, `recover`, `win` e `lose`. Estados podem compartilhar imagens.
4. Atribuir o novo recurso ao campo **Execution Character** da raiz de `scenes/main.tscn`, no Inspector, e salvar a cena. Não é necessário mudar os fios nem as fases.
5. Executar `./tools/dev.ps1 test` e `./tools/dev.ps1 capture`. Conferir a grade 6×6, a sequência e o modo suave antes de exportar a atualização.

Estado ausente usa `idle`; `zap_soft` ausente também usa `idle`. Um recurso sem imagem ou sem ocupante atribuído mantém o fallback do pacote visual anterior. O montador `tools/build_concept_pack.gd` cria o cavaleiro somente se o arquivo ainda não existir, preservando ajustes manuais do personagem. A troca também pode ocorrer durante uma partida por código, sem reiniciar a sessão ou modificar tempo, células, movimentos e recordes; esse comportamento tem teste próprio.

Esta entrega prepara a substituição em futuras atualizações. Não acrescenta seleção de personagens, desbloqueios ou sorteio no jogo.

## Layout

O jogo e o menu usam uma área lógica de 720×1600; o seletor mantém 720×1280. A escala preserva proporção e a grade continua com 624×624 unidades lógicas. Foram incluídas verificações de posicionamento dos dois personagens e controles em 720×1280, 360×800 e 720×1600, além dos testes de toque existentes.

## Novas artes e prompts

Modo: edição com a ferramenta nativa `image_gen`, preservando o PNG original do engenheiro e o JPEG de referência. Imagens selecionadas copiadas para o projeto. A animação usa recursos nativos `SpriteFrames` do Godot; os pixels das imagens não foram editados por scripts.

### engineer_middle.png

Arquivo: `assets/art/concept_v3/engineer_middle.png`

Prompt final:

Use case: identity-preserve. Asset type: one transparent square animation pose for the existing Zap & Fry game. Image 1 is the EXACT edit target: green goblin engineer holding the raised power switch, with its silver control box and gold switch housing. Keep this goblin's identity, face, goggles, clothing, grin, feet, body size, and cartoon painted style. Keep EXACTLY the same square canvas, full-body scale and position; keep the control box, feet and gold switch housing fixed in the same pixel positions. Change ONLY the operating arm/hand and the long gold switch lever and brown grip, as the goblin pulls it clockwise DOWN. Maintain physical contact between hand and grip; the lever must pivot from the existing gold housing, without changing its length. No duplicate arm, hand, handle or extra lever. Actual transparent background, no wall, text, lightning, panel border or additional objects. One pose, not a sheet. INTERMEDIATE POSE: lever has rotated halfway down from its raised pose, leaning mostly RIGHT with its grip around 66% canvas width and 36% canvas height. Goblin's operating hand follows this grip at chest/shoulder height, elbow bending naturally. Keep the original gold lever visible at this halfway angle.

### engineer_down.png

Arquivo: `assets/art/concept_v3/engineer_down.png`

Prompt final:

Use case: identity-preserve. Asset type: one transparent square animation pose for the existing Zap & Fry game. Image 1 is the EXACT edit target: green goblin engineer holding the raised power switch, with its silver control box and gold switch housing. Keep this goblin's identity, face, goggles, clothing, grin, feet, body size, and cartoon painted style. Keep EXACTLY the same square canvas, full-body scale and position; keep the control box, feet and gold switch housing fixed in the same pixel positions. Change ONLY the operating arm/hand and the long gold switch lever and brown grip, as the goblin pulls it clockwise DOWN. Maintain physical contact between hand and grip; the lever must pivot from the existing gold housing, without changing its length. No duplicate arm, hand, handle or extra lever. Actual transparent background, no wall, text, lightning, panel border or additional objects. One pose, not a sheet. CLOSED/DOWN POSE: the goblin has pulled the lever fully DOWN and toward the RIGHT, with grip around 65% canvas width and 63% canvas height, at the goblin's waist. The long lever now points diagonally DOWN-RIGHT from its fixed pivot, clearly below its initial raised position. Operating arm is lowered and bent, hand gripping at waist. The switch is visibly fully lowered; do NOT retain the upright gold lever or its original upper grip.

## Atualização de composição 0.12.1

Na partida, os atores agora são desenhados diretamente sobre um cenário contínuo, sem os cards explicativos da primeira entrega. Goblin, grade e cadeira ficam próximos. Cabeçalho, rodapé e medidor foram reorganizados; o recurso independente do ocupante e a sequência de animação permanecem os mesmos. Ver `SALA_CONTINUA_UX.md`.

## Encaixe do cabo no ocupante — 0.12.2

O campo `Cable Anchor` de `ExecutionCharacter` define o ponto de conexão na imagem, em coordenadas normalizadas de 0 a 1. O cavaleiro usa (0,74; 0,69), junto ao conector da lateral direita da cadeira. Ao criar outro ocupante, ajustar esse campo se a posição do encaixe mudar. O cabo acompanha automaticamente a posição, a escala e a proporção do sprite, sem modificar a fase. O pacote visual também expõe `Engineer Cable Anchor` para o encaixe no console do goblin.

## Atualização 0.13 — impacto e duração

A sequência completa passa de 1,65 para 2,40 s, com o choque de 0,40 a 1,75 s. Flashes e tremor afetam somente o fundo; o ocupante permanece totalmente visível. O modo suave conserva a animação e usa uma iluminação gradual sem tremor. A janela de resultado aguarda o encerramento da sequência. Os frames dos personagens continuam substituíveis pelos mesmos recursos.

## Acabamento 0.14.2

A pose levantada agora separa a alavanca da orelha e conecta corretamente a mão direita ao antebraço. Os pisos metálicos ocupam toda a largura sob os atores. Arquivos e prompts finais da edição nativa em [ACABAMENTO_GOBLIN_PISO.md](ACABAMENTO_GOBLIN_PISO.md). O ícone tem arte própria do mesmo goblin; a trilha é independente das animações e baixa de volume durante a descarga.
