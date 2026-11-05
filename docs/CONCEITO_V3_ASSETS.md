# Assets derivados dos conceitos — pacote v3

Modo: ferramenta nativa `image_gen`, com os JPEGs de `test_sprites` como referências e edições transparentes. Os originais foram preservados. Os PNGs selecionados estão em `assets/art/concept_v3/`; os originais gerados também permanecem no diretório padrão do Codex.

As operações de alinhamento/recorte de margens usadas no jogo são recursos nativos `AtlasTexture`; os pixels dos PNGs não foram alterados por scripts. A importação do Godot limita a resolução de execução sem descartar as fontes.

## plate

Arquivo: `assets/art/concept_v3/tile_plate.png`

Prompt final:

Use case: background-extraction. Asset type: ONE square game tile background for the existing Zap & Fry puzzle. Input image 1 is the edit target/reference sheet. Extract and clean ONLY the empty beveled blue-gray metal plate from cell 2D. Recreate it as a single isolated front-facing square plate, thick dark cartoon outline, rounded corners, subtle cool metal highlights, small corner screws, matching this sheet's painterly cartoon art. No wires, no sockets, no symbols, no labels, no grid, no letters, no shadow outside the object. Actual transparent background. Square canvas; plate occupies the central 94% and is centered. This is the fixed backing under separately rotating wires. Preserve the reference material and style. Return one standalone transparent PNG asset, not a sheet.

## straight

Arquivo: `assets/art/concept_v3/straight.png`

Prompt final:

Use case: precise-object-edit. Asset type: one standalone transparent PNG game sprite for Zap & Fry, square canvas. Input image 1 is the reference/edit target sheet. Preserve its painted cartoon cables, thick ink outlines, colored red/yellow/green/blue cable bundle, small gray metal clamps, cool industrial material. Extract/reconstruct only the requested wire component: no metal backing plate, no colored background, no labels, no grid, no arrows, no text, no socket, no extra branches. Actual transparent background around the cables. Cable bundle thickness about 25% of the canvas, clean silhouette readable at 64 pixels. Exact connection centers must be at the requested edge midpoints. The wires and end clamps continue through those canvas edges with no margin at connected edges; all unconnected edges are entirely transparent. Center the geometry on the square. Output exactly one component, not an atlas.
Requested component: unpowered straight cable bundle from cell 1B. ONLY TWO ports: NORTH at (50% width,0% height) and SOUTH at (50% width,100% height). Runs vertically through the center. Left and right sides have no wires. No glow.

## curve

Arquivo: `assets/art/concept_v3/curve.png`

Prompt final:

Use case: precise-object-edit. Input 1 is the draft to correct, input 2 is style reference. Produce ONE transparent game cable sprite. Keep the colored painted cartoon cable style, no metal backing plate. CORRECT THE GEOMETRY: square canvas. A four-cable bundle enters EXACTLY at the midpoint of the TOP edge (x=50%, y=0%), runs downward to the CENTRAL REGION, bends RIGHT, and exits EXACTLY at the midpoint of the RIGHT edge (x=100%, y=50%). Thus the upright top leg and horizontal right leg form a rounded L, with its corner close to canvas center. The top-end clamp is HORIZONTAL and touches the TOP border. The right-end clamp is VERTICAL, located against the RIGHT border. All four cables run horizontally out through that vertical right clamp. Do not put the right clamp along the bottom. No cable at LEFT or BOTTOM. Entire bottom and left edge transparent. No loose or branching cable. Geometry must meet the edge midpoints exactly for a rotating puzzle tile. Genuine transparent background; no plate, no letters, no arrow, no glow. One asset, not a sheet.

## tee

Arquivo: `assets/art/concept_v3/tee.png`

Prompt final:

Use case: precise-object-edit. Asset type: one standalone transparent PNG game sprite for Zap & Fry, square canvas. Input image 1 is the reference/edit target sheet. Preserve its painted cartoon cables, thick ink outlines, colored red/yellow/green/blue cable bundle, small gray metal clamps, cool industrial material. Extract/reconstruct only the requested wire component: no metal backing plate, no colored background, no labels, no grid, no arrows, no text, no socket, no extra branches. Actual transparent background around the cables. Cable bundle thickness about 25% of the canvas, clean silhouette readable at 64 pixels. Exact connection centers must be at the requested edge midpoints. The wires and end clamps continue through those canvas edges with no margin at connected edges; all unconnected edges are entirely transparent. Center the geometry on the square. Output exactly one component, not an atlas.
Requested component: unpowered three-way T junction derived from 5A/5D but rotated to ONLY THREE ports: NORTH (50%,0%), WEST (0%,50%) and EAST (100%,50%). Three connected cable bundles meet in the central region. NO lower branch, NO bottom connector, NO fourth port. Bottom edge is entirely transparent. No glow.

