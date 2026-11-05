# Prévia dos cinco condenados — pose de espera

Gerado em 5 de novembro de 2026 com a ferramenta nativa `image_gen`, com fundo transparente. Fontes copiadas sem alterar os pixels. Pranchas e capturas são renderizadas na engine, com textos nativos.

| Personagem | Arquivo selecionado |
| --- | --- |
| Zefa do Trovão — cavaleira adulta curvilínea, com busto destacado conforme pedido | `01_cavaleira_idle_v2.png` |
| Capitão Biscoito — pirata | `02_pirata_idle.png` |
| Dra. Fuzarca — alquimista goblin | `03_alquimista_idle.png` |
| Nico Mi Maior — bardo | `04_bardo_idle.png` |
| Conde Protocolo — vampiro burocrata | `05_vampiro_idle.png` |

A v1 da cavaleira permanece como alternativa; a v2 é a selecionada em `characters.json`. Variações realistas descartadas não fazem parte deste conjunto. Os cinco retratos compartilham cadeira, composição e pontos de conexão aproximados do modelo existente. As fontes selecionadas são PNG RGBA de 1254×1254, com alpha real e margens verificadas (`validation.json`). A renderização nativa produziu cinco capturas e duas pranchas, sem erros. O recorte de exibição na prancha ignora franjas de alpha quase invisível; não altera os PNGs.

Esta pasta é ignorada pela importação automática do Godot (`.gdignore`) e pelos filtros de exportação. São prévias; a campanha e o celular continuam usando os personagens da versão instalada. Ainda faltam choque, recuperação, máscaras/paletas, recursos finais, sorteio e diálogos.

## Reproduzir a prancha e as capturas

Executar da raiz do projeto com Godot 4.7.2, renderer real e áudio Dummy:

```powershell
& $env:GODOT_BIN --path . --audio-driver Dummy --script res://test_sprites/condemned_v1/render_previews.gd -- --test
```

Os resultados ficam em `previews/`: `prancha-personagens.png`, `prancha-jogo.png` e uma captura de gameplay para cada condenado. O modo `--test` é obrigatório e isola o perfil real. O preview usa somente a pose de espera; não simula poses de choque inexistentes.

## Referências e prompts exatos

Referência 1: `assets/art/concept_v3/portrait_idle.png`, edit target da cadeira/pose. Referência 2: `assets/art/concept_v3/engineer.png`, estilo cartoon existente. Para a cavaleira v2, a referência 1 é sua primeira versão `01_cavaleira_idle_v1.png`, preservando identidade e cadeira.

### cavaleira_v2

```text
Use case: precise-object-edit.
Asset type: one transparent square idle-pose game sprite, character seated in an electric chair, for the existing humorous fantasy puzzle Zap & Fry.
Input images: Image 1 is the EDIT TARGET and alignment template: existing adult woman knight seated in a wooden electric chair. Image 2 is a STYLE REFERENCE ONLY: the existing goblin engineer. Do not put the goblin engineer or his lever in this output.
Primary request: refine ONLY the seated adult woman knight with the new adult character described below. Preserve the same chair design, chair width, frontal camera angle, lower foot platform, armrest positions, steel lap restraint, base and the side electrical connector positions. Keep the same square canvas proportions and consistent full-body scale, fixed chair foot platform close to 94% canvas height and clear margin around the upper cable loop.
Style: clean exaggerated hand-painted 2D cartoon matching these exact game references, thick dark outlines, readable expressive eyes, brushed metal highlights, warm wood, restrained detail for viewing at 160 pixels tall. Same frontal seated composition, no perspective change, no photorealism, no 3D render, no pixel grid.
Pose: idle/awaiting, alive and intact, comically apprehensive or defiant, seated naturally, both hands resting on the corresponding armrests and both feet on the foot platform. Exactly two arms and two legs with anatomically connected hands. Headwear can change to suit the new character, with a small visible electrical contact that preserves the upper cable connection; do not hide the character's defining hair or face.
Background: ACTUAL transparent alpha, no painted black, no checkerboard, no room, no floor, no scenery, no cast shadow outside the chair base.
No words, labels, logos, borders, speech bubbles, glow, lightning, injuries, blood or extra characters. Output ONE single character WITH the complete chair, not a sprite sheet. Do not crop any chair feet, hair or cables.
Character: ZEFA DO TROVÃO: refine the existing Black woman knight to be unmistakably an attractive mature adult in her thirties, voluptuous hourglass figure with a VERY FULL BUST and curvy hips. Her fitted silver breastplate and plum-purple corset-shaped armored bodice emphasize her bust and waist; a deep rounded neckline shows tasteful upper cleavage while fully covering breasts with opaque armor/cloth. Confident charming expression, mature facial proportions, short black natural curls, dark brown skin and gold hoop earrings. Keep her identity and robust build, two correctly connected hands on the original armrests, same feet and complete chair. Full-body game sprite with a playful glamorous fantasy costume, not a chest closeup. NO nudity, nipples, transparent clothing or explicit sexual action. Preserve exact 2D cartoon style, outline weight, chair, original pose, all wires and square canvas alignment. No photographic rendering, no room, true transparent background.
```

