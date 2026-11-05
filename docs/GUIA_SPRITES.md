# Evolução da arte e dos sprites

O jogo usa um pacote visual Godot independente das fases e das regras. O pacote atual está em `assets/art/concept_v3.tres`; o pacote inicial `assets/art/default_art.tres` foi preservado; a propriedade **Art Pack** da raiz `ZapFry`, em `scenes/main.tscn`, define qual recurso será usado. Personagem e cadeira podem ser camadas distintas de `SpriteFrames`; o pacote v3 usa o campo opcional `Portrait` para uma composição de personagem e cadeira. Fios e fusível são `Texture2D`.

Para trocar o ocupante da cadeira na versão 0.12, usar o recurso independente `assets/characters/knight.tres` e o campo **Execution Character** da raiz da cena. Ele prevalece sobre o retrato/camadas legadas do pacote visual durante a partida. O operador usa `Engineer` do `Art Pack`. Procedimento completo em `OPERADOR_E_PERSONAGENS.md`.

## Substituir a arte em uma atualização

1. Duplicar `concept_v3.tres` no painel FileSystem do Godot, por exemplo como `assets/art/cartoon_v4.tres`. Manter o pacote anterior permite comparar versões.
2. Importar as novas imagens para uma pasta própria, por exemplo `assets/art/cartoon_v4/`. PNG com transparência, SVG e spritesheets com `AtlasTexture` são aceitos pelos recursos nativos usados aqui.
3. No Inspector do novo pacote, editar `Character` e `Chair` no editor de `SpriteFrames`: substituir imagens ou adicionar frames, ajustar velocidade e duração individual e manter os nomes das animações da tabela abaixo. Para atlas, selecionar as regiões no editor de SpriteFrames.
4. Atribuir as texturas de fios, estados energizados e fusível aos campos correspondentes. Cada textura pode ser trocada separadamente. Os campos opcionais `Room Background` e `Ui Background` controlam os fundos da sala e da tela inteira. Para usar o desenho geométrico, limpar o campo no Inspector; apagar um arquivo ainda referenciado exige corrigir essa referência antes de exportar.
5. Selecionar a raiz de `scenes/main.tscn`, atribuir o novo `.tres` em **Art Pack** e salvar a cena. Para editar somente a primeira versão, basta alterar os recursos já atribuídos em `default_art.tres`.
6. Executar `./tools/dev.ps1 test`, depois `./tools/dev.ps1 capture`, e conferir tela pequena, fios rotacionados, dicas, redução de flashes e conclusão. Exportar uma nova versão Android/Windows após essa revisão.

Os pacotes são incluídos na build. A troca chega ao jogador por uma atualização do aplicativo; não há download de arte nem dependência de rede.

## Animações e tempo

| Nome | Uso | Comportamento inicial |
| --- | --- | --- |
| `idle` | Menu e partida normal | Respiração discreta e piscada. |
| `worried` | Últimos 15 segundos | Expressão de tensão. |
| `anticipation` | Início do circuito fechado, de 0 a 0,40 s | Preparação para o zap. |
| `zap` | De 0,40 a 1,75 s | Esqueleto cartunesco e eletricidade. |
| `zap_soft` | Mesmo trecho com flashes suaves | Pose estável, sem alternância do esqueleto. |
| `recover` | De 1,75 a 2,40 s | Cabelo arrepiado e fumaça cartunesca. |
| `win` | Estado de vitória | Reação de conclusão. |
| `lose` | Fim do tempo | Alívio do personagem. |

As velocidades, loops e durações de frames vêm de `SpriteFrames`. Uma animação sem loop mantém seu último frame até mudar de estado. A sequência de resolução dura 2,40 s, controlada pelo jogo; substituir a arte não muda o momento da vitória, o relógio ou a pontuação.

Para criar mais poses dentro de um trecho, adicionar frames à animação existente e ajustar sua velocidade. Novos nomes de estados exigem ligação explícita na apresentação. Se uma animação estiver ausente ou vazia, o pacote procura `idle`; se também faltar, a camada usa desenho geométrico. Quando `zap_soft` faltar, a redução de flashes usa `idle` em vez de reproduzir `zap`.

## Canvas e alinhamento

