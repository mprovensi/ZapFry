# Testes obrigatórios antes de entregar

**Atualizado em 5 de novembro de 2026.** Aplicável ao protótipo 0.15.0 e às próximas alterações.

## Fluxo oficial

```powershell
# Conferir tudo, sem exportar nem instalar
./tools/dev.ps1 verify

# Cada comando abaixo executa novamente toda a verificação antes de exportar
./tools/dev.ps1 android
./tools/dev.ps1 windows

# Verificar, exportar um APK novo, transferir e instalar preservando o save
./tools/dev.ps1 install

# Escolher o alvo quando houver mais de um aparelho
./tools/dev.ps1 install -DeviceSerial 'SERIAL_CONFIRMADO'
```

Android, Windows e instalação executam obrigatoriamente, nesta ordem:

1. **`test`**: testes Python, auditor independente das 24 fases, geração de 730 estados de dicas, suíte Godot e auditoria independente dos resultados das dicas.
2. **`effects-test`**: simulação temporal e renderização OpenGL real do tremor, flashes, matriz e cabeçalho.
3. **`audio-test`**: mixagem, silêncio, pausa, retomada e três ciclos do OGG decodificados.

Só depois de todas as etapas aprovadas é permitida a exportação. Instalação exige também exportação bem-sucedida. Qualquer saída diferente de zero interrompe o fluxo; não há opção para ignorar testes. A indisponibilidade do renderer também bloqueia a entrega.

Depois de exportar, o Android passa por uma auditoria do APK: JSONs das fases devem ser idênticos às fontes; retratos, esqueleto, menu e poses do goblin precisam ter os imports e suas texturas compiladas presentes. Fontes de testes, ferramentas e rascunhos não podem entrar no pacote. O Windows executa um teste de inicialização do EXE exportado, em modo isolado, com prazo de 30 segundos e conferência do log. Falhas nessas etapas também bloqueiam a entrega/instalação.

O SHA-256 dos arquivos de código, assets, fases, cenas, testes, ferramentas e configurações é comparado antes/depois da verificação e depois da exportação. Mudanças durante essas etapas bloqueiam a entrega. Saídas de testes, documentação e caches gerados não fazem parte dessa comparação. Um bloqueio exclusivo impede duas entregas simultâneas de disputarem relatórios e artefatos.

O resultado do conjunto de verificações fica em `builds/verification.json`, com status, horários UTC, suites concluídas e fingerprint das fontes. Esse relatório não substitui os testes: cada entrega os executa novamente.

**Usar este fluxo em todas as entregas.** Exportar diretamente pelo editor, executar ADB manualmente ou reutilizar scripts históricos de `builds/` contorna a barreira. A regra para futuras alterações está em `AGENTS.md`.

## Cobertura das partes sensíveis

| Área | Proteções verificadas automaticamente |
| --- | --- |
| Fases e dicas | Solução independente das 24 fases; mouse/toque; 730 estados com dicas; T já válido, peças fixas e tabuleiros sem solução; dica não piora a solução. |
| Tremor | 30, 60 e 120 FPS; modos normal/suave; preferência de vibração ligada/desligada; alternância de direção, limites, redução da força e fim do efeito. |
| Renderização do impacto | Pixels da parede realmente mudam; matriz e textos permanecem no lugar; não surgem bordas vazias; parede volta à posição original; clarão ilumina placas opacas e não cobre o cabeçalho. |
| Condenado e resultado | Esqueleto durante todo o choque nos dois modos; resultado não encobre a sequência; conclusão e som de choque únicos; reinício/menu não deixam efeito residual. |
| Relógio e segundo plano | Pausa antes/depois da primeira jogada; retorno não retoma sozinho; tempo parado, giros e dicas bloqueados; ajustes permanecem abertos e retornam à pausa. |
| Áudio | Volumes separados; zero em um canal não silencia o outro; mute geral; música em zero ao abrir; religar durante a pausa; alerta e vitória sem repetição; loop decodificado. |
| Perfil e migração | Recordes, desbloqueios e ponto de continuação; valores inválidos; recuperação por backup; preferências antigas; temporário interrompido ignorado; falhas de escrita/cópia não substituem dados válidos. |
| Segurança dos testes | Runners principais recusam execução sem `-- --test`; testes Godot não gravam o perfil real. |
| Barreira de entrega | Falha em cada suíte impede exportar/instalar; falha de exportação não instala APK antigo; Windows também é bloqueado; alterações durante testes/exportação interrompem entrega; entrega concorrente é recusada. |
| Pacote exportado | APK contém fases corretas e texturas compiladas, inclusive o esqueleto; fontes de testes ficam fora; erro na auditoria do APK impede instalar; EXE Windows exportado inicia sem erros em modo isolado. |
| Instalação Android | Alvo USB autorizado e inequívoco; pacote correto; APK posterior à verificação; SHA-256 local/remoto igual; versão instalada conferida; VIBRATE presente/concedida; save comparado byte a byte; processo e erros de inicialização conferidos. |