## straight_live

Arquivo: `assets/art/concept_v3/straight_live.png`

Prompt final:

Use case: precise-object-edit. Input 1 is the EXACT unpowered wire sprite to edit; input 2 is glow style reference (3B). Create its powered counterpart. Preserve the EXACT square canvas, vertical position, thickness, two edge endpoints, silhouettes, clamps, screws and individual red/yellow/green/blue wires of input 1. Add vivid cyan/white electricity flowing ALONG the vertical cable bundle, luminous thin cores and a restrained cyan halo, similar to reference 3B. Exactly TWO ports: top-middle and bottom-middle. NO new lateral branches. Do not move, crop or resize the cable or clamps. Keep left/right edges transparent; no plate, text, arrows, colored background. Actual transparent PNG, one standalone sprite.

## curve_live

Arquivo: `assets/art/concept_v3/curve_live.png`

Prompt final:

Use case: precise-object-edit. Input 1 is the EXACT corrected unpowered curve sprite to edit. Input 2 is the energy style reference. Produce ONE powered counterpart preserving the exact square canvas, cable geometry, clamp locations and transparent silhouette of input 1. There are ONLY TWO edge ports: NORTH midpoint and EAST midpoint. The top clamp stays horizontal at top edge; the right clamp stays VERTICAL at the middle of the right edge. All four colored cables make the same central rounded L turn. Add cyan/white energy ALONG the existing cables, a thin bright core following the entire top-to-right route and a restrained cyan halo. Preserve the visible colored wires and gray clamps. Absolutely no cable at left/bottom, no fourth port, no plate, no arrows, no text, no background. Do not move, resize or crop the geometry. Actual transparent PNG.

## tee_live

Arquivo: `assets/art/concept_v3/tee_live.png`

Prompt final:

Use case: precise-object-edit. Input 1 is the EXACT unpowered T sprite to edit; input 2 is cyan energy style reference. Create its powered counterpart preserving the EXACT square canvas, positions and three terminals. Add cyan/white electric energy along the existing cables with thin luminous core and restrained halo. EXACTLY THREE branches: TOP middle, LEFT middle, RIGHT middle. They meet in the central junction. The entire BOTTOM edge remains transparent. DO NOT create a lower branch or a cross. Preserve the gray clamps and the recognizable colored cables. No plate, no labels, no arrow, no background. Actual transparent PNG, one standalone T sprite.

## blocker

Arquivo: `assets/art/concept_v3/blocker.png`

Prompt final:

Use case: background-extraction. Extract/reconstruct ONE broken cable component inspired by cell 7A of input image. A horizontal bundle of red, yellow, green and blue cables held by gray metal clamps on left/right, broken open at center, frayed copper ends and a small yellow spark in the gap. Clearly broken and not conducting. Painted industrial cartoon matching the reference. Square canvas, component fills central 80% horizontally and 45% vertically. Transparent everywhere around the component. NO metal backing plate, no sheet, no numbers, no labels, no text.

## restart_icon

Arquivo: `assets/art/concept_v3/restart_icon.png`

Prompt final:

Use case: background-extraction. Extract/reconstruct ONE circular restart icon from cell 7D in the reference. Two clear broad curved arrows in pale brushed blue-gray metal, thick dark cartoon outline and subtle highlight, making a clockwise circular motion. Centered on square canvas, clean bold silhouette readable at 24 pixels. No metal backing square, no other objects, no text, no labels. Actual transparent PNG, one standalone UI icon.

## engineer

Arquivo: `assets/art/concept_v3/engineer.png`

Prompt final:

Use case: background-extraction. Asset type: ONE transparent menu character sprite for Zap & Fry. Input image is the edit target. Extract/reconstruct the green GOBLIN ENGINEER from the upper left TOGETHER with the brass lever mechanism he is operating, preserving his sly face, goggles, pointed ears, work apron and gloves, painted cartoon style, dark clean outline and cool industrial palette. Complete the character's boots and the lever box so the object is self-contained. No knight, no chair, no puzzle grid, no walls, no HUD, no numbers, no texts or labels. Square transparent canvas. Whole goblin and lever machine fit fully within the central 90% of the canvas with a little space at all edges. His face is large and readable as a small game mascot. Actual alpha transparency, no ground rectangle or cast background.

