# Encontros e paletas — 0.19.1

Cada nova fase apresenta exatamente dois balões: uma acusação do **Executor** e uma resposta curta do condenado. A 0.19.1 amplia o catálogo de 24 para 48 casos, sem terceira fala. Os casos anteriores permanecem nos mesmos IDs; os novos foram acrescentados ao final. Há restrições para manter histórias específicas compatíveis com seus personagens, incluindo raízes para a elfa, maçã para o zumbi e escudo para a cavaleira. A seleção evita repetir o último caso quando começa outro encontro, preservando os encontros já salvos.

O Executor usa verde; cavaleira rosa, pirata azul, alquimista lilás, bardo âmbar, vampiro vermelho, zumbi turquesa e elfa dourado. Cada `ExecutionCharacter` guarda sua cor em `dialogue_color`, independente da paleta de roupa e do nome sorteado. O balão tem papel claro tingido, contorno grosso e cauda curva integrada. A 0.19.1 remove os contadores de passos e destaca o nome em tarja colorida com texto claro, fonte 32 e negrito; a largura acompanha o nome sem cortar as 35 variações. As falas mantêm fonte 40 reforçada. O nome avulso ao lado da cadeira continua removido.

Toque, clique, Enter ou Espaço avançam uma fala; **Pular** termina a apresentação. A matriz e a dica ficam bloqueadas durante a conversa. O relógio começa somente na primeira jogada válida. Pausa, Ajustes e segundo plano preservam a fala atual; reiniciar uma tentativa dispensa a introdução já apresentada.

As sete bases têm quatro paletas de roupa cada, incluindo a original. Com os 35 nomes, são 140 combinações de nome e paleta. `character_portrait.gd` aplica um material exclusivo por retrato, com máscara SVG corporal e seleção de matiz; os PNGs originais permanecem intactos. Pele, cadeira e ossos brilhantes são preservados nas regiões verificadas pelo teste de pixels. A máscara e os limites de cor deverão ser revistos quando os sprites forem substituídos.

O perfil v6 grava personagem, nome, paleta, história e apresentação concluída. Perfis anteriores recebem a paleta original e uma história compatível, mantendo progresso e preferências. Os templates compartilhados não são alterados pelo sorteio. A aparência permanece igual no diálogo, partida e resultado.

## Validação

Conferência manual no aparelho: [ROTEIRO_ENCONTROS_017.md](ROTEIRO_ENCONTROS_017.md).

- Catálogo, combinações, compatibilidade, migração e persistência: `tests/encounter_tests.gd`.
- Interação nativa por mouse, toque e teclado; pausa, interrupção de gesto e prevenção de entrada duplicada ou vazamento para a matriz.
- As 96 falas cabem nos balões em 360×800, 720×1280 e 720×1600. Os testes verificam as 35 variações de nome na tarja, as cores dos oito falantes, a ausência de contadores, a compatibilidade dos casos específicos e o início da fase após o segundo balão sem entrada involuntária na matriz.
- Renderização das quatro paletas nas três poses das cinco bases, com comparação de pixels e isolamento dos materiais.
- O relógio real continua sendo usado em produção. Os testes controlam a fonte de tempo para que interrupções do computador não expirem fases artificialmente; há cobertura de desconto único, pausa e retomada.
- Exportação e instalação continuam sujeitas às três suítes obrigatórias de `tools/dev.ps1`; a auditoria do APK inclui a máscara importada.

Capturas reproduzíveis com o Godot e perfil isolado: `--path . --audio-driver Dummy --script res://tests/capture_encounters.gd -- --test`. Saída em `builds/encounters/`.

As fases, seus tempos, soluções, pontuação e o intervalo da descarga de 2,40 s não mudaram nesta etapa. Textos e paletas funcionam offline.