### pirata

```text
Use case: precise-object-edit.
Asset type: one transparent square idle-pose game sprite, character seated in an electric chair, for the existing humorous fantasy puzzle Zap & Fry.
Input images: Image 1 is the EDIT TARGET and alignment template: existing knight seated in a wooden electric chair. Image 2 is a STYLE REFERENCE ONLY: the existing goblin engineer. Do not put the goblin engineer or his lever in this output.
Primary request: replace ONLY the seated knight with the new adult character described below. Preserve the same chair design, chair width, frontal camera angle, lower foot platform, armrest positions, steel lap restraint, base and the side electrical connector positions. Keep the same square canvas proportions and consistent full-body scale, fixed chair foot platform close to 94% canvas height and clear margin around the upper cable loop.
Style: clean exaggerated hand-painted 2D cartoon matching these exact game references, thick dark outlines, readable expressive eyes, brushed metal highlights, warm wood, restrained detail for viewing at 160 pixels tall. Same frontal seated composition, no perspective change, no photorealism, no 3D render, no pixel grid.
Pose: idle/awaiting, alive and intact, comically apprehensive or defiant, seated naturally, both hands resting on the corresponding armrests and both feet on the foot platform. Exactly two arms and two legs with anatomically connected hands. Headwear can change to suit the new character, with a small visible electrical contact that preserves the upper cable connection; do not hide the character's defining hair or face.
Background: ACTUAL transparent alpha, no painted black, no checkerboard, no room, no floor, no scenery, no cast shadow outside the chair base.
No words, labels, logos, borders, speech bubbles, glow, lightning, injuries, blood or extra characters. Output ONE single character WITH the complete chair, not a sprite sheet. Do not crop any chair feet, hair or cables.
Character: CAPITÃO BISCOITO: Adult man pirate with light freckled skin, lean body, scruffy copper-brown beard, big readable CARTOON eyes, arched eyebrows and a nervous crooked grin. Compact battered navy tricorn and red head scarf, faded teal coat with brass buttons, striped undershirt, brown boots. Frontal seated pose and SAME CHAIR as image 1, not a new throne. Keep the upper electrode compact so his hat fits inside the original upper wire loop. Exactly two arms, hands correctly attached and resting on each armrest. Two feet on the same platform. A clean hand-drawn 2D cartoon game sprite, not an actor or realistic portrait. No scenery, no text. True transparent alpha.
```

### alquimista

```text
Use case: precise-object-edit.
Asset type: one transparent square idle-pose game sprite, character seated in an electric chair, for the existing humorous fantasy puzzle Zap & Fry.
Input images: Image 1 is the EDIT TARGET and alignment template: existing knight seated in a wooden electric chair. Image 2 is a STYLE REFERENCE ONLY: the existing goblin engineer. Do not put the goblin engineer or his lever in this output.
Primary request: replace ONLY the seated knight with the new adult character described below. Preserve the same chair design, chair width, frontal camera angle, lower foot platform, armrest positions, steel lap restraint, base and the side electrical connector positions. Keep the same square canvas proportions and consistent full-body scale, fixed chair foot platform close to 94% canvas height and clear margin around the upper cable loop.
Style: clean exaggerated hand-painted 2D cartoon matching these exact game references, thick dark outlines, readable expressive eyes, brushed metal highlights, warm wood, restrained detail for viewing at 160 pixels tall. Same frontal seated composition, no perspective change, no photorealism, no 3D render, no pixel grid.
Pose: idle/awaiting, alive and intact, comically apprehensive or defiant, seated naturally, both hands resting on the corresponding armrests and both feet on the foot platform. Exactly two arms and two legs with anatomically connected hands. Headwear can change to suit the new character, with a small visible electrical contact that preserves the upper cable connection; do not hide the character's defining hair or face.
Background: ACTUAL transparent alpha, no painted black, no checkerboard, no room, no floor, no scenery, no cast shadow outside the chair base.
No words, labels, logos, borders, speech bubbles, glow, lightning, injuries, blood or extra characters. Output ONE single character WITH the complete chair, not a sprite sheet. Do not crop any chair feet, hair or cables.
Character: DRA. FUZARCA: MIDDLE-AGED ADULT woman goblin alchemist, green skin, short round body, large tightly curled dark auburn hair puff, copper round safety glasses with expressive eyes visible, pointed ears, mature adult facial proportions, arched brows, mischievous anxious smile. Clearly a grown woman, not a child. Violet long sleeves and stained cream apron, two tiny capped potion bottles attached to her belt. Same frontal seated wooden chair from image 1, same steel horizontal lap restraint, same feet platform and side cable connections. Both hands correctly attached to her arms and resting on armrests. Clearly different from the male engineer in image 2. FLAT hand-painted 2D cartoon, bold outlines, no photographic/3D texture. No room or background. True transparent alpha.
```

