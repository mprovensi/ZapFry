# Zap & Fry — Plano de desenvolvimento

**Data:** 4 de novembro de 2026  
**Status:** protótipo 0.19.2 implementado, com sete condenados incluindo zumbi e elfa, balões de quadrinhos e identificação somente no diálogo, com piscada e reações dos atores, transições suaves e 48 histórias com dois balões e nome em negrito sem fundo próprio, sem contador de passos (Executor e condenado), quatro paletas por base, 140 combinações de nome/cor e perfil v6, com ajustes independentes de música, efeitos, vibração e flashes acessíveis pelo menu e pela pausa:  campanha de 24 fases com dicas contextuais validadas, progressão persistente, sprites substituíveis, sala contínua com goblin/chave e ocupante independente, menu e resultado simplificados. Ícone próprio, alavanca e mão corrigidas, pisos de largura total e trilha original de mansão assombrada a 120 BPM. Começar de novo volta ao menu e à fase 1, preservando conquistas. Inclui flashes suaves, execução de 2,40 s e vibração física confirmada no aparelho. As fases 11–24 mantêm a calibração do playtest. Restam playtest externo, medição em outros aparelhos e preparação da publicação; monetização permanece opcional e desativada.
**Plataforma inicial:** Android / Google Play  
**Prazo de produção:** três semanas, equivalentes a 15 dias úteis  
**Premissa de capacidade:** um desenvolvedor com experiência em jogos 2D, seis horas produtivas por dia, totalizando 90 horas. Arte e áudio devem usar um conjunto pequeno de recursos próprios ou licenciados. O prazo depende dessa disponibilidade.

## 1. Visão do produto

**Nome de trabalho:** Zap & Fry. **Alternativa:** Current Execution: Electric Grid. Verificar disponibilidade comercial e conflitos de marca antes de fixar o nome público.

Puzzle de rotação de fios, com partidas curtas e humor negro em Cartoon 2D estilizado, com personagens expressivos e animações exageradas. O jogador é o engenheiro elétrico de uma fortaleza de vilões e precisa reorganizar um painel para levar energia do gerador à cadeira elétrica antes que o temporizador termine.

A fantasia de vilania aparece na ambientação, nos textos e no desfecho. O desafio é espacial: identificar conexões e girar peças com poucos toques. Não haverá simulação realista de eletricidade ou de lesões.

**Pilares de experiência:**

- Entender o comando de rotação nos primeiros segundos.
- Ler claramente quais fios recebem energia e quais continuam desconectados.
- Resolver fases em aproximadamente 30 a 120 segundos, conforme a dificuldade.
- Receber uma conclusão cômica e rápida, com personalidade suficiente para incentivar a próxima fase.
- Jogar toda a campanha sem pagar ou assistir a anúncios.

**Público pretendido:** adolescentes mais velhos e adultos interessados em puzzles e humor macabro. A classificação indicativa efetiva dependerá do conteúdo final e do questionário da loja; não presumir classificação livre nem apresentar o produto como infantil.

## 2. Escopo da primeira versão

### Entrega obrigatória

- Três telas principais: menu, puzzle e resultado.
- Campanha de 24 fases autorais: oito 4×4, oito 5×5 e oito 6×6.
- Fios retos, curvas em L, conexões em T, fios fixos e fusíveis queimados.
- Gerador e terminal da cadeira fixos, rotação por toque e avaliação automática das conexões.
- Temporizador, pausa, reinício e tutorial integrado às três primeiras fases.
- Uma animação de conclusão, uma reação de derrota e efeitos de energia.
- Pontuação, estrelas, desbloqueio de fases e persistência local.
- Controles de música, efeitos e redução de flashes.
- Uma dica gratuita na apresentação da mecânica e dicas opcionais por anúncio recompensado.
- Build Android assinada e materiais necessários para iniciar testes na Play Console.

### Após a primeira versão

- Loja e compras de skins de cadeira e cores de raio.
- Mais personagens, animações e pacotes de fases.
- Modo sem tempo, desafios diários e localização para outros idiomas.
- Geração procedural, ranking e salvamento em nuvem, somente se houver demanda.

**Fora do orçamento inicial:** backend, contas de usuário, multiplayer, física elétrica, editor visual próprio, banners, intersticiais e campanha narrativa com diálogos extensos. As configurações e o seletor de fases serão painéis do menu, sem ampliar o número de telas principais.

## 3. Regras do puzzle

### Representação das peças

Cada célula guarda tipo, orientação em passos de 90°, possibilidade de rotação e conexões nas direções norte, leste, sul e oeste. As conexões podem ser representadas por uma máscara de quatro bits.

