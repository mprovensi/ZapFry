# Cinco condenados — poses finais (0.16.0)

Artes geradas pela ferramenta nativa `image_gen`, preservando PNGs transparentes. Cada personagem tem espera, choque/esqueleto e recuperação; importação Godot limitada a 512 px. A espera veio das prévias em `test_sprites/condemned_v1/`. Fontes finais em `assets/characters/<id>/` e recursos em `assets/characters/<id>.tres`.

Nomes: cinco por base, sorteados independentemente da dificuldade. O mesmo personagem/nome é mantido ao reiniciar ou reabrir a fase pendente. Novas fases usam uma lista embaralhada dos cinco, evitando repetição imediata. Nome aparece ao lado da cadeira. Perfil v5 preserva progresso e preferências existentes.

As poses foram produzidas antes da integração; os prompts exatos seguem abaixo. As referências são a pose de espera da própria identidade (alvo) e `portrait_zap.png`/`portrait_recover.png` (efeito de referência do cavaleiro antigo). Não houve edição dos pixels por scripts.

## cavaleira_zap

```text
Use case: identity-preserve / precise-object-edit.
Asset type: ONE transparent square 2D cartoon game animation sprite for Zap & Fry.
Image 1 is the EXACT EDIT TARGET and master alignment: Zefa, the same mature adult Black curvy woman knight, same silver/plum fitted armor and natural short curls.
Image 2 is ONLY a reference for the cartoon X-ray shock effect of the previous knight. Do NOT copy that knight's identity, armor, chair positioning or body.
Edit ONLY the occupant's expression and temporary X-ray shock appearance. Keep the SAME identity, costume, props, body silhouette, exact frontal seated pose, complete chair design, steel bars, hand/foot positions, cable connectors, head electrode, full square canvas and scale as Image 1. No camera shift, no new chair, no enlargement. Exactly two arms/hands naturally resting on corresponding armrests and two legs/feet resting on the platform.
ZAP POSE: show a CLEAR, funny ivory cartoon SKULL with big glowing cyan eye sockets, visible cyan/ivory ribs and cartoon bones through translucent X-ray areas of the existing costume, like Image 2. Keep recognizable headwear/hair silhouette and outer costume/props; do not replace the character with the old knight. Match the anatomy to this character's own body. Use a few small cyan electricity accents close to the silhouette, comfortably inside the existing margin. The skeleton must be readable at 160px tall. No flesh injury, no gore, no realistic anatomy, no nudity or explicit body detail. The chair stays solid wood/metal, not X-rayed. No opaque white flash covering the sprite.
Style: EXACTLY the hand-painted 2D cartoon with heavy clean dark outlines and brushed highlights of Image 1. NOT photoreal, NOT 3D, no actors or realistic skin.
Background: ACTUAL TRANSPARENT ALPHA. No room, floor, painted black, checkerboard, backdrop, cast shadow outside the chair, words, labels or logos.
Return one complete sprite with every chair foot and cable loop inside the image. Preserve pose registration for animation with Image 1.
```

## cavaleira_recover

```text
Use case: identity-preserve / precise-object-edit.
Asset type: ONE transparent square 2D cartoon game animation sprite for Zap & Fry.
Image 1 is the EXACT EDIT TARGET and master alignment: Zefa, the same mature adult Black curvy woman knight, same silver/plum fitted armor and natural short curls.
Image 2 is ONLY a reference for the comic recovery expression and small soot marks of the previous knight. Do NOT copy that knight's identity, armor, chair positioning or body.
Edit ONLY the occupant's expression and temporary recovery appearance. Keep the SAME identity, costume, props, body silhouette, exact frontal seated pose, complete chair design, steel bars, hand/foot positions, cable connectors, head electrode, full square canvas and scale as Image 1. No camera shift, no new chair, no enlargement. Exactly two arms/hands naturally resting on corresponding armrests and two legs/feet resting on the platform.
RECOVERY POSE: return to this SAME adult character's living face and original skin tone, with a dazed cross-eyed half-smile, two or three small cartoon soot smudges on cheeks, slightly frazzled hair while preserving its color and identity, and at most two small wisps of smoke INSIDE the current canvas margins. All clothes remain intact and opaque. No wounds, burns, blood, exposed anatomy or disappearing body. Do not change the costume, chair, hands or feet; no lightning or skeleton in this pose.
Style: EXACTLY the hand-painted 2D cartoon with heavy clean dark outlines and brushed highlights of Image 1. NOT photoreal, NOT 3D, no actors or realistic skin.
Background: ACTUAL TRANSPARENT ALPHA. No room, floor, painted black, checkerboard, backdrop, cast shadow outside the chair, words, labels or logos.
Return one complete sprite with every chair foot and cable loop inside the image. Preserve pose registration for animation with Image 1.
```

