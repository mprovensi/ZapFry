# Próximo upgrade: condenados e conversas

**Data:** 5 de novembro de 2026.  
**Base:** Zap & Fry 0.15.0, Godot 4.7.2.  
**Status:** cinco bases, 15 poses e 25 nomes entregues na 0.16.0; paletas e diálogos na 0.17.0. A revisão 0.17.1 substitui o roteiro original de três falas por exatamente dois balões: Executor e condenado. Os 24 casos foram reescritos, a fonte das falas passou a 40 e cada base ganhou sua cor de balão. Esta revisão substitui o formato planejado abaixo; detalhes em [ENCONTROS_017.md](ENCONTROS_017.md).

## 1. Resultado esperado

Cada fase começa com um condenado sorteado e uma conversa curta com o goblin. A acusação é uma mesquinharia absurda, a defesa piora a situação e o goblin encerra com uma piada. Depois, o jogador resolve o painel normalmente.

Criar **cinco personagens visualmente diferentes**, com **cinco nomes/apelidos e quatro paletas de roupa por personagem**: 100 combinações de aparência e nome. As poses usam o mesmo estilo Cartoon 2D pintado da sala atual. Não serão cinco recolorações do cavaleiro existente.

Preparar **24 micro-histórias**, reutilizáveis entre fases e personagens compatíveis. A história e a aparência não alteram a solução, o tempo, as dicas ou a pontuação da fase.

## 2. Os cinco personagens-base

| Base | Identidade visual | Exemplos de nomes | Personalidade cômica |
| --- | --- | --- | --- |
| Cavaleira fanfarrona | Mulher adulta de pele escura, corpo curvilíneo com busto destacado conforme ajuste solicitado, armadura ajustada em prata/roxo e sobrancelhas expressivas. | Zefa do Trovão, Bia Escudo, Dora Aço, Nara Faísca, Tita Couraça. | Trata qualquer inconveniente como uma missão épica. |
| Pirata atrapalhado | Homem adulto de pele clara com sardas, corpo magro, barba desalinhada, lenço e chapéu amassado. | Capitão Biscoito, Zeca Maré, Bento Convés, Tito Âncora, Neco Sete Nós. | Inventa justificativas náuticas para pequenos furtos. |
| Alquimista goblin | Goblin adulta baixa, pele verde, cabelo crespo volumoso, óculos enormes e avental cheio de frascos. Silhueta distinta do engenheiro. | Dra. Fuzarca, Nina Borbulha, Rita Reagente, Teca Fumaça, Lila Caldeirão. | Chama toda confusão de experimento controlado. |
| Bardo dramático | Pessoa adulta não binária, pele oliva, cabelo assimétrico, roupa teatral e pequeno instrumento no colo. | Nico Mi Maior, Sol Serenata, Ari Refrão, Alex Bis, Dani Desafino. | Responde como se tudo fosse parte de um espetáculo. |
| Vampiro burocrata | Vampiro adulto de pele cinza-azulada, alto, cabelo grisalho, óculos, capa formal e pasta de documentos. | Conde Protocolo, Barão Carimbo, Dr. Recibo, Visconde Anexo, Sr. Firma. | Só admite uma acusação quando recebe o formulário correto. |

Os estereótipos são de fantasia, profissão e personalidade. Diversidade aparece em gênero, pele, cabelo, idade aparente adulta e formato de corpo. A identidade não será motivo da acusação ou da piada. Cada personagem terá falas compatíveis com seus nomes e formas de tratamento.

## 3. Produção dos sprites

### Conteúdo mínimo

- Cinco artes-base, todas sentadas na mesma cadeira e com mãos, pés e apoios alinhados.
- Três poses por base: **espera**, **choque com esqueleto** e **recuperação chamuscada cômica**. Total: **15 imagens de pose**, além das máscaras de cor necessárias.
- Oito estados do `SpriteFrames` atual continuam presentes: `idle`, `worried`, `anticipation`, `zap`, `zap_soft`, `recover`, `win` e `lose`.
- Na primeira entrega, espera pode atender `idle/worried/anticipation/lose`; recuperação atende `recover/win`; o choque atende `zap/zap_soft`. Movimento procedural existente fornece respiração, antecipação e recuperação.
- `zap_soft` também mostra o esqueleto. O modo suave modifica flashes e tremor, preservando o condenado visível.

### Consistência visual

