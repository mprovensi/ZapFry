# Zumbi e elfa — prompts e integração

Geração pela ferramenta nativa `image_gen`, com transparência real. Referência: `assets/characters/cavaleira/idle.png`. As novas imagens são variantes independentes; a cavaleira não é substituída. Prompts completos abaixo.

## Entrega 0.19.0

Seis PNGs em `assets/characters/zumbi/` e `assets/characters/elfa/`: `idle.png`, `zap.png` e `recover.png`. Fontes preservadas, importação limitada a 512 px. Recursos `zumbi.tres` e `elfa.tres` têm os mesmos oito estados das bases anteriores, cinco nomes por base, quatro paletas, cor própria do balão e entrada do cabo normalizada. O zumbi tem pele azul-esverdeada e roupa remendada; a elfa é adulta, esguia, ruiva e de busto volumoso, com traje opaco. Choque e recuperação mantêm identidade, roupa e cadeira, sem conteúdo gráfico.

O sorteio passa a sete bases sem repetição imediata, com 35 nomes e 140 combinações de nome/paleta. O perfil v6 e os IDs anteriores são preservados. A auditoria do APK verifica automaticamente todos os PNGs novos e suas texturas compiladas. Testes de poses, sorteio, paletas, esqueleto, animações e leitura incluem as novas bases.

Os balões agora usam `StyleBoxFlat` arredondado, papel claro, contorno de seis unidades e cauda Bézier desenhada sobre a borda, sem linha atravessando a junção. A cor de cada base aparece no tingimento do papel e no nome. A fonte de 40 unidades recebeu peso adicional. Foram mantidas duas falas, entrada animada, pausa, Pular e proteção contra toque vazando para a matriz. O nome no canto esquerdo da cadeira foi removido da árvore da interface.


## Ferramenta e referências

Ferramenta nativa `image_gen`, modo de edição/variante com alpha transparente. PNGs finais em `assets/characters/zumbi/` e `assets/characters/elfa/`. A arte de espera foi derivada do enquadramento da cavaleira; choque e recuperação usam a própria espera de cada novo personagem como referência.

## zumbi — espera

```text
Use case: precise-object-edit. Asset type: transparent 2D cartoon game sprite, one complete electric chair and its seated occupant. Image 1 is the source layout/style/chair reference. Create a NEW sibling character sprite by replacing ONLY the occupant. Preserve the reference's exact front three-quarter view, chair silhouette, chair feet, head electrode cap and cable loops, hand and foot positions, outline weight and hand-painted brushed highlights. Keep the same canvas registration and generous transparent margins. Whole chair fully inside frame. Comic villain game, cheerful macabre humor, NOT realistic. Idle living character, NO shock, no lightning, no smoke. TRUE transparent alpha background; no room, floor, solid backdrop, checkerboard, text, logo, extra objects or cast shadow outside the chair. The silhouette must remain clearly readable when imported down to 512 px. Occupant: an unmistakably ADULT male cartoon zombie, lanky, blue-green skin, heavy-lidded yellow eyes, crooked humorous grin with one missing tooth, messy dark hair. Wears an opaque worn PURPLE work shirt with rolled sleeves and dark trousers and boots. A few stitched fabric patches, all skin intact: NO blood, wounds, exposed organs, exposed bones, decay or gore. Both hands rest on the chair arms exactly as in Image 1, legs aligned with reference. Expressive goofy face, not frightening.
```

## elfa — espera

```text
Use case: precise-object-edit. Asset type: transparent 2D cartoon game sprite, one complete electric chair and its seated occupant. Image 1 is the source layout/style/chair reference. Create a NEW sibling character sprite by replacing ONLY the occupant. Preserve the reference's exact front three-quarter view, chair silhouette, chair feet, head electrode cap and cable loops, hand and foot positions, outline weight and hand-painted brushed highlights. Keep the same canvas registration and generous transparent margins. Whole chair fully inside frame. Comic villain game, cheerful macabre humor, NOT realistic. Idle living character, NO shock, no lightning, no smoke. TRUE transparent alpha background; no room, floor, solid backdrop, checkerboard, text, logo, extra objects or cast shadow outside the chair. The silhouette must remain clearly readable when imported down to 512 px. Occupant: unmistakably ADULT fantasy elf woman, around 30 years old, slim waist and slender arms and legs with a FULL, VOLUMINOUS BUST, long pointed ears, long copper-red hair and confident amused expression. Elegant dark PLUM and GOLD fantasy tunic with a fitted opaque bodice/corset and fitted trousers, practical brown boots. Bust has clearly prominent volume while all breasts and nipples are fully covered by opaque clothing; tasteful neckline, no nudity, no lingerie, no sexual pose. Both hands rest on the chair arms exactly as in Image 1. Keep electrode cap, seated registration and face placement matching the reference. Same richly outlined game cartoon style as Image 1.
```

## zap — aplicar separadamente a zumbi e elfa

```text
Use case: identity-preserve / precise-object-edit. Image 1 is the exact edit target, a production idle game sprite. Produce one transparent animation pose for that SAME occupant and SAME chair. Lock the EXACT canvas size, chair, chair feet, cable loops, camera, limbs, clothing silhouette, hair color, identity and every hand/foot position. No zoom, crop, rearrangement or perspective changes. Keep opaque clothes intact and the same bold hand-painted 2D cartoon style. TRUE TRANSPARENT ALPHA background; no room, floor, backdrop, checkerboard, words or logos. ZAP POSE: a comic electrical X-RAY effect, not injury: replace the living face with a bright cyan/cream cartoon skull, same head position, with goofy huge round glowing eyes and a funny startled jaw. Bright cream/cyan skeleton ribs, forearm bones, fingers and shin bones should be clearly visible as a glowing X-ray OVER the intact opaque costume, retaining its original plum/purple/gold colors and every costume panel. Preserve this character's hair and ears silhouette. Keep the head electrode cap and metal restraint bars opaque and unchanged. A few small yellow/cyan cartoon lightning zigzags stay close to the shoulders and cap, INSIDE original canvas margins. No realistic anatomy, gore, blood, wounds, fire, nudity or burns.
```

## recover — aplicar separadamente a zumbi e elfa

```text
Use case: identity-preserve / precise-object-edit. Image 1 is the exact edit target, a production idle game sprite. Produce one transparent animation pose for that SAME occupant and SAME chair. Lock the EXACT canvas size, chair, chair feet, cable loops, camera, limbs, clothing silhouette, hair color, identity and every hand/foot position. No zoom, crop, rearrangement or perspective changes. Keep opaque clothes intact and the same bold hand-painted 2D cartoon style. TRUE TRANSPARENT ALPHA background; no room, floor, backdrop, checkerboard, words or logos. RECOVERY POSE: return to this SAME character's original living face and original skin tone (the zombie stays blue-green and undead, the elf stays an adult elf). Give a dazed cross-eyed half-smile, two or three tiny cartoon soot smudges on cheeks, slightly frazzled hair preserving color, and at most two small smoke wisps INSIDE the original canvas margins. All clothes intact and opaque. No wounds, blood, exposed anatomy, realistic burns, skeleton or lightning. Chair, hands, feet and clothing pose stay exactly registered with Image 1.
```