| Componente | Comportamento |
| --- | --- |
| Fio reto | Liga duas direções opostas; tem duas orientações distintas. |
| Curva em L | Liga duas direções adjacentes; tem quatro orientações. |
| Conexão em T | Liga três direções e permite ramificações. |
| Fio fixo | Conduz normalmente, mas não gira; possui marca visual de trava. |
| Fusível queimado | Ocupa a célula e bloqueia a passagem de energia; não gira. |
| Gerador e saída | Terminais fixos com portas de entrada/saída definidas na fase. |

No MVP, o fusível queimado é um obstáculo permanente. Não haverá conserto, consumo de fusíveis ou explosão por erro.

### Conectividade e vitória

1. Um toque válido gira uma peça móvel 90° no sentido horário.
2. Duas células vizinhas se conectam apenas quando possuem portas voltadas uma para a outra.
3. Após cada jogada, uma busca em largura ou profundidade identifica todas as células alcançáveis a partir do gerador.
4. Essas células acendem; ramificações abertas não causam derrota nem desligam um caminho válido.
5. A vitória ocorre quando a busca alcança a porta correta do terminal da cadeira, com tempo restante positivo.
6. Qualquer solução válida é aceita. Não é necessário energizar todo o tabuleiro, usar todos os fios ou reproduzir a solução autoral.

Essa regra resolve a ambiguidade das peças em T e mantém o desafio simples. O efeito visual de corrente é uma representação de conectividade do jogo, não um modelo de circuito físico.

### Tempo e estados

- O relógio começa após a instrução inicial da fase e o primeiro toque de jogo.
- Estados previstos: `READY`, `PLAYING`, `PAUSED`, `AD_PENDING`, `RESOLVING`, `WON` e `LOST`.
- Pausa, aplicativo em segundo plano e anúncio suspendem relógio e interação. Um painel cobre a grade durante a pausa.
- Ao receber um toque, atualizar primeiro o tempo. Se já terminou, registrar derrota; caso contrário, aplicar a rotação e avaliar vitória.
- Ao concluir, congelar o tempo, bloquear novos comandos e tocar a animação apenas uma vez.
- Fim do tempo mostra falha elétrica e reação cômica, seguido de opção gratuita de tentar novamente.
- Reiniciar restaura o embaralhamento inicial autoral da fase. Sair de uma tentativa exige apenas voltar ao menu; o MVP não retoma partidas interrompidas após fechar o processo.

### Pontuação e progressão

**Proposta inicial:** `pontuação = 1.000 + floor(1.000 × tempo_restante / tempo_limite)`. Limitar a razão ao intervalo de zero a um. Derrota não gera pontuação.

- Uma estrela: concluir a fase.
- Duas estrelas: concluir com pelo menos 25% do tempo restante.
- Três estrelas: concluir com pelo menos 50% do tempo restante.
- Dicas não impedem concluir ou desbloquear a fase seguinte; registrar seu uso localmente para avaliar balanceamento.
- Salvar a melhor pontuação e o maior número de estrelas de cada fase, além da fase mais avançada desbloqueada.
- Não comparar placares online no MVP. Os valores e limiares são hipóteses para playtest.

## 4. Campanha e dificuldade

| Fases | Grade | Conteúdo | Tempo inicial sugerido |
| --- | --- | --- | --- |
| 1–3 | 4×4 | Tutorial com seta: um, dois e quatro toques na solução de referência, sem distrações ou pressão de tempo. | Sem limite |
| 4–8 | 4×4 | Retirar a seta nas fases 4–5; apresentar T com ajuda na 6, fusível na 7 e combinar os dois na 8. Mínimos de 6/8/8/9/10 toques. | 180 s, exceto fase 5: 150 s |
| 9–16 | 5×5 | Fase 9 guiada e livre; fase 10 introduz painel cheio. Fases 11–16 têm seis distrações, T e fusíveis; mínimos de 14/16/18/20/22/24 giros. | 9 livre; 10: 150 s; 11–16: 180 s |
| 17–24 | 6×6 | Continuação do desafio, oito distrações e dois fusíveis por painel; mínimos de 26/28/30/32/34/36/38/40 giros. | 17–20: 210 s; 21–24: 225 s |

Os tempos são parâmetros por fase e devem ser ajustados por observação. Não presumir que uma grade maior precise de menos tempo para ser difícil.

**Processo de autoria:** construir primeiro uma configuração solucionada, salvar uma solução de referência, adicionar distrações e embaralhar apenas peças móveis. Validar que a solução alcança a saída e que o tabuleiro inicial não está resolvido. Fios fixos permanecem compatíveis com pelo menos uma solução.

