# Encontros e paletas — 0.17.0

Cada nova fase apresenta uma conversa curta em três balões entre o goblin e o condenado. Há 24 casos locais, incluindo o roubo das paçocas da irmã, e restrições para manter histórias específicas compatíveis com seus personagens. A seleção evita repetir o último caso quando começa outro encontro.

Toque, clique, Enter ou Espaço avançam uma fala; **Pular** termina a apresentação. A matriz e a dica ficam bloqueadas durante a conversa. O relógio começa somente na primeira jogada válida. Pausa, Ajustes e segundo plano preservam a fala atual; reiniciar uma tentativa dispensa a introdução já apresentada.

As cinco bases têm quatro paletas de roupa cada, incluindo a original. Com os 25 nomes, são 100 combinações de nome e paleta. `character_portrait.gd` aplica um material exclusivo por retrato, com máscara SVG corporal e seleção de matiz; os PNGs originais permanecem intactos. Pele, cadeira e ossos brilhantes são preservados nas regiões verificadas pelo teste de pixels. A máscara e os limites de cor deverão ser revistos quando os sprites forem substituídos.

O perfil v6 grava personagem, nome, paleta, história e apresentação concluída. Perfis anteriores recebem a paleta original e uma história compatível, mantendo progresso e preferências. Os templates compartilhados não são alterados pelo sorteio. A aparência permanece igual no diálogo, partida e resultado.

## Validação

Conferência manual no aparelho: [ROTEIRO_ENCONTROS_017.md](ROTEIRO_ENCONTROS_017.md).

- Catálogo, combinações, compatibilidade, migração e persistência: `tests/encounter_tests.gd`.
- Interação nativa por mouse, toque e teclado; pausa, interrupção de gesto e prevenção de entrada duplicada ou vazamento para a matriz.
- As 72 falas cabem nos balões em 360×800, 720×1280 e 720×1600.
- Renderização das quatro paletas nas três poses das cinco bases, com comparação de pixels e isolamento dos materiais.
- O relógio real continua sendo usado em produção. Os testes controlam a fonte de tempo para que interrupções do computador não expirem fases artificialmente; há cobertura de desconto único, pausa e retomada.
- Exportação e instalação continuam sujeitas às três suítes obrigatórias de `tools/dev.ps1`; a auditoria do APK inclui a máscara importada.

Capturas reproduzíveis com o Godot e perfil isolado: `--path . --audio-driver Dummy --script res://tests/capture_encounters.gd -- --test`. Saída em `builds/encounters/`.

As fases, seus tempos, soluções, pontuação e o intervalo da descarga de 2,40 s não mudaram nesta etapa. Textos e paletas funcionam offline.