## pirata_zap

```text
Use case: identity-preserve / precise-object-edit.
Asset type: ONE transparent square 2D cartoon game animation sprite for Zap & Fry.
Image 1 is the EXACT EDIT TARGET and master alignment: the same adult freckled ginger-bearded pirate with navy tricorn, red scarf and teal coat.
Image 2 is ONLY a reference for the cartoon X-ray shock effect of the previous knight. Do NOT copy that knight's identity, armor, chair positioning or body.
Edit ONLY the occupant's expression and temporary X-ray shock appearance. Keep the SAME identity, costume, props, body silhouette, exact frontal seated pose, complete chair design, steel bars, hand/foot positions, cable connectors, head electrode, full square canvas and scale as Image 1. No camera shift, no new chair, no enlargement. Exactly two arms/hands naturally resting on corresponding armrests and two legs/feet resting on the platform.
ZAP POSE: show a CLEAR, funny ivory cartoon SKULL with big glowing cyan eye sockets, visible cyan/ivory ribs and cartoon bones through translucent X-ray areas of the existing costume, like Image 2. Keep recognizable headwear/hair silhouette and outer costume/props; do not replace the character with the old knight. Match the anatomy to this character's own body. Use a few small cyan electricity accents close to the silhouette, comfortably inside the existing margin. The skeleton must be readable at 160px tall. No flesh injury, no gore, no realistic anatomy, no nudity or explicit body detail. The chair stays solid wood/metal, not X-rayed. No opaque white flash covering the sprite.
Style: EXACTLY the hand-painted 2D cartoon with heavy clean dark outlines and brushed highlights of Image 1. NOT photoreal, NOT 3D, no actors or realistic skin.
Background: ACTUAL TRANSPARENT ALPHA. No room, floor, painted black, checkerboard, backdrop, cast shadow outside the chair, words, labels or logos.
Return one complete sprite with every chair foot and cable loop inside the image. Preserve pose registration for animation with Image 1.
```

## pirata_recover

```text
Use case: identity-preserve / precise-object-edit.
Asset type: ONE transparent square 2D cartoon game animation sprite for Zap & Fry.
Image 1 is the EXACT EDIT TARGET and master alignment: the same adult freckled ginger-bearded pirate with navy tricorn, red scarf and teal coat.
Image 2 is ONLY a reference for the comic recovery expression and small soot marks of the previous knight. Do NOT copy that knight's identity, armor, chair positioning or body.
Edit ONLY the occupant's expression and temporary recovery appearance. Keep the SAME identity, costume, props, body silhouette, exact frontal seated pose, complete chair design, steel bars, hand/foot positions, cable connectors, head electrode, full square canvas and scale as Image 1. No camera shift, no new chair, no enlargement. Exactly two arms/hands naturally resting on corresponding armrests and two legs/feet resting on the platform.
RECOVERY POSE: return to this SAME adult character's living face and original skin tone, with a dazed cross-eyed half-smile, two or three small cartoon soot smudges on cheeks, slightly frazzled hair while preserving its color and identity, and at most two small wisps of smoke INSIDE the current canvas margins. All clothes remain intact and opaque. No wounds, burns, blood, exposed anatomy or disappearing body. Do not change the costume, chair, hands or feet; no lightning or skeleton in this pose.
Style: EXACTLY the hand-painted 2D cartoon with heavy clean dark outlines and brushed highlights of Image 1. NOT photoreal, NOT 3D, no actors or realistic skin.
Background: ACTUAL TRANSPARENT ALPHA. No room, floor, painted black, checkerboard, backdrop, cast shadow outside the chair, words, labels or logos.
Return one complete sprite with every chair foot and cable loop inside the image. Preserve pose registration for animation with Image 1.
```