- O conjunto inicial contém 18 SVGs próprios de 256×256 com fundo transparente. As fontes estão em `assets/art/starter/`.
- Personagem e cadeira devem compartilhar a mesma proporção e o mesmo alinhamento em todos os frames. O conjunto inicial usa a área central do canvas, com pés e base próximos de y=230 em 256. Para 512×512, duplicar essas coordenadas e margens.
- Exportar todos os frames com o canvas completo e transparência. Recortar cada pose com uma margem diferente causa deslocamentos aparentes entre os frames e as duas camadas.
- É possível aumentar a resolução mantendo a proporção e as margens. A sala preserva proporção e centraliza o canvas na área disponível.
- O texto da sala e os indicadores da interface continuam separados da imagem. Evitar textos embutidos no sprite, para manter legibilidade e permitir tradução.

## Conexões dos fios

Todas as texturas de fios devem ser quadradas e transparentes. O centro das conexões fica exatamente no centro da imagem; cada porta usada alcança o meio da borda correspondente. A orientação inicial é:

| Campo | Portas na rotação zero |
| --- | --- |
| `straight` / `straight_live` | Norte e sul. |
| `curve` / `curve_live` | Norte e leste. |
| `tee` / `tee_live` | Norte, leste e oeste. |
| `blocker` | Sem conexão; não gira. |

O desenho gira 90° no sentido horário junto com a orientação da peça. Os sprites energizados devem manter as mesmas portas da versão normal. O teste de arte confere a presença de pixels nas quatro bordas e a correspondência com o circuito nos quatro giros.

Os alvos de toque, as portas elétricas, os ícones de trava, a seta do tutorial, a marca verde de dica e os terminais IN/OUT são controlados pelo jogo. Eles não dependem da imagem. Um campo de textura ausente usa desenho geométrico para aquele tipo/estado; isso permite atualizar somente uma parte do pacote.

## Acabamento visual e sonoro

O pacote v2 usa 13 SVGs novos: nove poses do personagem, dois estados da cadeira, o laboratório e o fundo da interface. As sete texturas de fios/fusível continuam compartilhadas com o conjunto inicial. Os sprites refinados usam canvas 512×512 com o mesmo alinhamento do conjunto 256×256.

Antecipação, tremor, recuperação, arcos e fumaça são efeitos de apresentação em `room_view.gd`. A redução de flashes usa a pose suave e arcos estáveis. As partículas dos fios usam somente as células realmente energizadas e não mudam o circuito.

Os nove sons próprios em `assets/audio/` são WAV mono PCM16 a 22.050 Hz. Para substituí-los, manter os nomes e caminhos ou atualizar o mapa `SOUNDS` em `scripts/game_audio.gd`. `hum.wav` é um loop contínuo; os outros sons devem terminar suavemente. A interface e os resultados têm canais separados. Silêncio interrompe todos os canais imediatamente; menu, pausa e resultado interrompem o ambiente.

`tools/create_polish_assets.py` reproduz o pacote v2 e os sons e exige `--overwrite` para substituir arquivos existentes. Para versões artísticas futuras, criar novo pacote/pasta preserva os conjuntos anteriores.

## Fontes e manutenção

- `scripts/art_pack.gd`: formato do pacote, seleção de frames e ajuste de proporção.
- `scripts/room_view.gd`: apresentação da sala e fallback por camada.
- `scripts/board_view.gd`: apresentação dos fios, mantendo entrada e marcadores.
- `tests/art_pack_tests.gd`: animação, alinhamento, portas, substituição em tempo de execução e preservação da partida.
- `tools/create_starter_art.py`: autoria reproduzível da primeira versão. Por padrão recusa sobrescrever arquivos existentes. `--overwrite` reconstrói **somente a arte inicial** e substitui ajustes manuais dessa versão; usar outra pasta/pacote para evoluções.

Os testes de portas adaptam os pontos de amostragem à resolução da textura e também verificam o pacote atribuído à cena principal. A troca por imagens maiores não exige alterar o código. O pacote inicial continua sendo uma referência independente para comparação.

## Pacote dos conceitos v3

Os 15 PNGs de `assets/art/concept_v3/` foram derivados dos JPEGs originais com a ferramenta nativa de geração de imagens; os prompts estão em `CONCEITO_V3_ASSETS.md`. Os originais foram preservados. O Godot limita a resolução importada a 512 px para sprites, 1024 px para cenário e 256 px para botão; os arquivos fonte mantêm a resolução gerada.

