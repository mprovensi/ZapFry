# Presidiário — arte e integração

Arquétipo solicitado: presidiário louco. Identidade principal: Dito Pavio. Arte produzida com a ferramenta nativa `image_gen`, com transparência real; sem edição de pixels por scripts. Fontes em `assets/characters/presidiario/`, importação limitada a 512 px. O recurso reutiliza `ExecutionCharacter`, os oito estados, o shader de paletas e a máscara de roupa existentes.

A cadeira e o enquadramento da espera do pirata servem como referência de alinhamento e estilo. Choque e recuperação derivam da espera do próprio presidiário. O choque do pirata serve apenas como referência do efeito de esqueleto. Os sprites finais devem ser conferidos na engine com as quatro paletas.

## idle.png

Referências: assets/characters/pirata/idle.png.

```text
Use case: stylized-concept / precise-object-edit. Asset: ONE square transparent game sprite for Zap & Fry. Reference image is the alignment and style master: assets/characters/pirata/idle.png. Replace ONLY the pirate occupant with a NEW adult male eccentric fantasy prisoner, thin angular build, warm olive skin, unruly short black hair sticking out to the sides under the electrode, very expressive uneven eyebrows, wide mischievous grin and large comically alert eyes. Prison uniform of dark muted PURPLE and ivory broad horizontal stripes, matching pants, simple dark leather shoes. No hat, beard, pirate accessories, weapons, number patches, text or props. The comic personality is a compulsive inventor of absurd escape plans, not a real medical diagnosis. KEEP EXACT SAME chair, metal chest bar, electrode helmet, hand rests, feet platform, bottom feet, cable loops, scale, image margins, straight-on seated pose and body registration of reference. Two hands on armrests and two feet on platform. Entire sprite fits inside canvas. Hand-painted polished cartoon 2D, heavy dark outlines, brushed highlights, matching reference. Clothes opaque and intact; no gore or injuries. Background genuinely transparent alpha, no scene, floor, cast shadow outside chair, lettering, checkerboard or watermark. Output one complete idle pose only.
```

## zap.png

Referências: assets/characters/presidiario/idle.png; assets/characters/pirata/zap.png.

```text
Use case: identity-preserve / precise-object-edit. ONE square transparent cartoon game sprite. Image 1 (presidiario/idle.png) is exact edit target, identity and registration master. Image 2 (pirata/zap.png) is ONLY a reference for the funny X-ray skeleton effect; do not copy pirate face, costume or hat. Change ONLY the prisoner's temporary shock appearance: clearly readable ivory cartoon skull with bright cyan eye sockets and goofy startled mouth, visible cyan/ivory ribs and arm/leg/hand bones through translucent regions of the SAME purple/ivory striped uniform. Keep this SAME thin adult prisoner, wild black hair silhouette, same opaque outer costume silhouette, shoes, seated body registration, exact chair design and position, steel bars, hands and feet positions, cable loops, helmet, full square canvas and margins. At most a few small cyan sparks close to silhouette, all inside canvas. Chair remains solid wood/metal and unchanged, no X-ray on chair. Match polished hand-painted 2D cartoon thick dark outlines. No opaque flash, no flesh injury, gore, realistic anatomy or nudity. Genuine transparent alpha, no backdrop, checkerboard, floor, text or watermark. Output only complete shock pose.
```

## recover.png

Referências: assets/characters/presidiario/idle.png.

```text
undefined
```
