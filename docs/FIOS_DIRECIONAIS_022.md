# Fios de sentido único — 0.22.0

Segunda entrega do [plano de desafios](../PLANO_DESAFIOS_FASES_EXISTENTES.md), após as lâmpadas obrigatórias.

| Fase | Regra | Mínimo de giros | Tempo |
| --- | --- | --- | --- |
| 13 | Uma seta indica o sentido permitido da corrente. | 18 | 180 s |
| 14 | Desvio por fusíveis com uma seta inicialmente invertida. | 20 | 180 s |
| 16 | Respeitar a seta, acender a lâmpada e ligar OUT. | 24 | 180 s |

As fases 12 e 15 continuam clássicas. As lâmpadas das fases 10 e 11 permanecem. Os demais painéis conservam suas regras e tempos. Não foram introduzidos alarmes, interruptores ou peças vinculadas.

## Comportamento

O fio direcional usa `kind: "diode"` nos dados. É um fio reto com entrada pela cauda e saída pela ponta da seta. Cada toque gira 90°. Um giro de 180° mantém as extremidades visuais do fio, mas inverte o sentido permitido.

O `CircuitBoard` separa portas de entrada e saída. A propagação exige que a saída da peça anterior alcance uma entrada permitida da seguinte; isso também vale para os terminais de origem e destino. Lâmpadas precisam receber energia pela entrada correta, e a cadeira só dispara com todos os objetivos atendidos.

O símbolo usa o sprite reto existente com uma seta vetorial de alto contraste. Quando a corrente chega pela ponta invertida, a seta recebe alerta com exclamação e o feedback explica que a entrada é pela cauda. A forma da seta e o texto complementam a cor. As faíscas seguem somente as portas de saída.

## Dicas e autoria

As dicas e o tutorial comparam a orientação elétrica completa, incluindo entrada e saída. Isso permite corrigir 180° quando a geometria do fio já parece alinhada. A ajuda mantém o comportamento anterior: corrige e trava um fio, contabiliza os giros reais e só é consumida quando existe uma solução válida.

O resolvedor de caminho respeita o sentido em cada célula. Na busca de redes com lâmpadas, os ramos são percorridos do objetivo até a rede da fonte; por isso a entrada e a saída são tratadas explicitamente no sentido inverso da busca. Os pontos de junção usam apenas saídas permitidas da rede já construída. A propagação completa confirma a solução candidata. Nenhuma dica consulta `solution` ou `reference_path`.

Os geradores preservam as novas peças e a lâmpada da fase 16. Na 14, o custo adicional do giro de 180° foi compensado em outra peça, mantendo o mínimo de 20 giros. As fases 13, 14 e 16 usam revisão de regras 2; o perfil v7 já preserva os recordes anteriores no histórico, sem alterar desbloqueios ou comparar tempos de regras diferentes. O seletor usa a mensagem genérica de regra nova.

## Verificação

- Quatro direções, entrada invertida, giro de 180°, simetria visual e fonte/destino direcionais.
- Lâmpada em ramificação, T, ciclos, peças fixas e estados impossíveis sem consumo da dica.
- Mínimos conferidos por enumeração exaustiva em tabuleiros pequenos e por implementação independente em Python.
- Partidas das 24 fases executadas por mouse/toque, estados parciais, erros e casos sem referência autoral.
- Aviso de bloqueio, pausa, dica de 180°, trava do fio e resultado com revisão correta em três proporções.
- Comparação de pixels confirma setas nas quatro orientações e a exclamação de bloqueio. Capturas em `builds/directional-wires/`.

Fluxo obrigatório aprovado: **55 testes Python, 41.705 verificações da engine, 806 estados de dicas, 3.640 verificações visuais/temporais e 48 de áudio**, sem falhas. A maior consulta de dica medida nesta execução foi 9,15 ms neste computador; não é um benchmark do celular.

APK 0.22.0/código 39 exportado e auditado, com fases idênticas às fontes e 83 texturas conferidas. A instalação parou na seleção do aparelho porque o S20 FE não estava disponível no ADB. Nenhum dado do celular foi alterado. Log: `builds/deploy-v0220-install.log`; relatórios de dicas e renderização em `builds/hint-stress-results.json` e `builds/effects/results.json`. As simulações usam perfil isolado, sem automatizar partidas no aparelho. Avaliação humana da nova mecânica no celular pendente.
