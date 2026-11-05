# Tela de encerramento — 0.20.0

Concluir a fase 24 apresenta uma composição final com o mesmo cenário, piso, personagem recuperado, estrelas, pontuação e botões dos demais resultados.

- Cabeçalho: **MISSÃO CUMPRIDA**.
- Agradecimento: **OBRIGADO POR JOGAR!**.
- Contagem: **24 FASES CONCLUÍDAS**.
- Mensagem: **Mais fases virão pela frente. Até a próxima descarga!**.
- Ações: **JOGAR DO INÍCIO** e **MENU**.

O agradecimento aparece somente quando a última fase chega a `WON`, após os 2,40 s da descarga e recuperação. As demais fases mantêm o resultado normal. A tela final não intercepta os botões nem registra novamente a vitória. Jogar do início abre a fase 1; Menu e Voltar do Android retornam ao menu. Recordes, estrelas e desbloqueios são preservados; nenhuma nova migração de perfil é necessária.

A composição reutiliza o overlay de resultado existente e suas ações, com duas `Label` nativas para o agradecimento e o aviso de novas fases. Não há um segundo fluxo de conclusão ou recursos gráficos novos.

Testes de interface cobrem fase anterior, última fase ainda em jogo, espera da descarga, conteúdo, encaixe em 360×800, 720×1280 e 720×1600, bloqueio do puzzle, registro único, replay, Menu e Voltar. A suíte OpenGL compara pixels com e sem as mensagens para verificar que elas são realmente apresentadas, incluindo o stretch do viewport nas telas menores. Capturas locais em `builds/ending/360x800.png`, `720x1280.png` e `720x1600.png`.

As validações e capturas usam perfil isolado com `-- --test`; não automatizam a conclusão de fases no celular do usuário.