## alquimista_zap

```text
Use case: identity-preserve / precise-object-edit.
Asset type: ONE transparent square 2D cartoon game animation sprite for Zap & Fry.
Image 1 is the EXACT EDIT TARGET and master alignment: the same middle-aged adult green goblin woman alchemist, round build, copper glasses, curly auburn hair and violet/cream apron.
Image 2 is ONLY a reference for the cartoon X-ray shock effect of the previous knight. Do NOT copy that knight's identity, armor, chair positioning or body.
Edit ONLY the occupant's expression and temporary X-ray shock appearance. Keep the SAME identity, costume, props, body silhouette, exact frontal seated pose, complete chair design, steel bars, hand/foot positions, cable connectors, head electrode, full square canvas and scale as Image 1. No camera shift, no new chair, no enlargement. Exactly two arms/hands naturally resting on corresponding armrests and two legs/feet resting on the platform.
ZAP POSE: show a CLEAR, funny ivory cartoon SKULL with big glowing cyan eye sockets, visible cyan/ivory ribs and cartoon bones through translucent X-ray areas of the existing costume, like Image 2. Keep recognizable headwear/hair silhouette and outer costume/props; do not replace the character with the old knight. Match the anatomy to this character's own body. Use a few small cyan electricity accents close to the silhouette, comfortably inside the existing margin. The skeleton must be readable at 160px tall. No flesh injury, no gore, no realistic anatomy, no nudity or explicit body detail. The chair stays solid wood/metal, not X-rayed. No opaque white flash covering the sprite.
Style: EXACTLY the hand-painted 2D cartoon with heavy clean dark outlines and brushed highlights of Image 1. NOT photoreal, NOT 3D, no actors or realistic skin.
Background: ACTUAL TRANSPARENT ALPHA. No room, floor, painted black, checkerboard, backdrop, cast shadow outside the chair, words, labels or logos.
Return one complete sprite with every chair foot and cable loop inside the image. Preserve pose registration for animation with Image 1.
```

## alquimista_recover

```text
Use case: identity-preserve / precise-object-edit.
Asset type: ONE transparent square 2D cartoon game animation sprite for Zap & Fry.
Image 1 is the EXACT EDIT TARGET and master alignment: the same middle-aged adult green goblin woman alchemist, round build, copper glasses, curly auburn hair and violet/cream apron.
Image 2 is ONLY a reference for the comic recovery expression and small soot marks of the previous knight. Do NOT copy that knight's identity, armor, chair positioning or body.
Edit ONLY the occupant's expression and temporary recovery appearance. Keep the SAME identity, costume, props, body silhouette, exact frontal seated pose, complete chair design, steel bars, hand/foot positions, cable connectors, head electrode, full square canvas and scale as Image 1. No camera shift, no new chair, no enlargement. Exactly two arms/hands naturally resting on corresponding armrests and two legs/feet resting on the platform.
RECOVERY POSE: return to this SAME adult character's living face and original skin tone, with a dazed cross-eyed half-smile, two or three small cartoon soot smudges on cheeks, slightly frazzled hair while preserving its color and identity, and at most two small wisps of smoke INSIDE the current canvas margins. All clothes remain intact and opaque. No wounds, burns, blood, exposed anatomy or disappearing body. Do not change the costume, chair, hands or feet; no lightning or skeleton in this pose.
Style: EXACTLY the hand-painted 2D cartoon with heavy clean dark outlines and brushed highlights of Image 1. NOT photoreal, NOT 3D, no actors or realistic skin.
Background: ACTUAL TRANSPARENT ALPHA. No room, floor, painted black, checkerboard, backdrop, cast shadow outside the chair, words, labels or logos.
Return one complete sprite with every chair foot and cable loop inside the image. Preserve pose registration for animation with Image 1.
```

## bardo_zap

