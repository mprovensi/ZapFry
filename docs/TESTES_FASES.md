# Testes de jogabilidade por fase

Relatório gerado por `python tools/validate_levels.py`. O resolvedor procura a solução com menos toques sem consultar a referência autoral.

| Fase | Nome | Mínimo de toques | Referência | Tempo | Cenário a 2 s/toque |
| --- | --- | --- | --- | --- | --- |
| 1 | Um toque e pronto | 1 | 1 | Livre | 2 s |
| 2 | Agora, uma curva | 2 | 2 | Livre | 4 s |
| 3 | Siga a faísca | 4 | 4 | Livre | 8 s |
| 4 | Sua vez, sem a seta | 6 | 6 | 180 s | 12 s |
| 5 | Pequeno desvio | 8 | 8 | 150 s | 16 s |
| 6 | Uma conexão em T | 8 | 8 | 180 s | 16 s |
| 7 | Fusível queimado | 9 | 9 | 180 s | 18 s |
| 8 | Tudo conectado | 10 | 10 | 180 s | 20 s |
| 9 | Painel maior, sem pressa | 6 | 6 | Livre | 12 s |
| 10 | Curvas no caminho | 12 | 12 | 150 s | 24 s |
| 11 | Um T no painel | 14 | 14 | 180 s | 28 s |
| 12 | Fusível no atalho | 16 | 16 | 180 s | 32 s |
| 13 | Corrente dividida | 18 | 18 | 180 s | 36 s |
| 14 | Contorno duplo | 20 | 20 | 180 s | 40 s |
| 15 | Fios e distrações | 22 | 22 | 180 s | 44 s |
| 16 | Engenheiro do setor | 24 | 24 | 180 s | 48 s |
| 17 | Setor de alta tensão | 26 | 26 | 210 s | 52 s |
| 18 | Curvas sob pressão | 28 | 28 | 210 s | 56 s |
| 19 | Ramificação oculta | 30 | 30 | 210 s | 60 s |
| 20 | Atalho interditado | 32 | 32 | 210 s | 64 s |
| 21 | Corrente em dois rumos | 34 | 34 | 225 s | 68 s |
| 22 | Rede cruzada | 36 | 36 | 225 s | 72 s |
| 23 | Último desvio | 38 | 38 | 225 s | 76 s |
| 24 | A chave geral | 40 | 40 | 225 s | 80 s |

O cenário temporal é uma hipótese de teste, não uma garantia de facilidade para todas as pessoas. Os testes na engine executam as sequências descobertas usando cliques e toques reais de entrada; não alteram diretamente a orientação das peças.

## Sequências descobertas

Coordenadas em linha/coluna, começando em 1. Coordenadas repetidas significam toques consecutivos na mesma peça.