### bardo

```text
Use case: precise-object-edit.
Asset type: one transparent square idle-pose game sprite, character seated in an electric chair, for the existing humorous fantasy puzzle Zap & Fry.
Input images: Image 1 is the EDIT TARGET and alignment template: existing knight seated in a wooden electric chair. Image 2 is a STYLE REFERENCE ONLY: the existing goblin engineer. Do not put the goblin engineer or his lever in this output.
Primary request: replace ONLY the seated knight with the new adult character described below. Preserve the same chair design, chair width, frontal camera angle, lower foot platform, armrest positions, steel lap restraint, base and the side electrical connector positions. Keep the same square canvas proportions and consistent full-body scale, fixed chair foot platform close to 94% canvas height and clear margin around the upper cable loop.
Style: clean exaggerated hand-painted 2D cartoon matching these exact game references, thick dark outlines, readable expressive eyes, brushed metal highlights, warm wood, restrained detail for viewing at 160 pixels tall. Same frontal seated composition, no perspective change, no photorealism, no 3D render, no pixel grid.
Pose: idle/awaiting, alive and intact, comically apprehensive or defiant, seated naturally, both hands resting on the corresponding armrests and both feet on the foot platform. Exactly two arms and two legs with anatomically connected hands. Headwear can change to suit the new character, with a small visible electrical contact that preserves the upper cable connection; do not hide the character's defining hair or face.
Background: ACTUAL transparent alpha, no painted black, no checkerboard, no room, no floor, no scenery, no cast shadow outside the chair base.
No words, labels, logos, borders, speech bubbles, glow, lightning, injuries, blood or extra characters. Output ONE single character WITH the complete chair, not a sprite sheet. Do not crop any chair feet, hair or cables.
Character: NICO MI MAIOR: ADULT nonbinary human bard with olive skin, androgynous angular adult face, asymmetrical dark hair swept to one side with teal streak, raised theatrical eyebrows and pursed lips as if their opera was interrupted. Slim body, plum theatrical tunic with teal trim, modest cream ruffled collar, brown boots. Small wooden lute lies across the lap BELOW the safety bar. Both hands rest naturally on the corresponding chair armrests; no crossed legs, both boots rest on the same foot platform. Preserve the exact wooden chair, lap bar and side electrical connectors from image 1. Bold outline hand-painted 2D CARTOON, not photographic. No nameplate, music notes, words or room. True transparent alpha.
```

### vampiro

```text
Use case: precise-object-edit.
Asset type: one transparent square idle-pose game sprite, character seated in an electric chair, for the existing humorous fantasy puzzle Zap & Fry.
Input images: Image 1 is the EDIT TARGET and alignment template: existing knight seated in a wooden electric chair. Image 2 is a STYLE REFERENCE ONLY: the existing goblin engineer. Do not put the goblin engineer or his lever in this output.
Primary request: replace ONLY the seated knight with the new adult character described below. Preserve the same chair design, chair width, frontal camera angle, lower foot platform, armrest positions, steel lap restraint, base and the side electrical connector positions. Keep the same square canvas proportions and consistent full-body scale, fixed chair foot platform close to 94% canvas height and clear margin around the upper cable loop.
Style: clean exaggerated hand-painted 2D cartoon matching these exact game references, thick dark outlines, readable expressive eyes, brushed metal highlights, warm wood, restrained detail for viewing at 160 pixels tall. Same frontal seated composition, no perspective change, no photorealism, no 3D render, no pixel grid.
Pose: idle/awaiting, alive and intact, comically apprehensive or defiant, seated naturally, both hands resting on the corresponding armrests and both feet on the foot platform. Exactly two arms and two legs with anatomically connected hands. Headwear can change to suit the new character, with a small visible electrical contact that preserves the upper cable connection; do not hide the character's defining hair or face.
Background: ACTUAL transparent alpha, no painted black, no checkerboard, no room, no floor, no scenery, no cast shadow outside the chair base.
No words, labels, logos, borders, speech bubbles, glow, lightning, injuries, blood or extra characters. Output ONE single character WITH the complete chair, not a sprite sheet. Do not crop any chair feet, hair or cables.
Character: CONDE PROTOCOLO: OLDER ADULT male vampire bureaucrat with cool gray-blue skin, tall slender body, mature long angular face, slicked-back silver-gray hair, a thin mustache, two tiny fangs and annoyed raised eyebrows. Small rectangular reading glasses, eyes visible. Burgundy formal coat, charcoal waistcoat, cream shirt, understated dark cape collar and narrow polished black boots. Closed plain document folder sits on his lap BELOW the lap restraint, with no lettering or symbols. Both hands are attached naturally and rest on armrests, both feet on platform. Preserve original chair and cables from image 1. Make a bold-outline 2D CARTOON sprite matching image 1, NOT a live-action person, photoreal portrait or 3D scene. No room, no floor or scenery. True transparent alpha.
```

