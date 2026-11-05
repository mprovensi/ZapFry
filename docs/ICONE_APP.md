# Ícone do aplicativo — 0.14.1

Goblin engenheiro, óculos e raio amarelo: o mesmo personagem e as cores industriais do jogo, com silhueta legível em tamanho pequeno. Sem texto e sem cena de execução.

## Arquivos e integração

- `assets/icon/goblin.png`: arte original com transparência real, gerada pela ferramenta nativa de imagens, usando `assets/art/concept_v3/engineer.png` como referência de personagem e estilo.
- `assets/icon/app.png`: ícone principal opaco de 1024×1024, usado pelo projeto, Windows e launcher Android clássico.
- `assets/icon/adaptive_foreground.png`: personagem com transparência, 432×432.
- `assets/icon/adaptive_background.png`: fundo metálico azul, opaco, 432×432; fonte vetorial em `background.svg`.
- `tools/build_app_icon.gd`: empacotamento nativo Godot com escala e composição; não redesenha o personagem. Toda a silhueta com alfa acima de 5% fica dentro de um círculo de raio 130 px, com margem para a zona segura de 132 px.
- `builds/previews/icon-android.png` e `icon-64.png`: conferência do recorte circular e da leitura reduzida.

As três opções `launcher_icons` ficam explícitas em `export_presets.cfg`, evitando o fundo padrão do Godot. `project.godot` aponta para o ícone principal. O antigo `assets/icon.svg` fica preservado como fonte anterior. Regerar: Godot `--headless --path . --script res://tools/build_app_icon.gd`, seguido da importação e exportação normais.

Dimensões e zona segura conferidas na [documentação oficial de exportação Android do Godot](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html#providing-launcher-icons). Propriedades conferidas na [referência oficial do exportador](https://docs.godotengine.org/en/stable/classes/class_editorexportplatformandroid.html).

## Geração

Modo: ferramenta nativa `image_gen`, imagem única, fundo transparente. Sem CLI/API. Referência inspecionada antes da geração. Cópia selecionada do resultado `exec-421318b2-6e01-4c1e-92f8-c25b0d52a34f.png`, preservando o original em `.codex/generated_images`.

Prompt final:

> Use the reference image only as character and style reference. Create a production mobile game launcher foreground emblem for Zap & Fry. A close-up head of the SAME mischievous green goblin engineer: long pointed ears, expressive amber eyes, big hooked nose, wide toothy sly grin, round brass and dark steel goggles resting on his forehead with luminous pale green lenses. Head only plus a tiny hint of the dark teal work collar, no full body, no lever or machinery. One bold simple golden-yellow lightning bolt overlaps the lower right cheek/collar edge, readable as an electricity symbol, without covering the eyes or smile. Match the polished hand-painted exaggerated cartoon style, thick dark outlines, olive-green skin and brass accents of the reference, simplify small surface detail for legibility at 48 pixels. Strong clean silhouette, symmetrical balanced near-front three-quarter face. Subject fills about 88% of a square canvas, ears completely visible with transparent margin all around. Single isolated emblem with genuine transparent background, no text, no letters, no frame, no app tile, no scenery, no checkerboard, no gore. High contrast, playful villain tone.

Esta atualização altera somente arte do ícone, configuração de exportação e número da versão. As fases, dicas, progresso, vibração e animações mantêm o comportamento validado na 0.14.
