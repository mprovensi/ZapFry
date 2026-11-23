# Atualização de narrativa — Zap & Fry 0.24.0

Data: 23 de novembro de 2026. Android: código 41.

## Objetivo e história

Transformar as conversas isoladas em 24 acontecimentos do mesmo plantão, preservando puzzles, dificuldade, personagens e duas falas por encontro.

A Fortaleza do Curto abriga uma guilda de vilões presa ao Contrato de Eternidade. Ninguém morre definitivamente ou consegue encerrar o expediente. Infrações geram multas elétricas; o choque quita a pena e devolve energia mágica à fortaleza. O condenado se recupera e volta ao trabalho.

O Executor quer terminar a fila e receber seu bônus. Descobre que a Diretoria inventa multas para compensar o desvio de energia para seu spa. O último circuito restaura o abastecimento e a ventilação, registra a fraude e encerra o plantão. Seu bônus é negado por interromper o spa, classificado como serviço essencial.

## Sequência da campanha

| Fases | Arco e evidências |
| --- | --- |
| 1–8 | Multas, imortalidade, geração de energia e promessa do bônus. Os apagões persistem e os relatórios não explicam as panes. |
| 9–16 | Ampliação do painel, recibos luminosos e ramais direcionais revelam prioridades da chefia e ordens adulteradas. |
| 17–23 | Inspeção da instalação central, alarmes, cópia do recibo e chave A/B expõem o ramal compartilhado com o spa. |
| 24 | Ventilador obrigatório permite encerrar o procedimento; o desvio é registrado, a fortaleza recebe energia e o bônus é negado. |

Cada fase recebe uma acusação/pergunta do Executor, uma resposta curta e uma consequência própria no resultado. Variações de resposta usam apenas características do arquétipo sorteado; não presumem que aquele nome já apareceu. A aparência continua aleatória, com sete bases, nomes e paletas atuais.

## Implementação

1. Registrar roteiro em `assets/narrative/campaign.json`; manter a seleção e a leitura sob responsabilidade de `EncounterStories`.
2. Selecionar o acontecimento pela fase e a resposta compatível pelo personagem. Preservar IDs 0–47 do catálogo anterior; novos encontros usam IDs 48–71.
3. Ao abrir save anterior, preservar nome, cor, base, recordes, desbloqueios e preferências. Substituir somente o encontro antigo pela história daquela fase, reapresentando as duas falas. Não alterar o esquema v7 nem criar um segundo progresso narrativo: a campanha já identifica o ponto da história.
4. Mostrar a premissa no menu; consequências somente nos resultados de vitória/derrota. Pausa e descarga não exibem consequências antecipadas. Na derrota, o procedimento foi cancelado e não houve multa. Rejogar fase concluída é uma reconstituição de processo arquivado.
5. Usar uma legenda curta no resultado, preservando pontos, estrelas, personagem, agradecimento e aviso de novas fases. Não acrescentar balões, cards, escolhas ou novas penalidades.
6. Atualizar testes de catálogo, seleção, migração, retomada, pausa, reconstituição, 24 consequências e encerramento. Conferir todos os textos nas três proporções e capturar exemplos com renderer real.
7. Incluir o JSON nos presets e conferir seus bytes nos pacotes. Incrementar versão para 0.24.0/código 41. Gerar APK e AAB pelo fluxo obrigatório `tools/dev.ps1 android -Release`, sem instalar ou enviar à loja automaticamente.

## Critérios de aceite

- As 24 fases contam uma história completa, em ordem, sem depender do sorteio de uma identidade específica.
- Cada encontro tem exatamente duas falas e todas cabem nos balões atuais; respostas de arquétipos permanecem compatíveis.
- Não há mudanças nos arquivos de fases, regras, tempo, dicas, pontuação, duração do choque, flash, tremor ou vibração.
- Saves anteriores mantêm seus dados; o novo encontro permanece estável ao reiniciar ou reabrir.
- Consequência aparece após a recuperação, nunca antes da vitória; timeout não registra sucesso narrativo.
- As suítes `test`, `effects-test` e `audio-test` e as auditorias de APK/AAB devem passar antes da entrega.

## Situação

Implementação concluída em 23 de novembro de 2026. Os sete passos foram executados. O roteiro tem 24 acontecimentos, 24 respostas alternativas por arquétipo (48 conversas atuais), 24 consequências e a premissa do menu. O catálogo anterior permanece preservado como legado.

Fluxo final `tools/dev.ps1 android -Release` aprovado: 75 testes Python, 44.079 verificações da engine, 831 estados de dicas, 3.772 verificações visuais/temporais e 48 de áudio, sem falhas. Foram testados o save v7 anterior, a preservação da aparência e dos recordes, a reapresentação da conversa atualizada, a retomada após reabrir, o bloqueio do relógio na conversa, pausa, reinício, derrota e reconstituição.

As 24 fases continuam solucionáveis com seus mínimos anteriores. Nenhum arquivo de fase ou regra de puzzle foi alterado. A inspeção das capturas confirmou os balões após sua animação de entrada e o resultado final legível. Capturas locais em `builds/lore/`, nas dimensões 360×800, 720×1280 e 720×1600.

APK e AAB 0.24.0/código 41 assinados com a mesma chave de upload e pacote `com.mprovensi.zapfry`, API 36 e alinhamento de 16 KB aprovados. A auditoria conferiu os bytes de `campaign.json` nos dois pacotes, além das fases e das 83 texturas. Os testes também rejeitam pacote sem roteiro ou com conteúdo diferente.

| Artefato local | SHA-256 |
| --- | --- |
| `builds/release/ZapFry-0.24.0.apk` | `0268c578941ea87a8ac93150851c2d1b17d4bd972a51d63e3038226d1bcf2b15` |
| `builds/release/ZapFry-0.24.0.aab` | `d255f8651b8e000abad9366217f933ec7692b5de60029512062b12d91a0f299e` |

Registros: `builds/lore-release.log`, `builds/verification.json` e `builds/release/release-audit.json`. Nenhuma instalação, partida no celular ou publicação na loja foi realizada nesta atualização. A avaliação humana do ritmo e do humor das conversas continua disponível como próximo playtest. A preservação do save se aplica a atualizações do mesmo pacote; a mudança anterior de `com.zapfry.prototype` para `com.mprovensi.zapfry` não transfere automaticamente dados entre esses apps.