Priorizar legibilidade sobre quantidade de obstáculos. As primeiras fases apresentam uma regra por vez. A fase 10 apresenta o painel cheio; 11–16 mantêm seis fios fora da rota de referência e 17–24 mantêm oito, após calibração por playtest. A orientação de tutorial deixa de aparecer; a fase 17 mantém o desafio ao aumentar a grade. Separar testes de compreensão, velocidade e dificuldade para evitar atribuir problemas de interface ao jogador.

## 5. Telas e navegação

| Tela | Elementos | Ações e transições |
| --- | --- | --- |
| Menu principal | Logo com animação discreta, “Iniciar Execução”, “Fases” e configurações. | Continuar na primeira fase não concluída; selecionar fases desbloqueadas; alterar áudio, flashes e privacidade. |
| Puzzle | Voltímetro com tempo numérico, nível, pausa, grade, indicador de circuito e miniatura da cadeira. | Girar fios; reiniciar; pedir dica; concluir automaticamente ou perder pelo tempo. |
| Resultado | Vitória/derrota, estrelas, pontuação e tempo restante quando aplicável. | Vitória: próxima fase, repetir ou menu. Derrota: repetir, dica para a próxima tentativa ou menu. Última fase: conclusão da campanha. |

**Layout:** orientação retrato. A miniatura fica acima ou abaixo da grade em celulares estreitos; uma posição lateral só será usada se houver espaço. A grade 6×6 deve continuar confortável ao toque, com alvo próximo de 48 dp por célula no aparelho de referência e validação em tela pequena. Ícones, texto e brilho devem comunicar estados além da cor.

**Fluxo principal:** menu → puzzle → animação do zap → resultado → próxima fase. A animação de vitória deve durar aproximadamente um segundo e permitir pular após a primeira exibição.

## 6. Direção visual e sonora

**Estilo definido:** Cartoon 2D estilizado, com humor macabro e animação exagerada. Usar contornos bem definidos, formas simples, paleta curta e sombras discretas. Produzir ilustrações com acabamento limpo, exportadas como sprites em resolução suficiente para os aparelhos-alvo; dimensionar interface e arte para leitura em celular.

**Objetivo da escolha:** tornar a rotação dos fios fácil de ler e explorar expressões, poses e deformações para comunicar o humor do zap. Essa é uma decisão de direção artística para o público casual e para a proposta do jogo, sem pressupor que o estilo, por si só, garanta sucesso comercial.

**Aplicação visual:**

- **Tabuleiro:** fios grossos, conexões grandes e fundo metálico com poucos detalhes; energia e encaixes têm prioridade sobre decoração.
- **Personagem:** cabeça grande, silhueta reconhecível e olhos e boca expressivos, legíveis mesmo na miniatura da sala.
- **Cadeira:** máquina de laboratório de vilão com parafusos enormes, alavancas e proporções absurdas.
- **Cores:** cenário escuro e pouco saturado, com corrente amarela ou azul em alto contraste; indicar estados também por símbolos e brilho.
- **Interface:** botões grandes, tipografia legível e ícones consistentes com os contornos e formas da arte.

**Produção dentro de três semanas:** reutilizar partes do personagem e animar por transformações simples de posição, rotação e escala, complementadas por poucas poses desenhadas. Limitar o MVP a um personagem, uma cadeira e uma sequência de zap; evitar animação quadro a quadro extensa e cenários detalhados.

**Ambientação:** painel metálico industrial, parafusos, botões exagerados, laboratório de vilões e personagem fictício caricatural. A cadeira continua identificável, mas a cena privilegia a gag visual: cabelo arrepiado, esqueleto em silhueta e fumaça cartunesca, sem sangue, queimaduras detalhadas ou sofrimento prolongado.

**Lista mínima de recursos:**

- Um fundo de painel e um cenário compacto da sala.
- Peças reto/L/T, estados energizados, trava e fusível queimado; reutilizar sprites por rotação.
- Gerador, terminal, cadeira e um personagem com poses de repouso, antecipação, zap e reação de falha.
- Logo, botões, estrelas, ícones de áudio, pausa, dica e indicadores.
- Cliques mecânicos, zumbido de corrente, alerta de tempo, zap e efeitos de vitória/derrota.
- Uma trilha curta em loop, se couber no orçamento; sem depender dela para comunicar regras.

**Sequência do zap:** antecipação curta → choque com esqueleto cartunesco e deformação exagerada → cabelo arrepiado, fumaça e expressão indignada. Manter a sequência próxima de um segundo, reutilizar as poses e preservar a opção de pular após a primeira exibição.