Usar como referência a sala, o goblin e os retratos atuais em `assets/art/concept_v3/`. Fontes PNG transparentes, canvas quadrado consistente e importação de até 512 px, como no pacote atual. Não recortar cada pose com margens diferentes.

Manter a cadeira, o apoio dos pés e o ponto de entrada do cabo na mesma posição entre poses. A anatomia do esqueleto deve acompanhar a silhueta de cada personagem. Sem sangue ou ferimentos realistas.

**Escolha para esta entrega:** conservar retratos compostos de personagem com cadeira, compatíveis com `ExecutionCharacter`. Separar completamente cadeira e corpo poderá ser considerado quando houver necessidade de novas cadeiras; não é requisito deste upgrade.

As quatro paletas por base mudam **roupas e acessórios**, usando material nativo restrito ao retrato e máscara de cor. Não aplicar tintura global: pele, olhos, cadeira, metal e esqueleto devem manter suas cores. A máscara deve acompanhar cada pose; o material de uma instância não pode recolorir outro personagem por compartilhamento de recurso.

Guardar as fontes e os recursos em subpastas por personagem de `assets/characters/`. Conservar o cavaleiro atual como fallback durante a integração. Registrar prompts e imagens aprovadas junto à documentação da arte.

## 4. Sorteio e continuidade

1. Ao entrar em uma fase pela campanha ou pelo seletor, escolher personagem, nome, paleta e história.
2. Usar uma **lista embaralhada dos cinco personagens**: apresentar todos antes de começar outra rodada. A primeira escolha da nova rodada não pode repetir a última da rodada anterior.
3. Sortear nomes, paletas e histórias evitando a combinação recém-usada. As histórias terão indicação dos personagens com que combinam; casos genéricos servem para todos.
4. Sortear uma vez na entrada. Redesenhar a tela, pausar, abrir Ajustes ou tocar no tabuleiro nunca deve mudar o condenado.
5. **Reiniciar a tentativa mantém o mesmo condenado e história**, indo direto ao puzzle para facilitar uma nova tentativa. Uma nova entrada na fase pelo menu/seletor pode trazer outro encontro.
6. Avançar para a fase seguinte gera um novo encontro. O sorteio é independente da dificuldade e da solução do tabuleiro.
7. Salvar o encontro da fase atual, para fechar/reabrir o aplicativo não trocar o personagem de uma fase ainda pendente. Validar IDs ao carregar; se um asset deixar de existir em atualização futura, escolher uma alternativa válida sem perder o progresso.

O encontro guarda apenas IDs de personagem, nome, paleta e história, fase associada e se a introdução já foi concluída. Não é necessário salvar uma cópia das texturas ou do tabuleiro. A fila embaralhada pode continuar apenas durante a sessão; o encontro atual persistido impede a troca ao retomar.

## 5. Conversa em balões

**Fluxo:** fase carregada → acusação do goblin → resposta do condenado → comentário final do goblin → puzzle liberado.

- Três falas por história, aproximadamente 20–45 palavras no total. Exibir uma fala por vez, sem voz gravada nesta entrega.
- Balão com cauda apontando para quem fala, nome do falante e texto com quebra automática. O diálogo é desenhado na própria sala, sem voltar aos cards explicativos retirados anteriormente.
- Usar o espaço central da matriz durante a introdução. A matriz fica levemente escurecida e sem interação; rosto do goblin, rosto do condenado e identificação da fase continuam legíveis.
- **Toque para continuar** avança; **Pular** encerra imediatamente a conversa. Ambos com alvo de toque adequado em tela estreita. Teclado também pode avançar.
- A última fala termina com **Começar**, liberando a fase. Não há passagem automática por tempo: o jogador pode ler no próprio ritmo.
- O toque que fecha o último balão deve ser consumido, sem girar uma peça por acidente.
- Durante a conversa, o cronômetro não corre e dica/reinício não atuam sobre o painel. Após a introdução, manter a regra atual: o tempo começa na primeira jogada válida.
- Pausa, Ajustes e segundo plano preservam a fala atual. Retornar não deve pular balões ou liberar o painel antecipadamente.
- Na repetição imediata da tentativa, pular a introdução já vista; entrar novamente pela seleção de fases permite um novo encontro e uma nova introdução.

### Exemplos de histórias completas

**As paçocas**