```text
Use case: identity-preserve / precise-object-edit.
Asset type: ONE transparent square 2D cartoon game animation sprite for Zap & Fry.
Image 1 is the EXACT EDIT TARGET and master alignment: the same adult olive-skinned androgynous bard with asymmetrical teal-streaked hair, plum/teal tunic and small lute on lap.
Image 2 is ONLY a reference for the cartoon X-ray shock effect of the previous knight. Do NOT copy that knight's identity, armor, chair positioning or body.
Edit ONLY the occupant's expression and temporary X-ray shock appearance. Keep the SAME identity, costume, props, body silhouette, exact frontal seated pose, complete chair design, steel bars, hand/foot positions, cable connectors, head electrode, full square canvas and scale as Image 1. No camera shift, no new chair, no enlargement. Exactly two arms/hands naturally resting on corresponding armrests and two legs/feet resting on the platform.
ZAP POSE: show a CLEAR, funny ivory cartoon SKULL with big glowing cyan eye sockets, visible cyan/ivory ribs and cartoon bones through translucent X-ray areas of the existing costume, like Image 2. Keep recognizable headwear/hair silhouette and outer costume/props; do not replace the character with the old knight. Match the anatomy to this character's own body. Use a few small cyan electricity accents close to the silhouette, comfortably inside the existing margin. The skeleton must be readable at 160px tall. No flesh injury, no gore, no realistic anatomy, no nudity or explicit body detail. The chair stays solid wood/metal, not X-rayed. No opaque white flash covering the sprite.
Style: EXACTLY the hand-painted 2D cartoon with heavy clean dark outlines and brushed highlights of Image 1. NOT photoreal, NOT 3D, no actors or realistic skin.
Background: ACTUAL TRANSPARENT ALPHA. No room, floor, painted black, checkerboard, backdrop, cast shadow outside the chair, words, labels or logos.
Return one complete sprite with every chair foot and cable loop inside the image. Preserve pose registration for animation with Image 1.
```

## bardo_recover

```text
Use case: identity-preserve / precise-object-edit.
Asset type: ONE transparent square 2D cartoon game animation sprite for Zap & Fry.
Image 1 is the EXACT EDIT TARGET and master alignment: the same adult olive-skinned androgynous bard with asymmetrical teal-streaked hair, plum/teal tunic and small lute on lap.
Image 2 is ONLY a reference for the comic recovery expression and small soot marks of the previous knight. Do NOT copy that knight's identity, armor, chair positioning or body.
Edit ONLY the occupant's expression and temporary recovery appearance. Keep the SAME identity, costume, props, body silhouette, exact frontal seated pose, complete chair design, steel bars, hand/foot positions, cable connectors, head electrode, full square canvas and scale as Image 1. No camera shift, no new chair, no enlargement. Exactly two arms/hands naturally resting on corresponding armrests and two legs/feet resting on the platform.
RECOVERY POSE: return to this SAME adult character's living face and original skin tone, with a dazed cross-eyed half-smile, two or three small cartoon soot smudges on cheeks, slightly frazzled hair while preserving its color and identity, and at most two small wisps of smoke INSIDE the current canvas margins. All clothes remain intact and opaque. No wounds, burns, blood, exposed anatomy or disappearing body. Do not change the costume, chair, hands or feet; no lightning or skeleton in this pose.
Style: EXACTLY the hand-painted 2D cartoon with heavy clean dark outlines and brushed highlights of Image 1. NOT photoreal, NOT 3D, no actors or realistic skin.
Background: ACTUAL TRANSPARENT ALPHA. No room, floor, painted black, checkerboard, backdrop, cast shadow outside the chair, words, labels or logos.
Return one complete sprite with every chair foot and cable loop inside the image. Preserve pose registration for animation with Image 1.
```

## vampiro_zap

