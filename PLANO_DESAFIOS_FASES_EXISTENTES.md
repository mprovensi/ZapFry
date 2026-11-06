# Zap & Fry — desafios para as fases existentes

**Data:** 5 de novembro de 2026.  
**Base:** versão 0.20.0, Godot 4.7.2 / GDScript.  
**Status:** lâmpadas nas fases 10 e 11 entregues na 0.21.0. Sentido único nas fases 13 e 14 e combinação com lâmpada na 16 implementados e testados na 0.22.0; APK pronto, instalação pendente de reconexão do S20 FE. Alarmes e segundo lote continuam planejados. Detalhes em [docs/DESAFIOS_021.md](docs/DESAFIOS_021.md) e [docs/FIOS_DIRECIONAIS_022.md](docs/FIOS_DIRECIONAIS_022.md).

**Objetivo:** aumentar a variedade de raciocínio da campanha atual antes de criar as fases 25–32.

## 1. Diretrizes

- Trabalhar nas 24 fases atuais, mantendo seus IDs, a progressão e o encerramento após a fase 24.
- **A autoria escolhe quais desafios existem em cada fase.** O jogador não escolhe desativá-los: quando uma fase contém um desafio, ele faz parte das condições para vencer. Podem existir fases inteiramente clássicas, sem lâmpada obrigatória, sentido único, alarme, interruptor, dupla vinculada ou segundo equipamento.
- Intercalar fases clássicas e fases com desafios para variar o ritmo. Uma fase clássica continua podendo exigir raciocínio pela disposição dos fios, T e fusíveis existentes.
- Preservar o aprendizado das fases 1–9. Introduzir cada regra nova isoladamente, com uma instrução curta no feedback existente e um símbolo persistente no painel.
- Manter os dois balões de conversa. As explicações das mecânicas não acrescentam uma terceira fala nem cards à sala.
- Preservar inicialmente os tempos atuais: fase 10 com 150 s; 11–16 com 180 s; 17–20 com 210 s; 21–24 com 225 s. Ajustes posteriores dependem de testes e playtest.
- O relógio continua começando na primeira ação válida. Ler a apresentação não consome tempo.
- Usar símbolos, formas e setas junto das cores. O significado de uma peça deve continuar claro durante o brilho da corrente.
- No primeiro lote, combinar no máximo duas regras novas por fase. As fases de apresentação podem receber menos distrações para acomodar o aprendizado.
- Cada desafio só entra na campanha quando tiver solução, dica válida e feedback visual verificáveis.

## 2. Desafios e comportamento esperado

| Desafio | Regra | Apresentação | Prioridade |
| --- | --- | --- | --- |
| Lâmpada obrigatória | A cadeira e uma lâmpada marcada precisam receber energia da fonte ao mesmo tempo. Ramificações válidas são aceitas. | Ícone de lâmpada apagada/acesa; indicador de objetivo pendente. | Primeiro lote |
| Fio de sentido único | Uma peça reta conduz somente da entrada para a saída indicada pela seta. Girar 180° inverte o sentido, mesmo mantendo a aparência de fio reto. | Seta grande sobre o fio e indicação de corrente bloqueada quando a orientação está invertida. | Primeiro lote |
| Alarme proibido | A cadeira só pode ser acionada quando o terminal de alarme estiver sem energia. | Sirene/triângulo de alerta; feedback explicando o desvio necessário. | Primeiro lote |
| Interruptor de caminhos | O toque alterna entre duas conexões estáveis, abrindo uma passagem e fechando outra. | Alavanca pequena com posições A/B e contatos visíveis. | Segundo lote |
| Peças vinculadas | Um toque gira duas peças identificadas como uma dupla, de forma simultânea. | Símbolo de corrente e o mesmo identificador nas duas células; destaque conjunto ao tocar. | Segundo lote |
| Dois equipamentos | Alimentar a cadeira e um segundo equipamento em pontos distintos do painel. | Terminais identificados e ícone do equipamento, como ventilador ou porta. | Evolução dos objetivos obrigatórios |