> Goblin: “Você roubou as paçocas da minha irmã!”  
> Condenado: “Eu estava protegendo ela do açúcar.”  
> Goblin: “Então hoje vamos testar sua resistência.”

**A última coxinha**

> Goblin: “Comeu a última coxinha e deixou a caixa vazia!”  
> Condenado: “Deixei a caixa por educação.”  
> Goblin: “Que bom. Vou guardar seu recibo nela.”

**A senha do Wi-Fi**

> Goblin: “Você mudou a senha do Wi-Fi da fortaleza!”  
> Condenado: “A nova senha é ‘calma’.”  
> Goblin: “Não atende aos meus requisitos de segurança.”

**O solo interminável — bardo**

> Goblin: “Seu solo de flauta durou seis horas!”  
> Bardo: “Era só a introdução.”  
> Goblin: “Ótimo. Agora vem o encerramento.”

**O formulário — vampiro**

> Goblin: “Você cobrou taxa para devolver meu grampeador!”  
> Vampiro: “Faltou reconhecer firma.”  
> Goblin: “Reconheço. A firma é minha.”

### Banco inicial de 24 casos

| ID | Gancho para a história |
| --- | --- |
| 01 | Roubou as paçocas da irmã do goblin. |
| 02 | Comeu a última coxinha e deixou a caixa vazia. |
| 03 | Mudou a senha do Wi-Fi da fortaleza. |
| 04 | Fez um solo de flauta de seis horas. |
| 05 | Cobrou taxa para devolver o grampeador. |
| 06 | Devolveu um pote de sorvete cheio de feijão. |
| 07 | Escondeu o controle remoto dentro do caldeirão. |
| 08 | Vendeu ingresso para assistir à fila da cantina. |
| 09 | Pôs passas no banquete sem avisar. |
| 10 | Deu spoiler do final da novela dos goblins. |
| 11 | Levou o carregador e deixou só o cabo quebrado. |
| 12 | Trocou o açúcar pelo sal na cozinha. |
| 13 | Colou “puxe” em todas as portas de empurrar. |
| 14 | Usou o mapa do tesouro para embrulhar pastel. |
| 15 | Guardou meias no capacete cerimonial. |
| 16 | Ensinou o papagaio a imitar o alarme de incêndio. |
| 17 | Assombrou o banheiro na hora da limpeza. |
| 18 | Fez uma poção de invisibilidade só para a louça suja. |
| 19 | Vendeu uma espada lendária feita de papelão. |
| 20 | Deixou um áudio de sete minutos dizendo “ok”. |
| 21 | Alugou o fantasma da fortaleza para uma festa. |
| 22 | Comeu o recheio dos biscoitos e devolveu as metades. |
| 23 | Carimbou “negado” no pedido de férias do goblin. |
| 24 | Trocou os nomes dos frascos e perfumou a fortaleza com alho. |

Os IDs não correspondem ao número da fase. Na produção, escrever e revisar as três falas de todos os casos, indicando compatibilidade quando houver piada específica de um arquétipo.

## 6. Integração com o código existente

| Área | Alteração planejada |
| --- | --- |
| `scripts/execution_character.gd` e recursos em `assets/characters/` | Reutilizar `ExecutionCharacter`, `SpriteFrames` e `cable_anchor` para os cinco conjuntos. Acrescentar somente os dados visuais necessários às paletas. |
| Catálogo de encontros | Dados locais com IDs estáveis, nomes, paletas, falas e compatibilidade. Um pequeno seletor com RNG injetável para testes cuida da lista embaralhada. Sem serviço remoto ou gerenciador global. |
| `scripts/main.gd` | Sortear ao entrar na fase, atribuir `execution_character` e controlar a introdução. Reutilizar navegação de pausa/Ajustes. |
| `scripts/room_view.gd` e resultado | Aplicar aparência e nome selecionados de maneira consistente durante espera, choque, recuperação, vitória e derrota. Material de cor limitado ao retrato. |
| Balões | Um componente visual local com texto, falante, cauda, avanço e Pular. Não conhece regras, soluções ou pontuação. |
| `scripts/player_profile.gd` | Acrescentar o encontro atual com migração e validação. Manter gravação atômica, backup, recordes, desbloqueios e preferências da 0.15.0. |
| Exportação | Garantir inclusão do catálogo e dos recursos referenciados. Excluir rascunhos, fontes de revisão e testes dos pacotes finais. |

