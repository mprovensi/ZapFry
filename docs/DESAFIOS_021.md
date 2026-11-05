# Lâmpadas obrigatórias — 0.21.0

Primeira entrega do [plano de desafios](../PLANO_DESAFIOS_FASES_EXISTENTES.md).

- Fase 10: ligar OUT e a lâmpada indicada no caminho. Mínimo de 12 giros, 150 segundos.
- Fase 11: alimentar a lâmpada em um ramo do T e ligar OUT. Mínimo de 14 giros, 180 segundos.
- Fases 1–9 e 12–24 conservam as regras anteriores. A autoria define onde há desafios; o jogador cumpre os objetivos presentes naquela fase.

O ícone permanece no canto da célula, sem girar com o fio. Apagado, possui contorno claro e interior escuro; aceso, ganha luz e raios. O cabeçalho mostra `LÂMPADA 0/1` ou `1/1`. Se OUT estiver ligado sozinho, o feedback informa que falta acender a lâmpada. A descarga, o flash, o esqueleto e a vibração continuam aguardando a condição completa do modelo.

## Modelo e dicas

`required_nodes` é uma lista opcional de índices de células que precisam estar energizadas pela mesma fonte que OUT. A ausência do campo mantém o puzzle clássico. A validação rejeita índices inválidos, repetidos, fracionários, vazios, bloqueados ou redundantes com os terminais. Dados inválidos impedem vitória e dica.

`CircuitBoard` continua responsável pela energia e pela vitória. Sua avaliação sem efeitos colaterais permite verificar uma configuração candidata sem alterar a partida nem invalidar o cache. As dicas usam somente o estado atual e respeitam todas as peças fixas.

O resolvedor clássico permanece para fases sem lâmpadas. Com objetivos extras, sua solução é aproveitada quando já satisfaz todos eles: o mínimo até OUT é também um limite inferior da rede completa. Caso contrário, a busca de rede conecta cada objetivo à rede da fonte, considera todas as orientações compatíveis dos T e conta cada peça uma vez. Distâncias relaxadas apenas podam candidatos; a propagação completa do modelo confirma a resposta. Nenhuma dica consulta `solution` ou `reference_path`.

O auditor Python também representa redes com ramos. Oráculos exaustivos de orientações em 2×2 e 3×3 conferem o custo mínimo, incluindo ciclos, fonte móvel, duas lâmpadas e estados impossíveis. A validação da referência autoral passou a incluir também as orientações de peças fora do caminho principal.

## Recordes e compatibilidade

As fases 10 e 11 declaram `rules_revision: 2`; as demais continuam na revisão 1. O perfil v7 importa registros antigos como revisão 1. A primeira vitória sob uma regra diferente arquiva o registro anterior, mantendo estrelas, tempo, pontuação e contagem de conclusões no histórico. A comparação de melhores resultados ocorre somente entre revisões iguais.

O seletor identifica um resultado da regra anterior com `REGRA NOVA`, pontuação anterior e convite para rejogar. Desbloqueios, conclusões, preferências, personagem e gravação com backup continuam preservados. O histórico permanece no save; não há uma tela nova dedicada a ele nesta entrega.

## Validação e entrega

Fluxo obrigatório aprovado: **49 testes Python, 41.050 verificações da engine, 761 estados de dicas, 3.589 verificações visuais/temporais e 48 de áudio**. Conferência independente das soluções das 24 fases, inclusive execução por mouse e toque; zero falhas nas suítes finais. Os novos testes fazem parte das verificações exigidas em toda exportação e instalação.

Cobertos objetivo pendente, ausência de descarga prematura, dica no ramo, pausa, migração dos recordes e renderização do símbolo apagado/aceso nas três proporções. Capturas em `builds/lamps/`; relatórios em `builds/hint-stress-results.json`, `builds/effects/results.json` e [TESTES_FASES.md](TESTES_FASES.md). A maior consulta nativa de dica medida na primeira execução completa foi 13,48 ms neste computador; não é uma medição do celular.

APK/código 34 exportado, com fases idênticas às fontes e 83 texturas conferidas. Instalado no S20 FE/SM-G781B após restabelecer a conexão do ADB e repetir o fluxo completo. Versão correta, permissão VIBRATE concedida, perfil idêntico antes/depois e inicialização sem erros. Registro em `builds/android/install-20261105T214431411815Z/status.json`; log em `builds/deploy-v0210-install-retry.log`. SHA-256 do APK: `e5c33a4b6c8b135761ceaa88b971c1bf9fd2bcd2578e098a4a5cc3451037e869`.

As simulações usam perfil isolado. Nenhuma partida é automatizada no aparelho do usuário. Sentido único, alarmes, interruptores, duplas e segundo equipamento permanecem para as próximas entregas.