**Alarme recuperável:** energizar o alarme não causa derrota imediata. O jogador pode corrigir a ligação; o relógio segue a regra normal da tentativa. Mesmo com a cadeira conectada, a descarga aguarda o alarme desligar e os demais objetivos serem atendidos.

**Interruptor:** cada toque é uma ação e alterna apenas entre as duas posições definidas. O modelo e as dicas não devem tratá-lo como uma peça comum de quatro giros.

**Duplas:** cada toque conta como uma ação, ainda que altere duas células. A alteração é atômica: ambas giram e só então a corrente é recalculada. Não criar grupos sobrepostos ou que incluam obstáculos e peças fixas.

**Consolidação:** lâmpada e segundo equipamento compartilham a avaliação de objetivos obrigatórios. O equipamento pode exigir também uma porta de saída conectada, enquanto a lâmpada exige energia na célula. Não criar dois sistemas independentes para validar esses objetivos.

## 3. Distribuição inicial — primeiro lote

Esta é uma proposta de composição. As posições exatas, os giros mínimos e a quantidade de distrações serão definidos pelo resolvedor e pelo playtest.

Os intervalos abaixo não tornam os desafios obrigatórios em todas as fases daquele setor. A distribuição já reserva fases clássicas, e outras podem permanecer sem as novidades conforme o playtest.

| Fase | Alteração proposta |
| --- | --- |
| 1–9 | Aprendizado atual de giro, curvas, T, fusíveis e mudança para 5×5. |
| 10 | Apresentar uma lâmpada obrigatória em uma ligação visualmente clara. |
| 11 | Lâmpada com conexão em T, sem acrescentar outra regra nova. |
| 12 | Fase clássica de desvio por fusível, sem os novos desafios. |
| 13 | Apresentar um único fio de sentido obrigatório. |
| 14 | Sentido obrigatório com desvio simples. |
| 15 | Fase clássica de curvas e T, sem os novos desafios. |
| 16 | Combinar lâmpada e sentido obrigatório. |
| 17 | Apresentar a grade 6×6 em uma fase clássica, sem os novos desafios. |
| 18 | Apresentar um alarme recuperável, com pouco ruído visual. |
| 19 | Alarme e fio direcional. |
| 20 | Alarme e lâmpada. |
| 21 | Nova disposição de lâmpada e fios direcionais. |
| 22 | Fase clássica com rotas alternativas, sem os novos desafios. |
| 23 | Revisão de duas regras já aprendidas, priorizando leitura do painel. |
| 24 | Encerramento clássico ou combinação de duas regras já aprendidas, conforme o playtest, seguido da tela de agradecimento existente. |

No segundo lote, avaliar substituir exercícios de revisão por um interruptor na fase 14, uma dupla vinculada na 21 e um segundo equipamento na 23. A primeira ocorrência de cada um apresenta a regra isoladamente; o encaixe definitivo depende da dificuldade medida no primeiro lote. Preservar fases clássicas entre essas introduções.

## 4. Responsabilidades no código

### Modelo do tabuleiro — `scripts/circuit_board.gd`

- Continuar responsável pelas conexões, ações válidas, propagação da energia e condição completa de solução.
- Para peças comuns, preservar as portas recíprocas atuais. Para fios direcionais, distinguir portas de entrada e saída durante a propagação.
- Avaliar todos os objetivos obrigatórios e terminais proibidos na mesma recomputação. `solved` só pode ser verdadeiro quando todas as condições forem atendidas.
- Expor o motivo de pendência para a apresentação: objetivo apagado, direção bloqueada ou alarme energizado.
- Aplicar interruptores e grupos vinculados no próprio modelo. Cada ação atômica gera uma revisão do tabuleiro, invalidando o cache de dicas.

### Tentativa e dicas — `scripts/game_session.gd` e `scripts/circuit_solution.gd`

O resolvedor atual procura um caminho até um destino. Isso não basta para aceitar ramificações obrigatórias, impedir energia em alarmes ou planejar ações vinculadas.

