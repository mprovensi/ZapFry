# Correção dos fios — espessura uniforme

Modo: edição com a ferramenta nativa `image_gen`. Referências e PNGs anteriores preservados. As quatro saídas selecionadas estão em `assets/art/concept_v3/`, com sufixo `_uniform.png`. Os sprites retos foram mantidos como referência de espessura e entrelaçado.

Padrão: cada porta ocupa aproximadamente 26% da largura da célula. A validação aceita até dois pontos percentuais de variação na silhueta e 1,5 ponto percentual de deslocamento do centro para acomodar o contorno pintado e a importação. Conferir todos os giros e estados. Não há alteração das fases ou dos alvos de toque.

## curve

Arquivo: `assets/art/concept_v3/curve_uniform.png`

Prompt final:

Use case: precise-object-edit. Edit this transparent square game cable sprite. Make ONE SMALL ALIGNMENT CORRECTION ONLY: move the entire EAST-facing horizontal arm UP by 2% of the canvas height (about 25 pixels on this 1254px canvas). Its four-wire bundle and silver end clamp currently end slightly BELOW the vertical midpoint. The final east port must be centered EXACTLY at y=50% of the canvas, with its bundle spanning y=37% to63%. Keep the NORTH-facing port centered at x=50%, spanning x=37% to63%, and keep its position unchanged. Smoothly adjust the bend to meet the slightly raised horizontal arm. Preserve the gently intertwined red/yellow/green/blue wires, current widths, painted cartoon look, exact square canvas, actual transparent background, and only NORTH+EAST ports. No south or west branch. Do not rescale or recenter the entire sprite; correct only the east arm. Unpowered, no glow, no background, no text.

## tee

Arquivo: `assets/art/concept_v3/tee_uniform.png`

Prompt final:

Use case: precise-object-edit. Image 1 is the T cable edit target. Image 2 is the straight cable gauge reference. Change ONLY the thickness and end alignment of the T: its branches are visibly TOO THIN. Make ALL THREE arms 45% THICKER than they currently are, around the existing centerlines, not longer. Widen the top arm and BOTH side arms equally; include all four colored wires in each arm. At the image boundaries the top bundle should span x=37% to63%; the left and right bundles should span y=37% to63%, all exactly centered. This is about one quarter of the whole tile, NOT one sixth. Do not keep the thin original arms. Preserve the gently intertwined cables, painted cartoon silver brackets, colors, and the T topology (NORTH+EAST+WEST ports only). South edge empty. Exactly square canvas. Connected cable ends run flush through canvas edges. Actual transparent background, no tile plate, no text, no grid, no extra ports. One unpowered sprite.

## curve_live

Arquivo: `assets/art/concept_v3/curve_live_uniform.png`

Prompt final:

Use case: lighting-weather. Image 1 is the EXACT unpowered game cable sprite to edit. Produce its powered variant. Preserve the canvas, silhouette, exact cable positions, overlaps, wire thickness, end clamps, and all port end locations pixel-aligned to image 1. Add only a restrained bright cyan-white electrical glow following the existing cable bundle and a few thin electric arcs in its INTERIOR. At the outermost 5% of every connected end keep the original silhouette, gauge and opaque alpha unchanged; do not let glow widen the ports. Keep original red/yellow/green/blue colors visible and the mild intertwined structure. Transparent background stays truly transparent. No plate, no text, no new wires, no extra branches. One transparent square sprite, same geometry as image 1. ONLY NORTH and EAST ports. SOUTH and WEST edges empty. Preserve the corrected EAST port centered at y=50% and the NORTH port centered at x=50%; do not shift either arm even slightly. Keep every endpoint exactly in place.

## tee_live

Arquivo: `assets/art/concept_v3/tee_live_uniform.png`

Prompt final:

Use case: lighting-weather. Image 1 is the EXACT unpowered game cable sprite to edit. Produce its powered variant. Preserve the canvas, silhouette, exact cable positions, overlaps, wire thickness, end clamps, and all port end locations pixel-aligned to image 1. Add only a restrained bright cyan-white electrical glow following the existing cable bundle and a few thin electric arcs in its INTERIOR. At the outermost 5% of every connected end keep the original silhouette, gauge and opaque alpha unchanged; do not let glow widen the ports. Keep original red/yellow/green/blue colors visible and the mild intertwined structure. Transparent background stays truly transparent. No plate, no text, no new wires, no extra branches. One transparent square sprite, same geometry as image 1. ONLY NORTH, EAST and WEST ports. SOUTH edge empty.

