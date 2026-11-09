# Desafios completos da campanha — 0.23.0

Entrega de todas as mecânicas restantes do [plano](../PLANO_DESAFIOS_FASES_EXISTENTES.md). Em 9 de novembro de 2026, o usuário solicitou também a instalação no celular e o commit de todas as alterações.

## Distribuição

| Fases | Desafio |
| --- | --- |
| 1–9 | Aprendizado anterior preservado. |
| 10–11 | Lâmpadas, incluindo ramificação em T. |
| 12 | Clássica. |
| 13–14 | Fios de sentido único. |
| 15 | Clássica. |
| 16 | Seta e lâmpada. |
| 17 | Clássica em 6×6. |
| 18 | Alarme recuperável. |
| 19 | Alarme e seta. |
| 20 | Alarme e lâmpada. |
| 21 | Interruptor A/B. |
| 22 | Clássica. |
| 23 | Dupla vinculada. |
| 24 | Cadeira e ventilador, seguidos pelo agradecimento existente. |

Cada mecânica nova recebe uma fase de apresentação. A distribuição do segundo lote usa as fases 21, 23 e 24, mantendo as introduções anteriores e as fases clássicas. As regras presentes são obrigatórias para vencer aquela fase; não há opção do jogador para desativá-las.

Os tempos foram mantidos. No setor 6×6, continuam 210 s nas fases 17–20 e 225 s nas 21–24. Os mínimos permanecem 26, 28, 30, 32, 34, 36, 38 e 40 ações. Na dupla, um toque conta uma ação, embora gire dois fios.

## Regras novas

**Alarme:** o símbolo de alerta identifica a célula que deve ficar sem energia. Ao acender, o alerta muda de aparência e o feedback explica o desvio necessário. A tentativa continua e o relógio segue normalmente. Mesmo com OUT ligado, a descarga só começa após desligar o alarme e atender os demais objetivos.

**Interruptor:** tem exatamente duas conexões, A e B. Cada toque alterna o caminho e conta uma ação. Usa os mesmos sprites de fios do pacote atual, com alavanca e identificação A/B desenhadas por cima.

**Dupla:** os dois fios mostram o mesmo número e símbolo de corrente. Tocar qualquer um gira ambos e recalcula a energia uma única vez. A dica corrige a orientação conjunta, trava os dois e destaca os dois contornos. O custo considera ações da dupla.

**Segundo equipamento:** o ventilador tem um terminal próprio. Não basta energizar a célula: sua porta de saída também deve estar conectada. O ícone gira quando alimentado. O modelo avalia o equipamento junto dos objetivos obrigatórios existentes, sem duplicar a regra de vitória na interface.

Mantidos os dois balões de conversa, a pausa, os ajustes, a descarga de 2,40 s, o esqueleto e a vibração. As instruções usam o feedback e o cabeçalho existentes.

## Modelo e resolvedor

Os dados usam `forbidden_nodes`, `linked_groups`, `required_outputs` e o tipo `switch`, com `switch_masks`. A ausência desses campos mantém as regras anteriores. O modelo valida índices, contatos do interruptor, sobreposição das duplas, membros fixos ou incompatíveis, portas externas e conflitos entre objetivos positivos e proibidos.

`CircuitBoard` mantém a propagação, a avaliação dos objetivos e a aplicação atômica das ações. Um traçado compartilhado da corrente fornece também o caminho que energizou um alarme. A dica usa a mesma unidade de ação do jogador e respeita o período de dois estados do interruptor.

O resolvedor positivo continua atendendo as fases clássicas e fornece um limite inferior para as fases com restrições. Para duplas, a busca considera as quatro orientações conjuntas, contabilizando o custo uma vez. Para alarmes, uma configuração candidata que aciona a sirene produz um caminho de energia; toda solução precisa interromper ao menos uma orientação nesse caminho. A busca restringe essas opções e procura novamente, incluindo fios fora da rota OUT. Candidatos completos são conferidos pela propagação real. Não há corte de tempo que produza uma dica não validada.

O auditor Python usa busca por prioridade e comparação com enumeração exaustiva de ações em tabuleiros pequenos. A engine usa busca com poda e verifica os mesmos estados de forma independente. Nenhuma dica lê `solution` ou `reference_path`.

## Compatibilidade e testes

IDs, continuação, desbloqueios, personagens, conversas e preferências permanecem preservados. As fases 18, 19, 20, 21, 23 e 24 usam revisão de regras 2. O perfil v7 existente arquiva os recordes da revisão anterior quando a fase é rejogada, sem comparar tempos de regras diferentes.

Cobertura nova: alarme ligado com OUT conectado, caminhos múltiplos até um alarme, correção fora da rota principal, duas duplas, interruptor B→A, dica conjunta, porta do ventilador, dados inválidos, configurações impossíveis sem consumo de dica e partidas com erros. A autoria determinística foi atualizada para preservar todas as mecânicas ao regenerar as fases.

A suite visual compara os estados dos símbolos, os dois contornos da dupla, a identificação A/B e a animação do ventilador em 360×800, 720×1280 e 720×1600. Capturas em `builds/advanced-challenges/`. Os testes fazem parte dos comandos obrigatórios de exportação.

## Entrega

Fluxo completo `tools/dev.ps1 android` aprovado: 64 testes Python, 42.330 verificações da engine, 831 estados de dicas, 3.685 verificações visuais/temporais e 48 verificações de áudio. As 24 fases são solucionáveis; os dados das fases no APK correspondem às fontes e 83 texturas foram auditadas.

APK 0.23.0, código Android 40, em `builds/ZapFry-0.23.0.apk`. SHA-256 do pacote instalado: `4621c67335044f1aeab3969ff6565e3de21899a4dfe45102eedf737d94b0d77b`. Capturas: `builds/advanced-challenges/`.

A instalação solicitada passou novamente por `tools/dev.ps1 install`, repetindo todas as suítes e a auditoria antes de atualizar o S20 FE (serial `RXCT803C36D`). A versão 0.23.0/código 40 foi confirmada no aparelho, o perfil permaneceu idêntico e a inicialização não registrou erros. Evidência: `builds/android/install-20261109T144435536290Z/status.json`; log: `builds/install-v0230-delivery.log`. A avaliação humana de dificuldade permanece pendente; nenhuma partida foi automatizada no celular.