O zumbido acompanha a proporção de peças do caminho de referência alcançadas pela energia, limitado a um volume confortável; não cresce simplesmente por energizar distrações. A opção de redução de flashes substitui a piscada da sala por brilho suave e mantém o resultado compreensível. Registrar licença e autoria dos recursos de terceiros.

**Evolução da arte implementada no marco 0.9:** `assets/art/default_art.tres` controla `SpriteFrames` de personagem/cadeira e texturas de fio/fusível. A raiz da cena seleciona o pacote no Inspector. Imagens podem evoluir em novas versões, inclusive PNG e atlas, preservando as regras, os dados das fases e os alvos de toque. O guia `docs/GUIA_SPRITES.md` define canvas, alinhamento e nomes dos estados. Redução de flashes possui animação específica; campos vazios usam representação geométrica.

## 7. Implementação proposta

**Engine definida no protótipo:** Godot 4.7.2 estável com GDScript e renderer Compatibility. O projeto fixa essa versão em suas instruções e configurações. O APK 0.10.0 foi gerado com acabamento visual/sonoro e as mesmas 24 fases da versão 0.9.0; foi instalado e aberto no SM-G781B, com fase 18 e preferências preservadas. A integração de anúncios e o teste prolongado em aparelho físico ainda precisam de validação.

| Módulo | Responsabilidade |
| --- | --- |
| `BoardModel` | Dados das células e rotações, sem depender de animações. |
| `CircuitSolver` | Portas recíprocas, busca a partir do gerador e detecção de vitória. |
| `LevelRepository` | Carregamento e validação de fases autorais. |
| `GameController` | Tempo, estados, comandos e resultado único. |
| `BoardView` | Entrada por toque e representação das peças e energia. |
| `HintService` | Seleção e aplicação das correções de fios. |
| `SaveService` | Progresso, configurações e melhor resultado em armazenamento local. |
| `AdsService` | Interface isolada para anúncio de teste, produção e indisponibilidade. |
| `AudioVisualFeedback` | Som, partículas, animação e redução de flashes. |

**Dados por fase:** identificador, dimensões, limite de tempo, portas dos terminais, peças e orientações iniciais, células fixas e solução de referência. Usar arquivos JSON ou recursos nativos da engine; escolher um formato no primeiro dia e manter consistência.

Salvar após conclusão e mudanças de configuração. Usar versão no formato do save e escrita segura com arquivo temporário; recuperar padrões válidos se o arquivo estiver ausente ou corrompido. Nenhum dado pessoal é necessário para o puzzle.

**Validação técnica antecipada:** exportar e instalar uma build Android no dia 1; verificar até o dia 2 se a integração de anúncios disponível para a engine cobre rewarded e consentimento. Se essa integração comprometer o prazo, entregar a campanha com dicas gratuitas e adiar a ativação comercial. Não bloquear a entrega do jogo por um SDK.

## 8. Dicas e monetização

**Implementado na versão 0.8:** botão “Dica grátis”, uma utilização por tentativa, corrige e trava um fio de uma solução mínima calculada do tabuleiro atual. Respeita conexões válidas, marca o fio em verde e informa linha/coluna. A implementação atual não usa a referência autoral para escolher a dica. Reiniciar restaura a oportunidade e a configuração original. Os giros necessários entram no contador; o relógio considera o tempo ativo. Não há SDK de anúncios, compra ou crédito de recompensa nesta versão. O fluxo de três fios abaixo é uma proposta futura de monetização.

### Gerador de Emergência — anúncio recompensado

Durante a fase, o botão informa claramente: **“Assistir anúncio: corrigir até 3 fios”**. A recompensa ajusta até três peças móveis incorretas do caminho de referência e trava essas peças na orientação correta até o fim da tentativa. Se houver menos de três, corrigir somente as restantes; não oferecer anúncio sem correção disponível.

