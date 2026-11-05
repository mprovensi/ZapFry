# Menu com cadeira e fios — 0.14.5

Aplicada a opção **2 — Fiação caótica**, escolhida após a avaliação das quatro propostas. O PNG foi copiado sem redesenho de `test_sprites/menu_options/02-fiacao-caotica.png` para `assets/art/concept_v3/menu_chair_wires.png`; ambos têm SHA-256 `f59e51b0722a5767423257bc985cb939ed63f3122e12452cf0bca93708e5a03d`. Fonte transparente de 1312×1199; importação Godot limitada a 512 px, com proporção preservada.

Geração original pela ferramenta nativa `image_gen`. O prompt final da opção 2 e as quatro fontes de avaliação estão em [menu_options/README.md](../test_sprites/menu_options/README.md). A seleção não alterou os pixels do PNG gerado.

`ArtPack.menu_portrait` recebe a cadeira exclusiva do menu no montador `tools/build_concept_pack.gd`. O goblin continua usando seus próprios `SpriteFrames`; o ocupante da partida continua em `ExecutionCharacter`. O operador não usa mais a imagem do menu como fallback, impedindo que a cadeira apareça no lugar do goblin quando um pacote não fornece poses. Nesse caso permanece o indicador geométrico da chave.

## Correção do esqueleto

`portrait_zap.png` já estava disponível, mas o estado `zap_soft` do cavaleiro e do pacote Conceito v3 usava `portrait_idle.png`. Perfis com flashes suaves não mostravam o esqueleto. Ambos os recursos agora usam `portrait_zap.png` em `zap` e `zap_soft`. O modo suave continua reduzindo brilho/tremor; não remove mais a pose de choque. O montador mantém a mesma regra ao criar futuros recursos do cavaleiro.

Os testes verificam a textura do esqueleto durante toda a janela de choque, de 0,40 a 1,75 s, nos dois modos, além da visibilidade até o resultado aos 2,40 s. Não houve mudança em fases, dicas, duração, vibração ou dados do jogador.

Capturas: `builds/previews/01-menu.png`, `54-goblin-chair-zap.png` e `56-goblin-chair-soft-zap.png`. A revisão 0.14.5 foi instalada após autorização no Samsung A5 (SM-A520F): versão 23 conferida, processo ativo e aplicativo em primeiro plano, sem erros de inicialização. Progresso e preferências preservados.