```text
Use case: identity-preserve / precise-object-edit.
Asset type: ONE transparent square 2D cartoon game animation sprite for Zap & Fry.
Image 1 is the EXACT EDIT TARGET and master alignment: the same older adult gray-blue vampire bureaucrat with silver hair, mustache, reading glasses, burgundy suit and document folder.
Image 2 is ONLY a reference for the cartoon X-ray shock effect of the previous knight. Do NOT copy that knight's identity, armor, chair positioning or body.
Edit ONLY the occupant's expression and temporary X-ray shock appearance. Keep the SAME identity, costume, props, body silhouette, exact frontal seated pose, complete chair design, steel bars, hand/foot positions, cable connectors, head electrode, full square canvas and scale as Image 1. No camera shift, no new chair, no enlargement. Exactly two arms/hands naturally resting on corresponding armrests and two legs/feet resting on the platform.
ZAP POSE: show a CLEAR, funny ivory cartoon SKULL with big glowing cyan eye sockets, visible cyan/ivory ribs and cartoon bones through translucent X-ray areas of the existing costume, like Image 2. Keep recognizable headwear/hair silhouette and outer costume/props; do not replace the character with the old knight. Match the anatomy to this character's own body. Use a few small cyan electricity accents close to the silhouette, comfortably inside the existing margin. The skeleton must be readable at 160px tall. No flesh injury, no gore, no realistic anatomy, no nudity or explicit body detail. The chair stays solid wood/metal, not X-rayed. No opaque white flash covering the sprite.
Style: EXACTLY the hand-painted 2D cartoon with heavy clean dark outlines and brushed highlights of Image 1. NOT photoreal, NOT 3D, no actors or realistic skin.
Background: ACTUAL TRANSPARENT ALPHA. No room, floor, painted black, checkerboard, backdrop, cast shadow outside the chair, words, labels or logos.
Return one complete sprite with every chair foot and cable loop inside the image. Preserve pose registration for animation with Image 1.
```

## vampiro_recover

```text
Use case: identity-preserve / precise-object-edit.
Asset type: ONE transparent square 2D cartoon game animation sprite for Zap & Fry.
Image 1 is the EXACT EDIT TARGET and master alignment: the same older adult gray-blue vampire bureaucrat with silver hair, mustache, reading glasses, burgundy suit and document folder.
Image 2 is ONLY a reference for the comic recovery expression and small soot marks of the previous knight. Do NOT copy that knight's identity, armor, chair positioning or body.
Edit ONLY the occupant's expression and temporary recovery appearance. Keep the SAME identity, costume, props, body silhouette, exact frontal seated pose, complete chair design, steel bars, hand/foot positions, cable connectors, head electrode, full square canvas and scale as Image 1. No camera shift, no new chair, no enlargement. Exactly two arms/hands naturally resting on corresponding armrests and two legs/feet resting on the platform.
RECOVERY POSE: return to this SAME adult character's living face and original skin tone, with a dazed cross-eyed half-smile, two or three small cartoon soot smudges on cheeks, slightly frazzled hair while preserving its color and identity, and at most two small wisps of smoke INSIDE the current canvas margins. All clothes remain intact and opaque. No wounds, burns, blood, exposed anatomy or disappearing body. Do not change the costume, chair, hands or feet; no lightning or skeleton in this pose.
Style: EXACTLY the hand-painted 2D cartoon with heavy clean dark outlines and brushed highlights of Image 1. NOT photoreal, NOT 3D, no actors or realistic skin.
Background: ACTUAL TRANSPARENT ALPHA. No room, floor, painted black, checkerboard, backdrop, cast shadow outside the chair, words, labels or logos.
Return one complete sprite with every chair foot and cable loop inside the image. Preserve pose registration for animation with Image 1.
```



## Verificação e instalação

412 verificações específicas de personagens: poses realmente distintas, oito estados, importação transparente de até 512 px, esqueleto próprio também no modo suave, nomes, distribuição sem repetição e persistência. O fluxo completo passou com 39.204 verificações da engine, 41 testes Python, 730 estados de dicas, 3.306 verificações de efeitos e 48 de áudio. Os 15 PNGs de produção estão no APK e a auditoria confirmou 43 texturas PNG importadas no total.

APK 0.16.0/código 26 instalado no S20 FE, serial RXCT803C36D. Arquivo de perfil idêntico antes/depois da instalação, processo iniciado sem erros e permissão VIBRATE concedida. Evidência: `builds/android/install-20261105T052830777398Z/`. A captura de poses foi feita na engine com perfil isolado; não foram automatizadas partidas no celular.

Prancha: `builds/characters/poses.png`. Capturas individuais: `builds/characters/<id>-idle.png`, `-zap.png` e `-recover.png`. Reproduzir com Godot: `--path . --audio-driver Dummy --script res://tests/capture_characters.gd -- --test`.