- **Fase 1:** L1 C2.
- **Fase 2:** L1 C2 → L1 C4.
- **Fase 3:** L1 C2 → L2 C2 → L2 C3 → L2 C4.
- **Fase 4:** L1 C2 → L2 C2 → L3 C2 → L3 C3 → L3 C4 → L3 C4.
- **Fase 5:** L2 C1 → L2 C1 → L2 C2 → L2 C3 → L2 C3 → L3 C3 → L3 C4 → L3 C4.
- **Fase 6:** L2 C1 → L2 C1 → L2 C2 → L2 C3 → L2 C4 → L2 C4 → L3 C4 → L4 C4.
- **Fase 7:** L2 C1 → L3 C1 → L3 C1 → L3 C1 → L3 C2 → L3 C3 → L2 C3 → L2 C4 → L3 C4.
- **Fase 8:** L1 C2 → L1 C3 → L2 C3 → L3 C3 → L3 C3 → L3 C2 → L3 C2 → L4 C2 → L4 C2 → L4 C3.
- **Fase 9:** L1 C2 → L1 C3 → L1 C4 → L1 C5 → L2 C5 → L3 C5.
- **Fase 10:** L1 C2 → L1 C2 → L2 C2 → L3 C2 → L3 C2 → L3 C2 → L3 C3 → L3 C4 → L3 C5 → L3 C5 → L3 C5 → L4 C5.
- **Fase 11:** L2 C1 → L3 C1 → L3 C1 → L3 C1 → L3 C2 → L3 C3 → L2 C3 → L2 C3 → L2 C3 → L2 C4 → L2 C5 → L2 C5 → L3 C5 → L4 C5.
- **Fase 12:** L2 C1 → L3 C1 → L4 C1 → L4 C1 → L4 C2 → L4 C3 → L4 C3 → L4 C3 → L3 C3 → L3 C3 → L3 C3 → L3 C4 → L3 C5 → L3 C5 → L3 C5 → L4 C5.
- **Fase 13:** L1 C2 → L1 C2 → L1 C2 → L2 C2 → L2 C2 → L2 C1 → L2 C1 → L3 C1 → L4 C1 → L4 C1 → L4 C2 → L3 C2 → L3 C3 → L2 C3 → L2 C4 → L2 C5 → L3 C5 → L4 C5.
- **Fase 14:** L2 C1 → L2 C1 → L2 C1 → L2 C2 → L2 C3 → L2 C3 → L2 C3 → L1 C3 → L1 C3 → L1 C4 → L1 C5 → L1 C5 → L2 C5 → L3 C5 → L3 C4 → L3 C4 → L4 C4 → L5 C4 → L5 C4 → L5 C4.
- **Fase 15:** L1 C2 → L1 C2 → L1 C2 → L2 C2 → L2 C2 → L2 C1 → L2 C1 → L2 C1 → L3 C1 → L4 C1 → L4 C1 → L4 C1 → L4 C2 → L4 C3 → L4 C4 → L4 C4 → L3 C4 → L3 C4 → L3 C5 → L3 C5 → L3 C5 → L4 C5.
- **Fase 16:** L2 C1 → L3 C1 → L3 C1 → L3 C1 → L3 C2 → L3 C3 → L3 C3 → L3 C3 → L2 C3 → L2 C3 → L2 C4 → L2 C5 → L3 C5 → L3 C5 → L3 C4 → L4 C4 → L4 C4 → L4 C4 → L4 C3 → L4 C3 → L4 C3 → L5 C3 → L5 C3 → L5 C4.
- **Fase 17:** L1 C2 → L1 C2 → L2 C2 → L3 C2 → L3 C1 → L3 C1 → L4 C1 → L5 C1 → L5 C2 → L5 C2 → L4 C2 → L4 C3 → L4 C3 → L3 C3 → L2 C3 → L2 C3 → L2 C3 → L2 C4 → L2 C5 → L3 C5 → L4 C5 → L5 C5 → L5 C5 → L5 C6 → L5 C6 → L5 C6.
- **Fase 18:** L2 C1 → L3 C1 → L3 C1 → L3 C2 → L3 C2 → L3 C2 → L2 C2 → L1 C2 → L1 C3 → L1 C4 → L1 C4 → L2 C4 → L3 C4 → L3 C4 → L3 C3 → L3 C3 → L3 C3 → L4 C3 → L5 C3 → L5 C3 → L5 C3 → L5 C4 → L5 C5 → L4 C5 → L4 C5 → L4 C6 → L4 C6 → L5 C6.
- **Fase 19:** L1 C2 → L2 C2 → L2 C2 → L2 C1 → L2 C1 → L3 C1 → L4 C1 → L4 C2 → L3 C2 → L3 C2 → L3 C3 → L2 C3 → L1 C3 → L1 C4 → L1 C5 → L2 C5 → L3 C5 → L3 C5 → L3 C5 → L3 C6 → L4 C6 → L5 C6 → L5 C6 → L5 C6 → L5 C5 → L5 C4 → L6 C4 → L6 C4 → L6 C4 → L6 C5.
- **Fase 20:** L2 C1 → L3 C1 → L4 C1 → L5 C1 → L5 C1 → L5 C2 → L5 C2 → L4 C2 → L3 C2 → L3 C2 → L3 C3 → L3 C3 → L3 C3 → L2 C3 → L2 C3 → L2 C3 → L2 C4 → L2 C5 → L2 C5 → L1 C5 → L1 C6 → L1 C6 → L2 C6 → L3 C6 → L3 C6 → L3 C5 → L3 C5 → L3 C5 → L4 C5 → L5 C5 → L5 C5 → L5 C6.
- **Fase 21:** L1 C2 → L1 C3 → L1 C3 → L2 C3 → L2 C3 → L2 C2 → L2 C2 → L3 C2 → L4 C2 → L4 C1 → L4 C1 → L5 C1 → L6 C1 → L6 C1 → L6 C1 → L6 C2 → L6 C3 → L6 C3 → L5 C3 → L4 C3 → L4 C3 → L4 C4 → L4 C4 → L3 C4 → L2 C4 → L2 C4 → L2 C5 → L2 C5 → L2 C5 → L3 C5 → L4 C5 → L5 C5 → L5 C5 → L5 C6.
- **Fase 22:** L2 C1 → L2 C1 → L2 C2 → L2 C2 → L2 C2 → L1 C2 → L1 C2 → L1 C3 → L1 C4 → L2 C4 → L2 C4 → L2 C3 → L2 C3 → L3 C3 → L3 C3 → L3 C2 → L3 C1 → L3 C1 → L4 C1 → L5 C1 → L5 C1 → L5 C2 → L5 C3 → L5 C3 → L6 C3 → L6 C3 → L6 C4 → L6 C5 → L6 C5 → L6 C5 → L5 C5 → L4 C5 → L4 C5 → L4 C6 → L4 C6 → L5 C6.
- **Fase 23:** L1 C2 → L1 C3 → L1 C3 → L2 C3 → L2 C3 → L2 C3 → L2 C2 → L2 C1 → L2 C1 → L2 C1 → L3 C1 → L4 C1 → L4 C2 → L4 C2 → L5 C2 → L6 C2 → L6 C3 → L6 C4 → L6 C4 → L6 C4 → L5 C4 → L4 C4 → L4 C4 → L4 C4 → L4 C5 → L4 C5 → L3 C5 → L3 C5 → L3 C6 → L3 C6 → L4 C6 → L5 C6 → L5 C6 → L5 C5 → L5 C5 → L6 C5 → L6 C5 → L6 C5.
- **Fase 24:** L1 C2 → L2 C2 → L2 C2 → L2 C1 → L2 C1 → L2 C1 → L3 C1 → L4 C1 → L4 C2 → L4 C2 → L3 C2 → L3 C2 → L3 C3 → L3 C3 → L3 C3 → L2 C3 → L1 C3 → L1 C3 → L1 C4 → L1 C5 → L1 C6 → L1 C6 → L2 C6 → L2 C6 → L2 C6 → L2 C5 → L2 C5 → L3 C5 → L3 C5 → L3 C6 → L3 C6 → L4 C6 → L5 C6 → L5 C6 → L5 C5 → L5 C4 → L5 C4 → L6 C4 → L6 C4 → L6 C5.