- Dar prioridade às peças mais próximas do trecho energizado do caminho de referência.
- Comparar conexões efetivas, respeitando a simetria dos fios retos; não cobrar correção por orientação visual equivalente.
- Apresentar uma dica gratuita no tutorial e limitar o rewarded a uma utilização por tentativa no MVP.
- Pausar tempo e bloquear grade enquanto o anúncio estiver em andamento.
- Conceder a recompensa somente no evento de recompensa do SDK, uma única vez por solicitação. Fechar o anúncio não basta.
- Ao receber a recompensa, registrar um crédito pendente; ao retornar ao jogo, aplicar a dica e só então retomar o relógio ou disparar vitória.
- Em cancelamento, falha ou ausência de anúncio, restaurar o jogo sem consumir a oportunidade e informar a indisponibilidade.
- No resultado de derrota, o anúncio concede uma dica para uma nova tentativa da mesma fase. Guardar esse crédito localmente e consumi-lo ao iniciar essa tentativa, sem reviver o relógio já encerrado.
- Usar anúncios de teste durante desenvolvimento. A documentação do SDK orienta o uso do callback de recompensa e de unidades de teste. [Referência AdMob](https://developers.google.com/admob/android/rewarded?hl=en).

A solução de referência serve para a dica; a vitória continua aceitando soluções alternativas. A trava é explicada antes da primeira dica, para que a correção não pareça um bug.

Integrar o fluxo de privacidade do provedor antes de solicitar anúncios e oferecer acesso às opções de privacidade quando necessário. O UMP documenta a atualização do estado de consentimento a cada abertura e a checagem de permissão para solicitar anúncios. [Referência UMP](https://developers.google.com/admob/android/privacy?hl=en).

Os anúncios serão voluntários e compatíveis com a classificação do jogo. A política da Play trata anúncios como parte do aplicativo; rewarded também precisa cumprir as políticas aplicáveis. [Política de anúncios](https://support.google.com/googleplay/android-developer/answer/9857753).

### Cosméticos — atualização posterior

Cores de raio verde alienígena, rosa e magenta, além de variações da cadeira, sem vantagem no puzzle. Começar por desbloqueios de progresso para validar interesse. Uma loja paga exige orçamento adicional para integração, restauração de compras, estados pendentes e testes.

Para a distribuição pela Play, planejar compras de bens digitais com Google Play Billing, observando as exceções aplicáveis da política. Não incluir checkout externo no escopo inicial. [Política de pagamentos](https://support.google.com/googleplay/android-developer/answer/9858738?hl=en).

## 9. Cronograma de três semanas

Cada dia representa seis horas, com entregas verificáveis. A sequência abaixo soma 90 horas e inclui 12 horas de estabilização nos dois últimos dias.

| Dia | Trabalho principal | Critério de conclusão |
| --- | --- | --- |
| 1 | Fixar escopo, engine, orientação e formato de fases; definir paleta, contornos e poses do Cartoon 2D; configurar projeto e exportação. | Build mínima instalada em Android; guia visual mínimo e decisões registrados. |
| 2 | Modelo de peças, rotação e prova de integração de anúncios/consentimento. | Reto/L/T giram; viabilidade do SDK decidida. |
| 3 | Busca de energia, estados e temporizador. | Vitória e derrota reproduzíveis; ciclos não travam a busca. |
| 4 | Primeira fase completa e tutorial básico. | Jogador chega do menu ao resultado no celular. |
| 5 | Save, seleção simples e fases 1–8. | Progresso persiste; primeiro grupo validado. |
| 6 | Layout final da grade e interface. | Grade 6×6 utilizável em tela pequena. |
| 7 | Fios fixos, fusíveis e fases 9–16. | Obstáculos e soluções de referência validados. |
| 8 | Fases 17–24 e ajustes de dificuldade. | Campanha inteira jogável com recursos provisórios. |
| 9 | Arte Cartoon 2D final mínima e animação de conclusão com poses reutilizáveis. | Fluxo visual completo, expressões legíveis na miniatura e redução de flashes. |
| 10 | Áudio, pontuação, estrelas e playtest de compreensão. | Nenhuma regra depende apenas de cor ou som. |
| 11 | Dica gratuita, seleção de peças e rewarded. | Recompensa e indisponibilidade testadas. |
| 12 | Consentimento, pausa, retorno de anúncio e persistência do crédito. | Jogo recupera o estado sem recompensa duplicada. |
| 13 | Playtest externo, balanceamento e preparação da ficha da loja. | Lista de problemas priorizada; materiais preliminares prontos. |
| 14 | Correções, aparelhos diferentes e revisão das declarações da loja. | Nenhum bloqueador conhecido; candidato a release. |
| 15 | Regressão final, AAB assinado e pacote de entrega. | Build e documentação prontas para o canal de testes adequado. |

**Marcos:** semana 1 = núcleo e oito fases; semana 2 = campanha e apresentação completas; semana 3 = monetização opcional validada, estabilização e entrega.

Preparar conta e recrutar testadores desde o primeiro dia. Disponibilizar builds de teste assim que forem estáveis. A duração do teste obrigatório, quando aplicável, começa a contar pela adesão dos testadores ao teste fechado, não pelo início do desenvolvimento.

## 10. Verificação e critérios de aceite

### Lógica automatizada

Implementado no protótipo: auditor independente de solvabilidade, testes para cada fase usando as soluções encontradas, mouse e toque em dois tamanhos de tela, pausa, reinício, derrota, vitória e progressão. Consultar `docs/TESTES_FASES.md` para os resultados e sequências.

- Portas incompatíveis e bordas não conduzem energia.
- Rotações de reto/L/T preservam conexões esperadas.
- Ramificações e ciclos são processados sem laço infinito.
- As 24 soluções de referência alcançam o terminal; nenhum início já está resolvido.
- Dicas respeitam peças fixas, simetrias, limite e concessão única.
- Transições de tempo, anúncio, pausa e resultado não duplicam conclusão ou recompensa.

### Testes no aparelho

- Completar a campanha sem anúncio e sem conexão à internet.
- Testar toque rápido, voltar do Android, minimizar, retomar, reiniciar e fechar o aplicativo.
- Verificar anúncio cancelado, recompensa recebida, erro de exibição, rede indisponível e retorno ao jogo.
- Confirmar save após reinício do processo, fim da campanha e configurações de som/flashes.
- Conferir texto, recortes, contraste e alvos de toque em pelo menos dois tamanhos de tela; incluir um aparelho de menor desempenho.
- Meta de fluidez: 60 fps no aparelho de referência; manter pelo menos 30 fps no aparelho de menor desempenho escolhido. São metas a medir, não resultados já obtidos.

**Aceite do MVP:** todas as fases solucionáveis, três telas funcionais, progresso persistente, ausência de bloqueadores no fluxo principal e build Android instalável. Se os anúncios estiverem ativos, seus fluxos de privacidade e recompensa também precisam passar; caso contrário, entregar explicitamente com dicas gratuitas e monetização desativada.

**Playtest sugerido:** pelo menos cinco pessoas sem instrução verbal do desenvolvedor. Observar se aprendem a girar e seguir energia nas três primeiras fases, registrar tempo por fase, desistências e dicas. Esse grupo serve à usabilidade e não substitui eventuais requisitos de teste da loja.

## 11. Publicação na Google Play

A política permite, em geral, violência fictícia em jogos, inclusive cartoons, e restringe violência gráfica realista. A estilização cartoon ajuda a direção cômica, mas não garante aprovação. Revisar a execução final e os materiais promocionais conforme a política. [Conteúdo inadequado e violência](https://support.google.com/googleplay/android-developer/answer/9878810?hl=en).

**Preparação para envio:**

- Confirmar nome, identidade do pacote, assinatura e acesso à conta de desenvolvedor.
- Verificar requisitos técnicos vigentes de Android e Play Console no momento da exportação final, inclusive API de destino e compatibilidade das bibliotecas nativas usadas.
- Produzir ícone, capturas e descrição fiéis ao jogo; mostrar o puzzle como atividade principal.
- Preencher questionário de classificação e público-alvo conforme o conteúdo real.
- Declarar anúncios, segurança dos dados e SDKs integrados; disponibilizar política de privacidade coerente com a coleta efetiva.
- Validar a build no canal de testes apropriado antes de solicitar produção.

Contas pessoais criadas após 13 de novembro de 2023 estão sujeitas, segundo a regra consultada, a teste fechado com pelo menos 12 testadores inscritos continuamente por 14 dias antes de solicitar acesso à produção. Conferir a situação da conta na Play Console. [Requisitos de testes](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en).

**Compromisso de prazo:** entregar um candidato a release em três semanas. Aprovação, conclusão do teste obrigatório e disponibilidade pública podem ocorrer depois, por dependerem da conta, dos testadores e da análise da loja.

## 12. Riscos e decisões de corte

| Risco | Resposta planejada |
| --- | --- |
| Escopo exceder a capacidade | Primeiro reduzir animações e decoração; depois reduzir campanha para 18 fases, seis por tamanho. Registrar o corte antes da entrega. |
| Integração Android/SDK atrasar | Validar no início; desativar monetização e entregar dicas gratuitas se necessário. |
| Humor parecer crueldade realista | Revisar gag, personagem e duração; manter estilização e eliminar detalhes gráficos de lesão. |
| Grade 6×6 ficar pequena | Priorizar espaço da grade, reposicionar miniatura e validar em tela pequena antes da arte final. |
| Fases frustrantes ou ambíguas | Ajustar tempo e obstáculos; comunicar que basta alcançar a saída e aceitar rotas alternativas. |
| Produção de arte atrasar | Reutilizar fios por rotação e partes do personagem por transformações simples; manter um personagem, uma cadeira e uma sequência de zap com poucas poses. |
| Publicação ultrapassar três semanas | Separar marco de entrega da build do calendário de aprovação e testes da loja. |

**Ordem de prioridade:** núcleo solucionável → interface legível → campanha → feedback cômico → dicas → anúncios → cosméticos. Compras de skins permanecem fora das três semanas.

## 13. Entregáveis finais

- Projeto-fonte organizado, versão de engine e dependências fixadas.
- Campanha e respectivos dados de validação.
- APK para instalação de teste e AAB assinado para o canal de distribuição.
- Registro dos aparelhos e cenários testados, limitações e problemas conhecidos.
- Instruções para abrir o projeto, gerar builds e configurar anúncios sem expor segredos.
- Relação de recursos e licenças, textos da loja, ícone e capturas.
- Declaração clara da situação da monetização e das etapas de publicação ainda pendentes.

As referências de política e monetização foram consultadas em 4 de novembro de 2026. As escolhas de escopo, engine, tempos e pontuação são propostas deste plano e devem ser confirmadas pela implementação e pelos playtests.

## Marco 0.11 — aproveitamento dos conceitos

Concluída a integração de 15 PNGs derivados das imagens de `test_sprites`, em um pacote independente e substituível. Placas estáticas, fios com portas compatíveis, T energizado, fusível, reinício, botão vermelho, cenário, engenheiro no menu e cavaleiro/cadeira com três poses. Mantidas as 24 fases, os tempos, a dica e a progressão; somente uma instrução deixou de citar a cor antiga da corrente. Fontes e prompts em `docs/CONCEITO_V3_ASSETS.md`; procedimento em `docs/GUIA_SPRITES.md`.

### Correção 0.11.1 — conexões dos fios

Curvas e T foram refeitos com pontas próximas à espessura da reta e cabos levemente entrelaçados. As versões normal e energizada mantêm as portas existentes. Teste de silhueta nas bordas confere largura e centralização nos quatro giros; as 24 fases não mudaram. Prompts e arquivos em `docs/CORRECAO_FIOS_UNIFORMES.md`.

## Marco 0.12 — operador e ocupante independentes

Tela reorganizada conforme o conceito: goblin/chave acima, grade ao centro, ocupante/cadeira abaixo. A ligação correta dispara 0,40 s de chave em três poses, descarga com som único, recuperação e resultado aos 1,65 s. Novo recurso `ExecutionCharacter` permite trocar nome e animações do ocupante sem alterar fios, operador, fases ou progresso. Documentação e prompts em `docs/OPERADOR_E_PERSONAGENS.md`. A grade conserva 624×624 unidades e os alvos de toque existentes.

### 0.12.1 — composição em sala contínua

Integrados goblin, matriz e ocupante sem cards ou divisórias de setor. Novo fundo contínuo, atores maiores e próximos da matriz, medidor de carga na parede, cabeçalho com menu/fase/tempo/giros/pausa e rodapé com instrução contextual e dois botões maiores. Preservados os 24 tabuleiros, cronômetros, dicas e recurso independente de personagem. Documentação em `docs/SALA_CONTINUA_UX.md`.

### 0.12.2 — cabos externos

Melhorado o acabamento com mangueiras curvas corrugadas, conectores e abraçadeiras. Corrigido o percurso da esquerda para ligar o gerador ao IN, mantendo OUT→cadeira pela direita. As pontas acompanham os terminais e os encaixes normalizados dos atores. A carga visual da saída só aparece depois da chave abaixada. Verificação dos percursos nas 24 fases e em três proporções, mantendo os tabuleiros existentes.

## Marco 0.13 — impacto da descarga

Adicionados tremor limitado e três clarões moderados atrás dos atores durante o choque, com iluminação gradual sem tremor no modo suave. Sequência prolongada de 1,65 para 2,40 s, preservando a visibilidade do ocupante, as regras das fases e o relógio da tentativa. Testes varrem a sequência em passos de 1/120 s nos dois modos, verificando limites, duração, opacidade, ausência de resultado antecipado e limpeza dos efeitos.

### Correção 0.13.1 — vibração física

Acrescentada uma chamada nativa de 800 ms ao iniciar o choque e habilitada a permissão Android VIBRATE. A versão anterior só deslocava o fundo; não acionava o motor do celular. Mantidos os flashes e a duração de 2,40 s, sem modificar preferências globais do aparelho. A operação depende das configurações de vibração do Android. Referência: https://docs.godotengine.org/en/stable/classes/class_input.html#class-input-method-vibrate-handheld.

## Marco 0.14 — menu e resultado simplificados

Menu sem cards, selos ou textos longos: título, goblin, Jogar/Continuar, Fases e ajustes de som/flashes. Resultado no mesmo cenário da sala, com ocupante, estrelas, pontuação e próxima fase; recordes completos continuam no seletor. Pausa e derrota seguem o mesmo padrão. Menu e partida compartilham proporção 720×1600. Mantidas fases, vibração e animação de 2,40 s. A vibração da 0.13.1 foi confirmada no serviço Android e pelo usuário.

### Acabamento 0.14.1–0.14.2

Ícone cartunesco do goblin com óculos e raio, com camadas adaptativas Android. Alavanca levantada afastada da orelha e mão direita conectada ao punho. Pisos metálicos percorrem toda a largura da sala sob goblin e cadeira. Trilha original Fortress After Hours, lo-fi sombria de 75 BPM, com loop de 51,2 s, pausa e volume reduzido durante a descarga. Começar de novo, no seletor de fases, retorna ao menu com a fase 1 selecionada. O ponto de continuação fica separado do maior desbloqueio no perfil v3; migração mantém o comportamento de saves antigos e preserva recordes e preferências. A nova sequência continua da fase 1 para a 2, sem saltar para o desbloqueio antigo.

### Revisão 0.14.3 — trilha mais sóbria e rápida

Tema original de órgão, baixo pulsante e celesta a 120 BPM, 64 segundos em loop. Sem bateria hip-hop ou ruído de fita. Volume normal aumentado em 6 dB e redução de 8 dB durante a descarga. Mantidos os controles de som, pausa e segundo plano. Suíte de áudio/acabamento: 35 verificações aprovadas.

### Revisões 0.14.4–0.14.5 — cabeçalho, menu e esqueleto

Cabeçalho com fase, tempo, giros e pausa; Menu fica na pausa. Perfis novos usam flashes normais. A opção 2 de cadeira e fios foi escolhida para o menu, independente do goblin e do ocupante. Corrigido o estado zap_soft do cavaleiro e do pacote, que usava a pose de espera: agora o esqueleto aparece em ambos os modos durante todo o choque. Suíte final: 35.489 verificações e 15 testes Python aprovados. Pacotes 0.14.5 gerados localmente, sem nova instalação após a instrução de não subir.

### Correção 0.14.6 — clarão visível na partida

Clarão movido do fundo para uma camada sobre matriz e atores, mantendo transparência e deixando cabeçalho/rodapé livres. Teste de pixels confirma iluminação real da placa. Preservados esqueleto, duração e vibração física. Instalado no SM-G781B, com flashes normais ativos. Suíte completa: 35.493 verificações e 15 testes Python aprovados.


### Ajustes 0.15.0 — áudio e vibração

Tela única no estilo da sala, acessível pelo menu e pela pausa. Música e efeitos têm volumes independentes de 0–100%; som geral mantém os níveis escolhidos ao desligar. Vibração tem opção própria, inicialmente ligada. Abrir ajustes da pausa preserva a tentativa e o relógio; Voltar retorna à pausa. Perfil v4 mantém compatibilidade, recordes e preferências anteriores. Validados migração, persistência, controles nativos, isolamento de áudio e retorno à partida: 35.530 verificações, 15 testes Python e 730 estados de dicas aprovados. Teste de áudio: 48 verificações, incluindo três ciclos do OGG. APK 0.15.0/código 25 instalado no SM-G781B com perfil idêntico após a instalação. Guia em `docs/AJUSTES.md`.


### Próximo upgrade planejado — condenados e diálogos

Planejamento solicitado em 5 de novembro de 2026: cinco bases de condenados com nomes e cores variados, sorteio por fase e micro-histórias em balões antes da partida. Escopo, exemplos, sequência de produção e testes em [docs/PLANO_CONDENADOS_E_DIALOGOS.md](docs/PLANO_CONDENADOS_E_DIALOGOS.md). Ainda não implementado; a primeira etapa será a prévia dos cinco personagens.


### Cinco condenados — entrega 0.16.0

Cinco bases com três poses próprias, 25 nomes, lista embaralhada sem repetição imediata e persistência da identidade da fase pendente. Nome exibido discretamente ao lado da cadeira. Perfil v5 conserva recordes, desbloqueios e preferências. Esqueleto próprio no modo normal/suave. Android instalado no S20 FE pelo fluxo obrigatório de testes, auditoria e comparação do perfil. Restam paletas adicionais e conversas em balões. Detalhes em `docs/CONDEMNED_POSES_016.md`.
