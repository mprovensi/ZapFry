# Análise dos conceitos em test_sprites

Análise visual das duas imagens JPEG de 1536×2752, considerando o jogo atual e o pacote de arte substituível. Os originais foram preservados; esta análise não extrai ou integra imagens na build.

## Folha Cartoon_puzzle_game_UI_tiles

É a fonte mais adequada para começar um novo pacote visual. Os códigos abaixo são os impressos na própria imagem.

| Elemento | Células | Aproveitamento |
| --- | --- | --- |
| Fio reto normal | 1A, 1B | Usar uma orientação base e gerar as outras por rotação. 1B já apresenta norte/sul. |
| Fio reto energizado | 3A, 3B; alternativa 6A | Parear 1B com 3B, normalizando centro, escala e terminais. Separar o brilho do fundo. |
| Curva normal | 1C, 1D, 2A, 2B | Basta uma curva limpa; as demais orientações vêm da rotação. |
| Curva energizada | 3C, 3D, 4A, 4B | Preferir 4A/4B, que não têm seta de rotação embutida. 1D ou 2A podem formar o par normal correspondente; ambos precisam ser orientados para a convenção norte/leste do jogo. |
| Conexão em T normal | 5A, 5D | São três terminais: esquerda, direita e baixo. Normalizar para norte/leste/oeste. |
| Conexão em T energizada | Não há equivalente direto | Produzir uma versão de 5A/5D com exatamente três terminais e brilho. Uma cruz de quatro terminais não representa o T do jogo. |
| Placa de metal | 2D | Base de célula e referência de material. Usar como camada fixa, separada do fio que gira. |
| Soquete circular | 2C | Pode virar indicador de gerador/saída ou decoração de painel. O desenho sozinho não representa uma peça condutora entre bordas. |
| Fio rompido | 7A, 7B | Visual adequado ao fusível queimado/bloqueio; duas variantes podem servir de animação decorativa. Continuar sem conduzir energia. |
| Contatos interrompidos | 7C | Alternativa de bloqueio ou detalhe de manutenção. |
| Seta circular | 7D | Ícone de reinício/rotação, preparado como imagem transparente separada. |
| Peças de quatro terminais | 4C, 4D, 5B, 5C, 6B, 6C, 6D | Reservar para uma atualização de mecânica. Exigem definir conexão entre os quatro lados ou cruzamento isolado; não reutilizar como T. |

Há variações repetidas de orientação e brilho. Não é necessário transformar cada quadrado da folha em uma peça diferente. Um conjunto de reto/curva/T em estado normal e energizado, placa e bloqueio cobre a necessidade principal do puzzle atual.

## Conceito com goblin e cadeira

| Elemento | Onde aproveitar | Preparação |
| --- | --- | --- |
| Goblin engenheiro | Menu, apresentação ou personagem de apoio | Recortar com transparência. A alavanca passa junto ao braço/corpo; criar uma pose limpa e reconstruir partes ocultas se separar os objetos. Para animar, produzir outras poses. |
| Cavaleiro na cadeira | Sala de conclusão do puzzle | Boa expressão cômica para o cliente. Separar personagem, cadeira e cabos ou produzir uma composição própria para esse espaço. Simplificar a armadura e valorizar o rosto para leitura em miniatura. |
| Cadeira e capacete | Evolução da cadeira atual | Reconstruir partes encobertas pelo personagem. Preparar os estados desligado, antecipação, choque e recuperação. |
| Paredes, chapas, rebites e faixas de perigo | Fundo da sala e moldura do painel | Remover personagens, grade, textos e botões; reconstruir as áreas ocultas e preparar trechos repetíveis. |
| Tubulações e cabos grossos | Decoração das bordas e entrada/saída | Isolar em camadas para ajustar o layout aos diferentes tamanhos de tela. |
| Molduras digitais | Tempo e contador de giros | Aproveitar a moldura; remover números e textos impressos e manter valores desenhados pelo jogo. |
| Medidores analógicos | Indicador de carga | Separar moldura, mostrador e ponteiro, permitindo animação real. |
| Botões metálicos, pausa e engrenagem | Interface | Extrair os fundos/ícones. Manter rótulos nativos em português e preparar estados normal, pressionado e desabilitado. |

O goblin funciona melhor como engenheiro no menu; o cavaleiro pode ocupar a cadeira durante a partida. Exibir os dois na pequena sala atual reduziria a legibilidade. O goblin exigiria um espaço de apresentação próprio ou uma nova camada de personagem.

## Ajustes necessários antes de integrar

- **Transparência:** JPEG não guarda canal alfa. Recorte retangular inclui o fundo; personagens e fios precisam de máscaras/limpeza ou reconstrução antes de virar PNG transparente.
- **Separação de camadas:** a placa metálica deve ficar parada enquanto o fio gira. O jogo já separa lógica e arte, mas precisaria de um campo opcional para a textura de fundo da célula, pois hoje essa base é geométrica.
- **Portas e escala:** alinhar todos os centros e levar os terminais ao meio das bordas. Normal e energizado precisam manter a mesma posição. Recortar incluindo o brilho e depois normalizar o canvas, evitando cortar efeitos.
- **Folha versus atlas:** remover códigos de linha/coluna, linhas de grade e fundos entre peças. A folha é conceitual e não um atlas pronto para fatiamento automático.
- **Cores:** os quatro fios coloridos são um feixe decorativo. No modelo atual, uma peça representa uma conexão; as cores não criam circuitos independentes.
- **Efeitos e setas:** 3C/3D têm setas impressas. O tutorial deve continuar sendo uma camada independente. Usar brilho moderado no estado energizado e efeitos adicionais controlados pelo jogo, respeitando flashes suaves.
- **Interface real:** remover 01:25, MOVES:12, RESET, ACTIVATE, WARNING e OUTPUT quando extrair molduras. O relógio e os contadores continuam dinâmicos e em português.
- **Mecânica:** ACTIVATE é uma referência visual de botão. O jogo atual conclui automaticamente ao fechar o circuito; não é necessário introduzir confirmação manual.
- **Composição:** não usar a segunda imagem inteira como fundo de gameplay, pois ela já contém uma grade 4×4, valores fixos, personagem e controles que duplicariam a interface real e não acompanhariam grades 5×5/6×6.

## Ordem recomendada de aproveitamento

1. Placa metálica, reto e curva em dois estados, T normal e nova versão energizada, bloqueio e ícone de reinício.
2. Molduras de botões/medidores e trechos de parede, mantendo textos e números nativos.
3. Cavaleiro e cadeira como sprites limpos, com canvas e poses compatíveis com a sala.
4. Goblin para uma composição própria no menu ou como personagem de apoio.

Criar um pacote separado, por exemplo `assets/art/concept_v3.tres`, preservando `cartoon_v2.tres`. Validar sobretudo as portas dos fios, a legibilidade em 6×6 e a equivalência entre estados normal/energizado. A integração deve manter as 24 fases e a progressão existentes.

## Integração realizada — 0.11

A proposta foi aplicada em `assets/art/concept_v3.tres`: 15 PNGs derivados das referências, sem alterar os JPEGs originais. Inclui placa estática, reto/curva/T em dois estados, bloqueio, reinício, botão, laboratório, goblin no menu e cavaleiro/cadeira com espera, zap e recuperação. Foi criado um T energizado de três portas; a cruz de quatro portas não foi introduzida. Textos e números permanecem dinâmicos e em português.

Prompts e fontes: `CONCEITO_V3_ASSETS.md`. Fluxo de manutenção: `GUIA_SPRITES.md`. A campanha, os tempos e as dicas permanecem os mesmos.