- Adaptar a busca para produzir um plano consistente com a rede inteira e com os objetivos da fase. Preservar o comportamento das fases sem regras extras.
- Considerar as peças fora do caminho principal: uma saída extra de T pode energizar um alarme, e um objetivo pode precisar de uma ramificação.
- Validar a configuração completa de cada solução candidata pela propagação real da energia. Filtrar um caminho encontrado pelo algoritmo antigo não é prova suficiente de que a melhor solução foi encontrada.
- Representar o custo em ações do jogador. Uma alternância de interruptor ou um giro de dupla custa um toque.
- A comparação de orientações deve considerar o sentido da corrente, não apenas a máscara visual do fio.
- As dicas partem do estado atual, incluindo peças já travadas, e não consultam `solution` ou `reference_path`.
- Para duplas, a dica aplica uma ação consistente ao grupo e trava o grupo inteiro na orientação da solução. O feedback informa que a dupla foi corrigida. Não travar somente uma das peças.
- Se o estado não tiver solução, não consumir a dica nem aplicar uma correção arbitrária. Informar a situação usando o comportamento de recuperação do jogo.
- Manter a descarga automática somente quando `board.solved` estiver verdadeiro; não duplicar as novas condições na interface.

### Visual e coordenação — `scripts/board_view.gd` e `scripts/main.gd`

- Reutilizar o painel, feedback e animações atuais. Criar ícones/setas e sinais locais antes de encomendar sprites adicionais.
- Mostrar o que falta para concluir, inclusive quando OUT já está energizado. Uma ligação incompleta não pode parecer um defeito do jogo.
- Permitir distinguir os símbolos em 4×4, 5×5 e 6×6 e nos modos de flashes normal e suave.
- Destacar as duas células de um grupo ao tocar ou receber dica, respeitando o bloqueio de input durante pausa, conversas e descarga.
- Preservar a duração de 2,40 s, o esqueleto, a vibração e a tela final após a fase 24.

### Dados e validação

- Manter os campos legados dos JSONs. Acrescentar somente os dados necessários aos desafios presentes naquela fase.
- Normalizar a saída principal e os objetivos adicionais no modelo. Ausência de campos novos significa a regra atual de conectar IN a OUT.
- Ativar desafios somente nas fases que os declaram explicitamente. Não inferir regras extras a partir do número da fase, do setor ou da dificuldade.
- Validar índices, portas, estados permitidos, objetivos duplicados ou incompatíveis, grupos sobrepostos e referências a células vazias/fixas.
- Fases não podem exigir e proibir energia no mesmo ponto.
- Atualizar os geradores de fases relevantes para que não sobrescrevam os novos desafios ao serem executados novamente.
- `solution` e `reference_path` continuam servindo a autoria, tutorial e regressões; não podem ser a resposta usada pela dica.

## 5. Ordem de execução e entregas

1. **Baseline:** guardar resultados atuais das 24 fases, tempos, soluções mínimas e regressões de dicas. Definir dados e invariantes do primeiro lote.
2. **Prova do resolvedor:** criar tabuleiros pequenos com objetivos em ramificações, sentido único e terminais proibidos. Confirmar soluções e dicas por uma implementação independente antes de editar a campanha.
3. **Lâmpada:** integrar modelo, dica, ícone e feedback; aplicar nas fases 10 e 11 e validar jogabilidade. A fase 12 permanece clássica.
4. **Sentido único:** integrar propagação dirigida, dica e setas; aplicar nas fases 13, 14 e 16. A fase 15 permanece clássica.
5. **Alarme:** integrar condição recuperável e avaliação da rede completa; aplicar nas fases 17–20.
6. **Combinações:** ajustar fases 21–24 com regras já ensinadas e executar playtest de dificuldade.
7. **Segundo lote:** implementar interruptor e dupla separadamente, com seus testes de ações e dicas; depois explorar o segundo equipamento usando o sistema de objetivos existente.
8. **Entrega:** executar o fluxo obrigatório, auditar o pacote e instalar como atualização, preservando o perfil. Registrar a confirmação humana no aparelho.

Cada entrega deve ser pequena o suficiente para identificar qual regra causou uma dificuldade ou regressão. Não introduzir todas as mecânicas simultaneamente.

## 6. Testes e critérios de aceite

