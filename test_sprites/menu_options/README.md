# Opções de sprite para o menu

Artes de avaliação. A opção 2 foi escolhida e integrada ao menu na revisão local 0.14.5, como `assets/art/concept_v3/menu_chair_wires.png`. As demais continuam apenas como propostas. Todas são PNGs com fundo transparente e usam a cadeira atual como referência de estilo. O goblin e a cadeira da partida não foram substituídos; não houve nova instalação no celular.

Modo: geração pela ferramenta nativa `image_gen`, uma chamada por opção. Originais preservados em `.codex/generated_images`; cópias de avaliação nesta pasta. A pasta contém `.gdignore` e não é importada pelo Godot.

| Opção | Arquivo | Direção |
| --- | --- | --- |
| 1 | `01-cadeira-classica.png` | Cadeira vazia de madeira e aço, fios coloridos e faíscas discretas. |
| 2 | `02-fiacao-caotica.png` | Cabos em grandes curvas emolduram a cadeira. |
| 3 | `03-cadeira-industrial.png` | Estrutura mais robusta, mais metal e tubulação organizada. |
| 4 | `04-emblema-eletrico.png` | Composição circular compacta, com a cadeira dentro de um anel de cabos. |

## Prompts finais

### 1 — Clássica

Use case: game-asset. Generate ONE new standalone transparent menu hero sprite for Zap & Fry, visually distinct from the existing goblin operator. The reference image is ONLY a design/style reference for the game's electric chair, steel, brass, wood and painted cartoon rendering. Output an EMPTY whimsical villain-fortress electric chair, with absolutely NO seated person, no goblin, no skeleton, no face. Tall dark walnut backrest, chunky armrests, open leather straps, riveted blue-gray steel braces and a broad steel foot platform, brass electrical connectors. A metal electrode hood rests just above the empty chair back on a curved support. Several thick insulated cables curve naturally around the base and up the sides: corrugated dark steel conduit plus blue, red and gold-yellow wires, with a few restrained cyan electrical sparks at connectors. Strong clear silhouette, front three-quarter perspective at slightly elevated eye level, clean anatomy of the chair and physically coherent cable connections. The EMPTY chair is the central dominant object and fills about 85 percent of canvas height; cables form a balanced compact frame, with the entire object and all cable tips inside the square canvas and modest transparent margins. Match the game's polished hand-painted exaggerated cartoon style: thick dark outlines, warm wood, steel blue-gray metal, small brass highlights, subtle scratches and soft volume; readable at roughly 300 pixels tall on a mobile menu. Playfully ominous rather than realistic. Single isolated object sprite with genuine transparent background. No floor, wall, scenery, UI, lettering, logo, border, title, duplicate chair, gore, dramatic lighting rays or large glows. Not a sprite sheet.