## Testes acrescentados nesta revisão

- `tests/execution_effect_tests.gd`: sequência avançada por `_process` em diferentes taxas de quadros, preferências, quadros demorados e limpeza ao interromper.
- `tests/run_effect_tests.gd`: comparação de imagens do renderer real em 360×800, 720×1280 e 720×1600. Evidências em `builds/effects/`.
- `tests/profile_tests.gd`: falha ao criar backup, falha no temporário, retry e preservação do backup saudável durante recuperação.
- `tests/run_tests.gd`: segundo plano/retomada e recusa sem modo de teste.
- `tests/test_deploy_pipeline.py`: executa o script PowerShell real em um projeto temporário, usando compilador e comandos de teste simulados. Prova os bloqueios sem gerar APK real ou acessar USB.
- `tests/test_android_install.py`: verifica seleção de alvo, integridade, perfil, versão, permissão e falhas de inicialização com ADB simulado.
- `tests/test_android_package.py`: verifica bloqueio de fases ausentes/diferentes, esqueleto compilado ausente e inclusão indevida de fontes de teste no APK.

As simulações do instalador complementam as suítes reais da engine. Não jogam fases no celular e não criam conquistas no perfil do usuário.

## Relatórios e reprodução

| Arquivo | Conteúdo |
| --- | --- |
| `builds/verification.json` | Resultado do conjunto obrigatório. |
| `builds/tests.log` | Suíte Godot de lógica, interface, persistência e efeitos. |
| `builds/effects-tests.log` | Sequência e renderização dos efeitos. |
| `builds/effects/results.json` | Contagens, dimensões e métricas de pixels. |
| `builds/effects/*.png` | Cena estável, tremor e clarão em cada dimensão. |
| `builds/audio-tests.log` | Reprodução, mixagem e ciclos do OGG. |
| `builds/windows-smoke.log` | Inicialização do executável exportado, sem usar o perfil do jogador. |
| `builds/android/install-*/status.json` | Resultado de cada instalação pelo novo fluxo. |
| `builds/android/install-*/profile-before.cfg` e `profile-after.cfg` | Cópias do perfil para comparação quando já existe save. |

Executar `./tools/dev.ps1 effects-test` para repetir somente a validação visual/temporal, ou `./tools/dev.ps1 test` para lógica, interface e persistência. Isso não dispensa o conjunto completo ao entregar.

## Resultado desta revisão

`./tools/dev.ps1 windows` concluiu o fluxo real completo: **40 testes Python, 38.790 verificações da engine, 730 estados de dicas, 3.306 verificações de efeitos e 48 de áudio, sem falhas**. A exportação Windows e o teste de inicialização do EXE passaram. O APK existente foi auditado separadamente: fases idênticas às fontes e 28 texturas PNG importadas presentes, incluindo o esqueleto. Nenhuma instalação foi feita no celular nesta revisão. Evidência consolidada em `builds/deployment-validation.json`.

## Limites da automação

Os testes visuais usam o renderer real do computador. Confirmam comportamento e pixels, mas não medem o FPS do celular nem a sensação física do motor de vibração. A instalação confere a permissão VIBRATE; intensidade e funcionamento do motor, conforto dos flashes e mixagem no alto-falante continuam sendo verificações em aparelho.

Os cinco novos condenados e seus diálogos ainda estão planejados. Seus testes serão incluídos quando forem implementados, antes da próxima entrega desse conteúdo.