- `Tile Background`: placa estática abaixo dos fios, sem girar com eles.
- `Live Color`: cor dos indicadores energizados, ciano neste pacote.
- `Portrait`: composição legada de personagem e cadeira com as mesmas oito animações. Quando existe um **Execution Character** selecionado, o seu retrato tem prioridade na partida. Quando atribuída, ocupa o lugar das duas camadas separadas. Os estados podem compartilhar imagens; o conjunto atual usa espera, esqueleto e recuperação.
- `Menu Portrait`: goblin e alavanca exibidos somente no menu. Sem essa textura, o menu usa o retrato normal.
- `Primary Button`: moldura vermelha em nove partes, mantendo rótulos, foco e estados nativos.
- `Restart Icon`: ícone do botão de reinício; ausente, usa o símbolo textual.

`tools/build_concept_pack.gd` monta o `.tres` usando recursos nativos `AtlasTexture` para recortar margens transparentes da placa, botão e ícone. Não modifica pixels dos PNGs. Executar com Godot após importar os arquivos. Manter o mesmo canvas em todas as poses do retrato; o modo suave usa a pose de espera para evitar alternância de esqueleto.

Os cadeados dourados, o ✓ da dica e as setas do treino são desenhados pelo jogo acima das imagens. Parafusos pintados na placa são decorativos. O feixe multicolorido representa uma única conexão: não há quatro circuitos independentes.

## Espessura e centralização das pontas

Na 0.11.1, as curvas e os T foram refeitos com entrelaçado semelhante à reta. Os quatro novos arquivos têm sufixo `_uniform.png`; o montador do pacote usa essas versões. As pontas ocupam cerca de 26% do tile (tolerância de dois pontos percentuais), com centro em 50% (tolerância de 1,5 ponto percentual). O teste lê a silhueta alfa nas bordas em todos os giros e estados; o contorno pintado e a importação permitem pequena variação. Portas e regras continuam independentes das cores dos cabos. Prompts: `CORRECAO_FIOS_UNIFORMES.md`.

Na 0.12, o campo `Engineer` do pacote visual usa oito estados de `SpriteFrames`: `anticipation` contém as três poses da chave a 7,5 fps, sem loop; `zap`, `zap_soft`, `recover` e `win` mantêm a chave abaixada. Os demais usam a chave levantada. Os campos do ocupante ficam em `ExecutionCharacter`, e os dois atores compartilham a leitura de frames e o tratamento do modo suave.

## Sala contínua — 0.12.1

`Game Background` define o fundo único da partida. Os dois atores usam o modo `embedded` de `RoomView` para desenhar somente os sprites e efeitos, sem cards, textos ou cenários individuais. Menu e seletor mantêm a apresentação anterior. `game_room.png` é a fonte do cenário, sem texto ou elementos interativos; o cabeçalho, medidor e rodapé são nativos. A composição usa o mesmo canvas 720×1600 e conserva a matriz 624×624. Fontes e prompt em `SALA_CONTINUA_UX.md`.

## Mangueiras externas — 0.12.2

`PowerCableView` usa curvas nativas e desenho em camadas para sombra, volume, anéis corrugados, conectores e abraçadeiras. Não há raster novo nem alteração dos PNGs. A geometria é reconstruída somente quando os pontos de conexão mudam. `BoardView.terminal_position` é compartilhado entre os terminais desenhados e as mangueiras, evitando divergência de posição em grades diferentes. Os encaixes dos personagens usam coordenadas normalizadas do canvas, ajustáveis em seus recursos. As mangueiras passam atrás da matriz e dos atores, sem capturar toque.

## Impacto visual — 0.13

O tremor desloca somente a textura da parede, com limite de 5 unidades na horizontal e 3 na vertical e amplitude decrescente. A margem de 8 unidades evita revelar bordas. Os três clarões têm opacidade máxima de 0,18 e centros separados por 0,50 s. São desenhados no pai, atrás dos atores e controles, sem modificar a opacidade dos sprites. No modo suave, a parede não treme e o brilho sobe/desce gradualmente até 0,07 de opacidade. O efeito começa com a descarga, após abaixar a chave, e termina antes da recuperação.