`GameSession` continua responsável pelo puzzle. A introdução mantém a sessão em `READY` e bloqueia entradas de partida na apresentação; não é necessário criar uma nova máquina de estados para as regras. Ao abrir a pausa, preservar também a posição no diálogo.

## 7. Ordem de execução

1. **Prévia dos cinco personagens:** gerar uma arte de espera por base e uma prancha comparativa na sala atual. Conferir distinção de silhuetas, proporções, inclusão e encaixe na cadeira.
2. **Completar a arte:** produzir as poses de choque/recuperação, máscaras, quatro paletas por base e os cinco recursos `ExecutionCharacter`. Conferir os dois modos de flashes.
3. **Catálogo e sorteio:** cadastrar nomes e encontros; implementar a lista embaralhada e a persistência do encontro atual.
4. **Roteiro e balões:** finalizar os 24 casos e integrar a introdução, Pular, retorno da pausa e acessibilidade dos controles.
5. **Validação:** executar testes automáticos, capturas em telas estreitas e revisão da sequência completa com cada base e paleta.
6. **Entrega:** exportar Android/Windows e conferir em celular conectado, mantendo o progresso existente.

Estimativa inicial: **5–8 dias de trabalho**, com maior incerteza na consistência das poses e máscaras geradas. A primeira entrega visual é a prancha com os cinco personagens; animação quadro a quadro detalhada fica para evolução posterior.

## 8. Critérios de aceite e testes

- Cinco silhuetas distintas, 25 nomes e 20 escolhas de paleta cadastradas; todos os IDs e textos válidos.
- Cada base tem as três poses e os oito estados, com esqueleto visível em `zap` e `zap_soft`.
- Paletas mudam somente os tecidos/acessórios; cadeira, pele e esqueleto permanecem consistentes. Testar que uma instância não altera outra.
- Todo grupo completo de cinco sorteios contém os cinco personagens, sem repetição na passagem entre grupos. Usar seeds fixas e casos de borda, sem testes probabilísticos instáveis.
- História sempre compatível com o personagem; nome e aparência permanecem iguais da introdução ao resultado.
- Reiniciar, pausar, abrir Ajustes e enviar ao segundo plano não sorteiam outro encontro nem consomem tempo de conversa.
- Salvar/reabrir conserva o encontro atual. Perfil antigo ou ID removido usa fallback sem perder recordes e preferências.
- Avançar/Pular funciona por toque e teclado; a última interação não gira fios, aciona dica ou dispara o choque.
- Todas as 24 histórias cabem nos balões em 360×800, 720×1280 e 720×1600. Casos com nomes longos também entram na revisão.
- Todas as 24 fases continuam solucionáveis e as dicas mantêm a validação atual. O sorteio não altera JSONs de fases, tempos ou pontuação.
- A sequência de execução mantém 2,40 s, esqueleto, flash e pulso de vibração conforme os Ajustes do jogador.

## 9. Limites desta entrega

Sem dublagem, geração de texto por IA durante a partida, seleção manual de condenados, coleção, raridades ou compras. Arte e diálogos são locais e funcionam offline. O menu mantém o sprite de cadeira e fios já escolhido; o goblin permanece o operador fixo.

Etapa 1 concluída: prévias dos cinco personagens geradas com a ferramenta nativa de imagens. A cavaleira foi ajustada conforme a preferência posterior por uma mulher adulta curvilínea e com busto destacado. Fontes e prompts exatos em [test_sprites/condemned_v1/README.md](../test_sprites/condemned_v1/README.md). Pranchas em `previews/prancha-personagens.png` e `previews/prancha-jogo.png`, dentro dessa pasta. Verificados alpha, margens e renderização no tamanho da partida, sem alterar o perfil real. A próxima etapa é produzir choque/recuperação mantendo cadeira, identidade e alinhamento de cada sprite.


## Entrega 0.16.0

Concluídas as poses de choque e recuperação das cinco bases e sua integração em recursos próprios. Nome aparece na sala, sem card explicativo. O conjunto de nomes tem 25 alternativas; as quatro paletas por base e os 24 diálogos serão implementados na etapa seguinte. Fonte e prompts em `CONDEMNED_POSES_016.md`; teste de sorteio/persistência e poses em `tests/character_roster_tests.gd`. Instalado APK 0.16.0/código 26 no S20 FE; 39.204 verificações da engine, 41 testes Python e as suítes de efeitos/áudio aprovados.
