# Animações — 0.18.0

O Executor tem respiração discreta, piscada breve a cada 4,6 segundos e movimento de cabeça durante sua fala. Os cinco condenados reagem com um leve aceno durante a resposta. As expressões atuam na região da cabeça, preservando a cadeira, o gerador, as mãos, os pés e os pontos de conexão dos cabos.

Cada balão entra em 0,18 s, com deslocamento de 12 unidades e opacidade de 45% até 100%. O texto aparece inteiro e os controles aceitam toque imediatamente. As conversas continuam com exatamente duas falas. Pausa, Ajustes e segundo plano congelam a apresentação e a reação; avançar a fala reinicia a entrada para o próximo falante.

As três poses existentes da alavanca recebem uma mistura curta entre quadros, respeitando as durações do `SpriteFrames`. A antecipação e o tremor do retrato entram e saem gradualmente. A recuperação termina com uma acomodação amortecida. A sequência mantém 2,40 s, o choque entre 0,40 e 1,75 s e os efeitos/vibração configurados pelo jogador. Durante o choque, a deformação facial e a piscada ficam desativadas; o esqueleto permanece visível durante toda a janela.

## Recursos e manutenção

Nenhum PNG foi alterado. O material exclusivo de `CharacterPortrait` combina a recoloração já existente com as expressões e as transições de pose. As coordenadas são normalizadas: `ExecutionCharacter.face_region` define a cabeça; `ArtPack.engineer_face_region`, `engineer_left_eye` e `engineer_right_eye` definem cabeça e olhos do Executor. Ao substituir os sprites, conferir esses campos no Inspector. Os pacotes sem regiões cadastradas mantêm a imagem original sem deformação localizada.

`RoomView` calcula a expressão a partir do estado e do tempo fornecidos pela apresentação. `DialogueView` controla a entrada do balão e seu relógio; `Main` avança esse relógio somente enquanto a conversa está visível e indica quem fala. Nenhuma animação usa relógio independente ou modifica regras, soluções, save, pontuação ou cronômetro do puzzle.

## Provas e prévia

`tests/animation_tests.gd` cobre entrada, pausa, troca de falante, piscada, tempo das poses e preservação do esqueleto. A parte visual roda obrigatoriamente com OpenGL em `effects-test`, comparando pixels da cabeça, do corpo, do gerador e da cadeira nas cinco bases, com recoloração ativa.

Capturas locais em `builds/animations/`. A prévia de seis segundos pode ser reproduzida com Godot, usando `--path . --audio-driver Dummy --script res://tests/capture_animation.gd -- --test`; codificar os 180 PNGs a 30 FPS com FFmpeg gera `builds/animations/ZapFry-0.18.0-preview.mp4`. As capturas usam perfil isolado e não automatizam partidas no celular.

Estes testes comprovam comportamento e renderização. Fluidez percebida e desempenho precisam ser observados no aparelho; a prévia em 30 FPS é uma captura determinística da engine, não uma medição de FPS do celular.