## portrait_idle

Arquivo: `assets/art/concept_v3/portrait_idle.png`

Prompt final:

Use case: background-extraction. Asset type: ONE composite transparent game portrait, knight plus electric chair. Input image is the edit target. Extract/reconstruct the frightened armored knight seated in the electric chair from the lower half of the image, preserving his comical wide-eyed face, metal cap, gloved hands, armor and restrained cartoon tone. Include the COMPLETE chair, seat, back, armrests, legs and compact curved cables; remove all walls, HUD, buttons, puzzle grid and text. Simplify small armor details and slightly enlarge head/face for readability in a small game window. Front facing, complete full figure and chair centered, square canvas, feet and chair base at 92% canvas height; head top near 8%. Keep everything inside the canvas with transparent margins. This will be the alignment reference for later zap poses. Actual transparent PNG, one asset, not a sheet.

## portrait_zap

Arquivo: `assets/art/concept_v3/portrait_zap.png`

Prompt final:

Use case: precise-object-edit. Asset type: ONE transparent animation pose for an existing knight+chair game portrait. Input 1 is the exact alignment and identity reference. Keep EXACT canvas size, scale, placement, palette, framing and transparent margins. Do not crop, zoom, rotate, move, add surrounding scenery or add text. The whole chair and knight must occupy the same coordinates as in the input so this frame can be swapped directly without jumping. Change only the seated knight's reaction into a COMICAL CARTOON X-RAY zap: exaggerated skull face with dark eye sockets and tiny teeth, a few stylized rib/arm bones visible as a cartoon overlay through the armor, subtle cyan edge glow and small electrical arcs near the cap. No blood, burns, wounds or realistic injury. Preserve helmet, armor silhouette, sitting pose, chair, restraining bars, hands, boots, tubes and every major contour. Actual transparent PNG. One pose only, not a sheet.

## portrait_recover

Arquivo: `assets/art/concept_v3/portrait_recover.png`

Prompt final:

Use case: precise-object-edit. Asset type: ONE transparent animation pose for an existing knight+chair game portrait. Input 1 is the exact alignment and identity reference. Keep EXACT canvas size, scale, placement, palette, framing and transparent margins. Do not crop, zoom, rotate, move, add surrounding scenery or add text. The whole chair and knight must occupy the same coordinates as in the input so this frame can be swapped directly without jumping. Change only the knight's facial expression into a dazed but funny relieved reaction after an electric cartoon gag: mildly crossed eyes, crooked little smile, tiny harmless soot smudges and two delicate wisps of gray smoke near the helmet. No wounds, blood or burns. Preserve helmet, armor, sitting pose, chair, restraining bars, hands, boots, tubes and every major contour. Actual transparent PNG. One pose only, not a sheet.

## room_background

Arquivo: `assets/art/concept_v3/room_background.png`

Prompt final:

Use case: precise-object-edit. Asset type: clean WIDE 3:1 background for a small cartoon villain laboratory window. Use the input image as the edit target and preserve its painted steel-wall panels, bolts, pipes, restrained blue-gray palette and yellow/black industrial hazard strip. REMOVE ALL characters, electric chair, puzzle tiles, all UI buttons, timer displays, numbers, readable text, warning labels and icons. Reconstruct a coherent industrial wall with low-contrast simple details, a little floor along the bottom, subtle cables and warm machinery light. Left third needs room for a separate character sprite; right two thirds should be mostly clear dark wall for readable overlaid text. Front view, wide composition, no perspective floor dominating, no baked lettering or HUD. One environment background only.

## primary_button

Arquivo: `assets/art/concept_v3/primary_button.png`

Prompt final:

Use case: background-extraction. Asset type: ONE blank red cartoon UI button background. Extract/reconstruct the beveled red ACTIVATE button style at lower right of the source, but REMOVE the word ACTIVATE and all other lettering. Dark thick ink outer outline, metallic blue-gray rim, red inset face, subtle painted highlights and rounded corners. Front-facing horizontal rounded rectangle, aspect ratio about 3.5:1, centered on a transparent canvas with only a narrow transparent margin. No text, no symbols, no icons, no background or surrounding controls. This background will be stretched with nine-patch margins and native Portuguese labels drawn over it.