| Área | Provas necessárias |
| --- | --- |
| Solução | As 24 fases têm solução válida para todas as regras; confirmar independentemente e executar a sequência na engine. |
| Fases clássicas | Ausência dos dados opcionais mantém a jogabilidade atual, inclusive em fases avançadas; nenhuma regra extra é aplicada pelo número da fase. |
| Lâmpadas/equipamentos | Aceitar ramificações válidas; não concluir com objetivo apagado ou porta obrigatória desconectada. |
| Direção | Cobrir entrada permitida, sentido invertido, quatro orientações, ciclos e conexões adjacentes. |
| Alarme | Cobrir energia por ramificação de T, bloqueio da descarga, correção sem derrota e ausência de penalidade automática adicional. |
| Interruptor | Exatamente duas posições; contatos antigos deixam de conduzir; custo de um toque e retorno ao estado inicial ao reiniciar. |
| Duplas | Giro atômico, um toque, revisão consistente, bloqueio de grupos inválidos e dica que preserva a relação entre as peças. |
| Dicas | Estados iniciais, parciais e errados; fios fixos; orientação simétrica com sentido diferente; grupos; ausência de solução. Toda dica concedida permite continuar e reduz o custo restante medido independentemente. |
| Interface | Mouse e toque, ausência de entrada duplicada, clareza dos objetivos e símbolos em três proporções; pausa e introdução continuam bloqueando ações. |
| Conclusão | Nenhuma descarga prematura; som e vitória únicos; esqueleto visível; recuperação antes do resultado e agradecimento apenas na última fase. |
| Entrega | Dados novos presentes no APK; texturas compiladas auditadas; erros nos logs e testes impedem exportação/instalação. |

Estender `tools/validate_levels.py`, `tools/validate_hint_states.py` e os testes da engine para as regras novas. O verificador Python precisa representar essas regras de forma independente; comparar apenas a referência autoral com o jogo não substitui essa prova.

As suítes devem cobrir também a execução de uma solução por mouse e por toque nas proporções já usadas pelo projeto. Se a busca ficar cara em 6×6, reduzir a combinação de componentes e melhorar a busca dentro de seu responsável antes de distribuir a fase. Uma busca interrompida não pode produzir uma dica sem validação.

## 7. Dificuldade e playtest

- Medir ações mínimas, tentativas, tempo ativo e uso de dica por fase. O teste atual de dois segundos por toque continua sendo uma referência automatizada, não uma prova de facilidade humana.
- Testar especialmente 10, 11, 13, 16, 17, 18, 21 e 24.
- Observar se o jogador entende por que a cadeira ainda não foi acionada.
- Se uma fase apresentar dificuldade excessiva, revisar distrações, posição dos objetivos e quantidade de componentes antes de aumentar a pressão do tempo.
- A introdução de cada regra deve ser compreensível por uma pessoa sem explicação oral do desenvolvedor.
- Ajustar o lote seguinte apenas após confirmar que a regra anterior ficou clara e que a dica continua útil.

## 8. Progresso, compatibilidade e segurança da entrega

- Preservar IDs de fases, fase de continuação, desbloqueios, personagens, conversas e preferências.
- A tentativa parcial já reinicia ao reabrir; a atualização não deve criar uma nova política de descarte de progresso.
- Identificar recordes obtidos com regras anteriores como históricos. Comparar desempenho entre revisões equivalentes, preservando os valores anteriores; definir a revisão da regra por fase nos dados e a migração aditiva no `PlayerProfile` antes de publicar fases modificadas.
- Manter escrita atômica e backup do perfil, com testes de migração dos saves existentes.
- Toda exportação/instalação passa por `tools/dev.ps1`: `test`, `effects-test` e `audio-test` obrigatórios. Para instalar, usar `tools/dev.ps1 install` com o aparelho correto.
- Não desinstalar, limpar dados nem automatizar partidas no celular do usuário. As simulações usam `-- --test` e perfil isolado.

## 9. Fora deste plano

Fases 25–32, aumento de grade, monetização, vidas consumíveis, quebra permanente de fios, punições por toque incorreto e serviços online. A primeira implementação deve começar pela prova do resolvedor e pela lâmpada obrigatória.
