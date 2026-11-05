# Zap & Fry 0.14.3 — roteiro de playtest

Objetivo: avaliar compreensão, ritmo, legibilidade e equilíbrio do áudio no uso real. Primeira sessão de 15–20 minutos; fases avançadas podem ser avaliadas em sessões posteriores, conforme os desbloqueios. Este roteiro não presume aprovação humana: registrar o que realmente aconteceu.

## Pacote

Arquivos preparados em `builds/playtest/ZapFry-0.14.3/`: APK Android, ZIP Windows, instruções e hashes SHA-256. Instalar o APK como atualização, mantendo o mesmo aplicativo e seus dados. No Windows, extrair o ZIP antes de executar `ZapFry.exe`.

A versão é de teste local. Não contém anúncios, compras nem coleta de métricas pela rede. Progresso e preferências ficam no aparelho. O botão Começar de novo volta à fase 1 e ao menu, mantendo conquistas; não é necessário desinstalar para repetir a introdução.

## Sessão inicial

1. Anotar modelo do aparelho, versão do Android, versão 0.14.3, uso de alto-falante ou fones e volume do sistema. Usar um identificador de sessão, sem dados pessoais.
2. Abrir o jogo e localizar Jogar/Continuar, Fases, SOM e flashes suaves. Conferir se textos e botões cabem na tela.
3. Em Fases, tocar Começar de novo: deve voltar ao menu, pronto para jogar a fase 1. As conquistas já obtidas devem continuar no seletor.
4. Observar a fase 1 sem explicar a solução. Registrar tempo até entender o giro, primeiro toque e conclusão. Nas fases 2 e 3, observar se a seta ajuda e se fica claro que não há cronômetro.
5. Nas fases 4–6, observar início do cronômetro, distrações e conexão em T. Se houver dificuldade, usar a dica e conferir se o fio indicado ajuda a conectar IN a OUT.
6. Pausar durante uma fase: relógio e música devem pausar. Continuar: a partida e a trilha devem retomar. Sair para outro aplicativo por dez segundos e retornar; a fase deve continuar pausada.
7. Fechar um circuito: conferir mão e alavanca do goblin, vibração, descarga visível até o fim e resultado após a recuperação. O piso deve atravessar toda a largura, sem cobrir grade, botões ou conexões.
8. Ir à próxima fase e depois ao menu. Fechar e reabrir o processo: conferir fase de continuação, desbloqueios, recordes e preferências. A tentativa em andamento reinicia; o protótipo não salva o tabuleiro parcial.

## Ouvir a trilha

- Ouvir ao menos dois ciclos de 64 segundos: registrar emenda perceptível, estalo, parada ou repetição incômoda.
- Avaliar se órgão, baixo e celesta transmitem ambiente sóbrio e fantasmagórico e se o ritmo de 120 BPM combina com o puzzle.
- Comparar música com cliques, dica e zap. O volume normal aumentou 6 dB; na descarga a música baixa 8 dB. Anotar se algum efeito fica encoberto, especialmente no alto-falante do celular.
- Desligar SOM: todos os canais devem parar. Religar: a trilha deve voltar, sem duplicação. O ajuste deve permanecer ao reabrir.

## Fases avançadas

Quando estiverem desbloqueadas, priorizar 9, 11, 16, 17 e 24. Registrar tentativas, tempo até concluir, uso de dica e causa da dificuldade. Na grade 6×6, verificar conforto do toque e leitura dos fios. Após a fase 24, conferir encerramento e a possibilidade de começar novamente.

## Registro

| Sessão | Aparelho/Android | Fase | Tentativas | Tempo observado | Dica | Problema ou impressão |
| --- | --- | --- | --- | --- | --- | --- |
| P01 | A preencher | — | — | — | — | — |

Para um defeito reproduzível, anotar fase, passos, resultado esperado e resultado observado; acrescentar captura ou gravação se disponível. Classificar: bloqueia a partida, dificulta bastante ou apenas acabamento. Uma fase ser solucionável automaticamente não comprova facilidade para uma pessoa.

## Critério para avançar

Corrigir travamentos, perdas de progresso, bloqueios de fase e dicas que prejudiquem a solução antes de ampliar a distribuição. Confirmar compreensão da introdução e conforto do áudio em aparelho real. Registrar recortes de tela, aquecimento e bateria observados; FPS e consumo ainda precisam de medição própria. A validação automatizada está em `VALIDACAO_PROTOTIPO.md`; ela não substitui esta observação humana.