## Resultado na interface da engine

Quatro cenários por fase: mouse e toque nas dimensões 720×1280 e 360×800. Cada cenário verifica pausa, peças não giráveis, reinício, solução independente, resultado e progressão. As fases com relógio também verificam derrota por tempo e nova tentativa.

| Fase | Cenários aprovados | Resultado |
| --- | --- | --- |
| 1 | 4 / 4 | APROVADA |
| 2 | 4 / 4 | APROVADA |
| 3 | 4 / 4 | APROVADA |
| 4 | 4 / 4 | APROVADA |
| 5 | 4 / 4 | APROVADA |
| 6 | 4 / 4 | APROVADA |
| 7 | 4 / 4 | APROVADA |
| 8 | 4 / 4 | APROVADA |
| 9 | 4 / 4 | APROVADA |
| 10 | 4 / 4 | APROVADA |
| 11 | 4 / 4 | APROVADA |
| 12 | 4 / 4 | APROVADA |
| 13 | 4 / 4 | APROVADA |
| 14 | 4 / 4 | APROVADA |
| 15 | 4 / 4 | APROVADA |
| 16 | 4 / 4 | APROVADA |
| 17 | 4 / 4 | APROVADA |
| 18 | 4 / 4 | APROVADA |
| 19 | 4 / 4 | APROVADA |
| 20 | 4 / 4 | APROVADA |
| 21 | 4 / 4 | APROVADA |
| 22 | 4 / 4 | APROVADA |
| 23 | 4 / 4 | APROVADA |
| 24 | 4 / 4 | APROVADA |

## Seletor, progresso e dica gratuita

- Dica gratuita: **24 / 24 fases aprovadas** após corrigir e prender um fio.
- Seletor: grupos 4×4, 5×5 e 6×6, bloqueios, seleção de fases concluídas e navegação em janela estreita.
- Recordes: melhores estrelas, pontuação e tempo por fase, sem redução ao rejogar.
- Persistência: gravação/releitura, atualização da cópia de segurança e recuperação de perfil inválido.
- Migração: desbloqueios e preferências antigos preservados, sem inventar recordes desconhecidos.

## Dicas em partidas parciais e com erros

**730 estados aprovados**, com conferência independente em Python antes e depois da dica realmente aplicada pelo Godot.
Inclui 26 regressões com T já conectado, rota montada a partir da entrada/saída, rotações incorretas, simetrias e tabuleiros impossíveis.
Toda dica concedida reduz os giros mínimos restantes e permite concluir pela engine; a simulação parte do estado de teste com o cronômetro integral e usa dois segundos por giro restante.

| Fase | Estados com dica útil e conclusão |
| --- | --- |
| 11 | 41 |
| 12 | 39 |
| 13 | 40 |
| 14 | 41 |
| 15 | 41 |
| 16 | 41 |
| 17 | 40 |
| 18 | 41 |
| 19 | 41 |
| 20 | 41 |
| 21 | 41 |
| 22 | 41 |
| 23 | 41 |
| 24 | 42 |
