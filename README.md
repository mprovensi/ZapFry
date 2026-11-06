# Zap & Fry — protótipo 0.21.4

[Repositório público](https://github.com/mprovensi/ZapFry).

**Revisão 0.21.4:** música aumentada em 6 dB, de −14 para −8 dB no nível máximo dos ajustes. Durante o choque, passa de −22 para −16 dB, preservando a redução de 8 dB para destacar o zap. Preferências de volume e efeitos preservados.

**0.21.4 pronta para instalar:** suítes obrigatórias e auditoria do APK/código 38 aprovadas. A instalação ficou pendente porque o celular não apareceu no ADB; última instalação confirmada: 0.21.3.

**Revisão 0.21.3:** o fundo claro da sala começa na linha divisória do cabeçalho, em 112 unidades, retirando a faixa escura restante. Clarão e área de conversa usam esse mesmo limite.

**Revisão 0.21.2:** sala, grade e atores elevados em 8 unidades; fundo alinhado ao recorte do cabeçalho para remover a faixa duplicada. O tremor usa uma base fixa para cobrir as bordas, sem ampliar a textura. Controles, regras e progresso mantidos.

**Revisão 0.21.1:** cabeçalho e rodapé da partida usam a textura e o sombreamento da pausa, substituindo as faixas quase pretas. Textos com contorno, legendas maiores e botões inferiores com tamanhos iguais e margens simétricas. Detalhes em [docs/INTERFACE_PARTIDA_0211.md](docs/INTERFACE_PARTIDA_0211.md).

**Novidade 0.21.0:** lâmpadas obrigatórias nas fases 10 e 11, com ícone apagado/aceso, contador no cabeçalho e aviso quando OUT está ligado mas falta a lâmpada. A fase 11 usa um ramo do T; dicas resolvem a rede completa. Mantidos os mínimos de 12/14 giros e os tempos de 150/180 s. As demais fases continuam clássicas. Recordes anteriores ficam preservados por revisão de regras no perfil v7. Detalhes em [docs/DESAFIOS_021.md](docs/DESAFIOS_021.md).

**Novidade 0.20.0:** concluir a fase 24 apresenta uma tela final com agradecimento por jogar e aviso de que mais fases virão. Mantidos cenário, personagem, estrelas, pontuação e ações de jogar do início ou voltar ao menu, preservando conquistas. Detalhes em [docs/TELA_FINAL_020.md](docs/TELA_FINAL_020.md).

**Revisão 0.19.2:** fundo da tarja do nome removido; identificação em negrito diretamente sobre o papel do balão. A fonte das falas foi reduzida de 40 para 36. Mantidas as 48 conversas curtas e a ausência dos contadores de passos.

**Revisão 0.19.1:** contadores de passos removidos dos balões. O nome aparece em tarja colorida, com fonte maior e negrito. O catálogo dobrou para 48 conversas curtas, incluindo casos próprios para cada base, mantendo duas falas por encontro e os IDs anteriores.

**Novidade 0.19.0:** balões de quadrinhos com papel claro tingido por personagem, contorno grosso, cauda curva e texto escuro. O nome avulso ao lado da cadeira foi removido; a identificação continua no diálogo. Zumbi **Zeca Soneca** e elfa adulta **Líria Faísca** entram no sorteio com espera, choque e recuperação próprios: sete bases, 35 nomes e 140 combinações de nome/cor. Arte, prompts e integração em [docs/SPRITES_019_PROMPTS.md](docs/SPRITES_019_PROMPTS.md).

**Novidade 0.18.0:** Executor pisca e reage à própria fala; os cinco condenados fazem pequenos movimentos de cabeça ao responder. Balões entram suavemente, alavanca recebe transições curtas entre poses e o retrato acomoda o movimento na recuperação. Os dois balões, a fonte maior, a pausa e o esqueleto durante o choque são preservados. Detalhes e prévia em [docs/ANIMACOES_018.md](docs/ANIMACOES_018.md).

**Revisão 0.17.1:** dois balões por encontro — Executor e condenado —, 24 conversas reescritas, cores próprias por personagem e texto 33% maior. A apresentação mantém Pular, pausa e bloqueio da matriz. Detalhes em [docs/ENCONTROS_017.md](docs/ENCONTROS_017.md).

**0.21.3 instalada no S20 FE:** atualização/código 37 conferida, save preservado e inicialização sem erros. Testes obrigatórios e auditoria das 83 texturas do APK aprovados. Rejogue as fases 10 e 11 pelo seletor para experimentar as lâmpadas. Capturas da nova interface em `builds/game-chrome/`; avaliação humana do acabamento no aparelho permanece pendente.

Puzzle de rotação de fios com humor macabro e visual em Cartoon 2D com sprites substituíveis.
Desenvolvido em **Godot 4.7.2 estável, GDScript e renderer Compatibility**.

**0.16.0 instalada no S20 FE:** cinco condenados com poses próprias de espera, esqueleto e recuperação, sorteio sem repetição imediata e 25 nomes. O nome aparece ao lado da cadeira. Reiniciar ou reabrir a fase mantém o condenado; perfil v5 preserva progresso e preferências. Testes completos e auditoria do APK aprovados. Integração e prompts em [docs/CONDEMNED_POSES_016.md](docs/CONDEMNED_POSES_016.md).

**Novidade 0.15.0:** **Ajustes** no menu principal e na pausa, com volumes independentes de música/efeitos, som geral, vibração e flashes. Volumes de 0–100%, gravados no aparelho; abrir os ajustes durante uma partida mantém o cronômetro pausado e Voltar retorna à pausa. Perfis antigos conservam progresso, preferências e a mixagem anterior. Versão instalada no S20 FE (SM-G781B), com perfil idêntico após instalar. Detalhes em [docs/AJUSTES.md](docs/AJUSTES.md).

**Novidade 0.17.0:** 24 histórias curtas em balões antes das fases, com avanço por toque/teclado e botão Pular. Quatro paletas de roupa por base e 25 nomes permitem 100 combinações. Introduções não consomem tempo nem permitem girar fios; pausa e Ajustes preservam a fala atual. O perfil v6 mantém o encontro e o progresso. Integração e testes em [docs/ENCONTROS_017.md](docs/ENCONTROS_017.md).

Correção 0.14.6: o clarão da descarga aparece sobre a área da partida, incluindo a matriz, com transparência que mantém o esqueleto visível. Antes, as placas cobriam o efeito desenhado no fundo. Cabeçalho e rodapé permanecem livres do clarão. Diagnóstico e teste de pixels em [docs/FLASH_DESCARGA.md](docs/FLASH_DESCARGA.md). Versão 0.14.6 instalada no SM-G781B, com flashes normais ativados e progresso preservado.

Na **0.14.5**, o menu usa a opção 2 de cadeira e fios, independente do goblin. O esqueleto agora aparece durante o choque também com flashes suaves; esse modo antes usava a pose de espera. Mantidos o cabeçalho simplificado da 0.14.4, Menu pela pausa e flashes normais por padrão em novos perfis. Integração e diagnóstico em [docs/MENU_CADEIRA.md](docs/MENU_CADEIRA.md). Revisão 0.14.5 instalada no Samsung A5 (SM-A520F), com versão e abertura conferidas; progresso preservado.

Ícone do aplicativo com goblin engenheiro, óculos e raio, incluindo camadas adaptativas Android e versão Windows. Arte, prompt e integração em [docs/ICONE_APP.md](docs/ICONE_APP.md).

Acabamento 0.14.2: mão direita e alavanca do goblin corrigidas, pisos que atravessam toda a sala e trilha lo-fi sombria original em loop. O botão **Começar de novo**, na tela **Fases**, volta ao menu com a fase 1 selecionada, mantendo recordes e desbloqueios. A escolha permanece após fechar o jogo; Continuar acompanha a nova sequência. Arte e prompts em [docs/ACABAMENTO_GOBLIN_PISO.md](docs/ACABAMENTO_GOBLIN_PISO.md); autoria e áudio em [docs/TRILHA_SONORA.md](docs/TRILHA_SONORA.md).

Na **0.14.3**, a trilha passa a um tema de mansão assombrada mais sóbrio: órgão, baixo marcado e celesta, **120 BPM**, loop original de 64 segundos. Volume normal aumentado em **6 dB**, com redução de 8 dB durante a descarga. Mantidos som, pausa e segundo plano. A suíte dedicada de áudio/acabamento passou com **48 verificações**, incluindo três ciclos reais do OGG em teste acelerado; detalhes em `builds/audio-tests.log`. Executar `./tools/dev.ps1 audio-test`.

## Jogar

- **Android:** instalar `builds/zap-fry-prototype.apk` em um aparelho com Android 7.0 (API 24) ou superior e arquitetura ARM64 ou x86_64. É uma build de depuração assinada para testes locais, não para envio à loja.
- **Windows (último pacote local 0.15.0):** executar `builds/windows/ZapFry.exe` ou extrair o pacote `builds/ZapFry-Windows.zip` e executar `ZapFry.exe`. Não é necessário instalar o Godot para usar essa versão.
- **Editor:** importar `project.godot` no Godot 4.7.2 e pressionar **F6** para a cena aberta ou **F5** para o projeto.
- **Terminal PowerShell:** `./tools/dev.ps1 play`.

No menu, selecionar **Jogar** ou **Continuar**. Clicar ou tocar em uma peça para girar 90° no sentido horário. Fios com brilho ciano estão energizados; conectar a entrada **IN** à saída **OUT**, cuja posição varia conforme a fase. Na primeira fase, basta um toque no fio destacado.

As três primeiras fases têm seta de orientação e **nenhum limite de tempo**. Depois, o relógio começa na primeira jogada válida: três minutos na fase 4 e dois minutos e meio na fase 5. Espaços vazios não giram e não precisam ser preenchidos. Cadeados identificam fios já posicionados e fixos; os parafusos das placas são decorativos. Não é preciso energizar todos os fios.

A fase 6 apresenta o T com orientação visual: uma ponta extra pode ficar aberta. A fase 7 apresenta o fusível queimado, marcado com X, que precisa ser contornado. A fase 8 combina as duas regras. As três oferecem três minutos.

As fases 9–16 usam uma grade 5×5. A fase 9 continua guiada e sem cronômetro. A fase 10 introduz a lâmpada obrigatória, com mínimo de 12 giros e 150 segundos. Na 11, a lâmpada usa um ramo do T, com mínimo de 14 giros. As fases 11–16 têm seis fios de distração e **180 segundos** cada. Os mínimos continuam crescendo de 14 a 24 giros; a fase 12 permanece clássica para variar o ritmo.

As fases 17–24 completam a campanha em grade 6×6, com mínimos de 26 a 40 giros. Cada painel tem oito fios de distração e dois fusíveis; 17–20 oferecem **210 segundos** e 21–24 oferecem **225 segundos**. A conclusão da fase 24 encerra a campanha. O cabeçalho mostra **FASE NN / 24** em destaque; pausa e resultado também identificam a fase.

A vitória dispara automaticamente o zap e oferece **Próxima fase**. O menu permite jogar ou continuar o progresso. Para repetir desde a primeira fase, abrir **Fases** e selecionar a fase 1. **Fases** abre três setores com oito fases cada, mostrando bloqueios, estrelas, melhor pontuação e melhor tempo. É possível repetir qualquer fase desbloqueada sem perder os recordes. Reiniciar repete a tentativa atual sem limite de vezes. A fase antiga foi retirada da campanha introdutória e preservada apenas como teste de regressão.

**Dica grátis:** uma utilização por tentativa corrige e trava um fio de uma solução calculada a partir do **tabuleiro atual**, respeitando os fios já fixos. A dica procura a rede com menos giros restantes, incluindo os ramos das lâmpadas nas fases que as exigem. Um T que liga OUT pode precisar mudar para alimentar também a lâmpada. O fio recebe contorno verde e um ✓ até reiniciar; o texto informa sua linha e coluna, contadas a partir de 1. Os giros necessários contam nas jogadas; a dica pode concluir a fase. Reiniciar restaura o fio e a oportunidade de dica. Não há anúncio ou compra para utilizá-la.

| Fase | Aprendizado | Toques na solução de referência | Tempo |
| --- | --- | --- | --- |
| 1 | Girar um fio reto | 1 | Livre |
| 2 | Continuar até uma curva | 2 | Livre |
| 3 | Seguir a corrente e a seta | 4 | Livre |
| 4 | Montar o caminho sem seta | 6 | 180 s |
| 5 | Ignorar fios de distração | 8 | 150 s |
| 6 | Usar conexão em T, com seta de orientação | 8 | 180 s |
| 7 | Contornar fusível queimado | 9 | 180 s |
| 8 | Combinar T e fusível | 10 | 180 s |
| 9 | Adaptar-se ao painel 5×5, com seta | 6 | Livre |
| 10 | Acender a lâmpada e ligar OUT | 12 | 150 s |
| 11 | Alimentar a lâmpada por um ramo do T | 14 | 180 s |
| 12 | Contornar o atalho bloqueado | 16 | 180 s |
| 13 | Separar ramificações e distrações | 18 | 180 s |
| 14 | Contornar dois fusíveis | 20 | 180 s |
| 15 | Resolver sob maior pressão | 22 | 180 s |
| 16 | Concluir o setor 5×5 | 24 | 180 s |
| 17 | Continuar o desafio em 6×6 | 26 | 210 s |
| 18 | Interpretar curvas sob pressão | 28 | 210 s |
| 19 | Encontrar a ramificação útil | 30 | 210 s |
| 20 | Evitar atalhos interrompidos | 32 | 210 s |
| 21 | Selecionar a rota da corrente | 34 | 225 s |
| 22 | Desfazer a rede cruzada | 36 | 225 s |
| 23 | Encontrar o último desvio | 38 | 225 s |
| 24 | Fechar a chave geral | 40 | 225 s |

**Pausa:** botão na tela ou Escape. O aplicativo também pausa ao perder o foco ou ir para segundo plano. Retomar pelo botão Continuar. O botão Voltar do Android pausa/retoma durante a tentativa, retorna ao menu no resultado e fecha o aplicativo no menu.

Som e redução de flashes ficam no menu. Flashes suaves são o padrão. Recordes por fase, fases desbloqueadas e preferências são guardados localmente em `user://prototype.cfg`, com escrita temporária e cópia de recuperação. O melhor tempo considera somente o tempo ativo da tentativa, sem pausa ou animação de conclusão. Atualizações preservam os desbloqueios antigos; como versões anteriores não guardavam recordes individuais, essas fases mostram “Recordes por registrar” até serem repetidas. Treinos sem tempo concedem três estrelas ao concluir, sem penalizar a demora.

## Entregue neste marco

- Menu, puzzle e resultado de vitória/derrota, com número da fase em destaque durante o jogo.
- Campanha completa de 24 fases autorais: oito em cada grade, 4×4, 5×5 e 6×6. Introdução fácil até a fase 9 e desafio crescente da 10 à 24, com fios retos e curvos, T, distrações e fusíveis queimados.
- Mouse e toque nativo; prevenção de rotação duplicada por mouse emulado.
- Busca de energia por portas recíprocas, com suporte a ciclos e rotas alternativas.
- Tutorial com destaque do próximo fio, treino sem tempo, temporizador nas fases seguintes, giros, pausa, reinício, pontuação, estrelas e progressão persistente.
- Seletor de fases por tamanho de grade, recordes individuais, migração dos saves anteriores e recuperação por backup.
- Uma dica gratuita por tentativa, corrigindo e travando um fio sem impedir a conclusão das 24 fases.
- Pacote visual substituível: PNGs derivados dos conceitos, com placa metálica, fios normais/energizados, fusível, reinício, botão vermelho, laboratório, goblin engenheiro e cavaleiro/cadeira em três poses. Os pacotes SVG anteriores continuam disponíveis.
- Desenho geométrico quando uma camada/textura não foi atribuída, sons sintetizados e animação própria para flashes suaves.
- Acabamento de laboratório industrial, iluminação suave, antecipação do choque, vibração visual, recuperação com fumaça e faíscas nos fios recém-energizados.
- Nove sons próprios: interface, giro, bloqueio, dica, choque, vitória, derrota, alerta e ambiente; canais separados e controle de som imediato.
- Exportação Android configurada e testes de lógica e interface.

Este marco entrega campanha, seletor, dica gratuita e acabamento visual/sonoro Cartoon. Próximos marcos incluem validação em outros aparelhos e preparação de publicação; AdMob, consentimento de anúncios e compras continuam fora da build atual. Não há anúncios, compras nem dependência de rede no jogo atual.

## Menu e resultado — 0.14

Menu, partida e resultado usam a mesma proporção e cenário. O menu mostra título, goblin, **Jogar/Continuar**, **Fases** e os ajustes de som/flashes. Foram retirados os cards, textos longos, selos e informações de protótipo. A repetição da fase 1 fica no seletor.

Ao concluir, o resultado destaca o ocupante da cadeira, estrelas, pontuação e a próxima fase, sem o card central ou recordes repetidos. O tempo aparece somente em fases cronometradas. Pausa e derrota seguem a mesma apresentação, com duas ações claras. Recordes continuam salvos e disponíveis no seletor. A tela de resultado aguarda os mesmos 2,40 s de animação.

## Vibração física — correção 0.13.1

O início da descarga agora chama `Input.vibrate_handheld(800)` uma única vez e o APK declara `android.permission.VIBRATE`. A vibração física é independente do som e da preferência visual de flashes suaves; continua sujeita às configurações do Android. A correção mantém os flashes, o tremor visual e a animação de 2,40 s.

## Impacto ao fechar o circuito

A versão 0.13 prolonga a sequência para 2,40 s. O goblin abaixa a chave nos primeiros 0,40 s; o choque segue até 1,75 s, com tremor curto e três clarões transparentes sobre a partida, e então vem a recuperação. A parede vibra; o ocupante e a matriz mantêm posição, com o esqueleto legível durante os clarões. Cabeçalho e rodapé ficam livres do efeito. O modo de flashes suaves usa uma iluminação gradual sem tremor. O resultado só aparece ao terminar a animação; esse intervalo não consome o relógio.

## Cabos externos

A versão 0.12.2 usa mangueiras corrugadas, conectores de latão e abraçadeiras para ligar visualmente a chave do goblin ao IN e o OUT à cadeira. Os trajetos acompanham a entrada/saída de cada fase e os encaixes dos sprites, passando pelas laterais da matriz. O conector da cadeira acende somente depois de abaixar a chave. O ponto de conexão do ocupante é ajustável no recurso independente do personagem.

## Sala contínua e controles

A versão 0.12.1 reúne os atores e a grade em uma única sala, sem cards explicativos ou molduras entre setores. O cabeçalho compacto mostra fase, grade, tempo e giros, com menu e pausa. A carga aparece em um medidor na parede ao lado do goblin; o rodapé reúne feedback, reinício e dica em botões maiores. Fontes e prompt do novo cenário: [docs/SALA_CONTINUA_UX.md](docs/SALA_CONTINUA_UX.md).

## Operador e personagem da cadeira

Na partida, o goblin fica acima da grade e o cavaleiro/cadeira abaixo. Ao fechar o circuito, o goblin abaixa a chave em três poses durante 0,40 s; então começa a descarga com áudio único. O resultado aparece após a recuperação, aos 2,40 s. Menu e resultado usam a mesma sala da partida; o seletor mantém a grade de cartões.

O campo **Execution Character** da raiz da cena aponta para `assets/characters/knight.tres`, um recurso independente com nome e animações do ocupante. Para adicionar outro personagem em uma atualização, duplicar esse recurso, trocar as imagens e atribuir à cena. Fios, operador e fases ficam separados. Procedimento completo, novas artes e prompts da edição nativa: [docs/OPERADOR_E_PERSONAGENS.md](docs/OPERADOR_E_PERSONAGENS.md).

## Atualizar sprites e animações

O valor padrão de **Art Pack** da raiz de `scenes/main.tscn`, definido em `scripts/main.gd`, usa `assets/art/concept_v3.tres`; `cartoon_v2.tres` e `default_art.tres` continuam disponíveis para comparação. O recurso contém `SpriteFrames` de personagem/cadeira e texturas independentes dos fios. Novas imagens, resoluções e frames podem ser atribuídos pelo Inspector sem alterar as fases ou a lógica do puzzle. Cada campo pode evoluir separadamente; campos vazios mantêm o desenho geométrico.

Os PNGs do pacote atual estão em `assets/art/concept_v3/`, com fontes preservadas, retrato composto opcional e transparência real. A placa fica estática e os fios giram acima dela. Os textos dos botões continuam nativos em português. Prompts e procedimento: [docs/CONCEITO_V3_ASSETS.md](docs/CONCEITO_V3_ASSETS.md). Os JPEGs de referência não são incluídos nas builds.

As fontes SVG estão em `assets/art/starter/` e `assets/art/cartoon_v2/`. O pacote v2 acrescenta cenário de laboratório, fundo de tela inteira e sprites refinados de personagem/cadeira com canvas 512×512. O jogo também aceita PNGs transparentes e frames de atlas pelos recursos nativos do Godot. A sequência leva 2,40 s: o goblin abaixa a chave antes do choque e da recuperação, preservando tempo, pontuação e progressão.

Correção dos fios na 0.11.1: curvas e T têm pontas com espessura próxima à reta (26% da célula), versões energizadas equivalentes e entrelaçado discreto. Os quatro PNGs novos usam o sufixo `_uniform.png`; os anteriores foram preservados. Prompts e critérios: [docs/CORRECAO_FIOS_UNIFORMES.md](docs/CORRECAO_FIOS_UNIFORMES.md).

Procedimento e convenções de canvas, alinhamento, poses e orientação dos fios: [docs/GUIA_SPRITES.md](docs/GUIA_SPRITES.md). As imagens são distribuídas nas atualizações do aplicativo; não há download de arte em tempo de execução.

## Desenvolvimento e verificação

Os testes exigem Python 3.10+ e Godot 4.7.2. Não precisam de pacotes Python adicionais.

```powershell
# Validar dados, buscar soluções e jogar todas as fases por mouse/toque
./tools/dev.ps1 test

# Todas as verificações obrigatórias, incluindo renderização e áudio
./tools/dev.ps1 verify

# Apenas tremor, clarões e esqueleto, com renderização real
./tools/dev.ps1 effects-test

# Abrir o jogo
./tools/dev.ps1 play

# Capturar menu, jogo, pausa, zap, vitória, derrota e janela estreita
./tools/dev.ps1 capture

# Gerar APK de teste com Android SDK, JDK e templates configurados no Godot
./tools/dev.ps1 android

# Obter somente os templates Windows do arquivo oficial (Python 3.10+ e rede)
python tools/fetch_windows_templates.py

# Gerar executável de Windows
./tools/dev.ps1 windows

# Verificar tudo, gerar APK novo e instalar preservando o progresso
./tools/dev.ps1 install
```

**Entregas obrigatoriamente verificadas:** `android`, `windows` e `install` executam `test`, `effects-test` e `audio-test` antes de exportar. Uma falha ou alteração das fontes durante o processo bloqueia a entrega. Não há opção de pular testes. O teste visual requer desktop com OpenGL. Instalação usa alvo USB confirmado, confere hash/versão/permissão de vibração e preserva o save. Guia e cobertura em [docs/TESTES_E_ENTREGAS.md](docs/TESTES_E_ENTREGAS.md).

O script procura `GODOT_BIN`, o Godot no PATH e, por último, a instalação 4.7.2 em Downloads. Para outra instalação:

```powershell
./tools/dev.ps1 test -GodotPath 'C:\caminho\Godot_v4.7.2-stable_win64_console.exe'
```

A validação procura o caminho com menos toques sem ler `reference_path` ou `solution`. As sequências encontradas são executadas na engine com mouse e toque, em 720×1280 e 360×800, incluindo pausa, reinício, peças não giráveis, vitória, derrota por tempo e progressão. Também confere o centro e os cantos internos de cada célula, os limites da tela, a área efetivamente tocável de pelo menos 48 unidades nas dimensões testadas e a troca de grade entre setores. O teste rejeita fases impossíveis ou já resolvidas e compara o resolvedor com enumeração exaustiva em puzzles pequenos.

Resultado da versão 0.16.0: **24 fases aprovadas, 96 cenários de interface, 24 cenários com dica, 12 cenários de dica contextual, 39.204 verificações na engine e 41 testes Python, sem falhas**. A suíte também valida animações, portas dos sprites nos quatro giros, troca do pacote sem alterar partida/recordes, campos de arte vazios, faíscas e canais de áudio. Verifica silêncio imediato, pausa do ambiente, alerta sem repetição a cada quadro e áudio único de resultado. Uma auditoria adicional confere **730 estados** antes e depois da dica aplicada pela engine, incluindo 26 regressões de T já conectado, jogadas a partir da entrada/saída, erros, simetrias, casos impossíveis e ausência da referência autoral. Toda dica concedida reduziu o mínimo de giros restantes e permitiu concluir. Os testes temporais desses estados começam com o cronômetro integral e simulam dois segundos por giro restante; não reproduzem o tempo já gasto por um jogador real. A facilidade percebida continua sendo avaliada em playtests.

Relatório com mínimos e sequências: [docs/TESTES_FASES.md](docs/TESTES_FASES.md). Dados de execução: `builds/level-solutions.json` e `builds/gameplay-results.json`. `python tools/validate_levels.py` executa apenas a auditoria e recria a parte de busca do relatório; `./tools/dev.ps1 test` gera o relatório completo com resultados da interface.

As pastas `builds/`, `.godot/` e `.tools/` são locais e não devem entrar no controle de versão. Os templates Windows são obtidos da distribuição oficial 4.7.2, com conferência de tamanho e CRC32 das entradas ZIP. A exportação Android usa os templates instalados no editor e sua chave de depuração; não inclui chave de produção no projeto.

## Estrutura

| Caminho | Conteúdo |
| --- | --- |
| `project.godot` | Projeto, cena inicial, orientação retrato e renderer. |
| `scenes/main.tscn` | Cena inicial. |
| `scripts/main.gd` | Interface, navegação, relógio, áudio e preferências. |
| `scripts/art_pack.gd` | Recurso visual e seleção de frames/texturas. |
| `scripts/room_view.gd` | Sala e camadas de personagem/cadeira, sem regras do puzzle. |
| `assets/art/default_art.tres` | Pacote visual inicial com animações e texturas. |
| `assets/art/starter/` | 18 sprites SVG próprios e editáveis. |
| `assets/art/cartoon_v2.tres` | Pacote atual, com cenário e sprites refinados. |
| `assets/art/cartoon_v2/` | Personagem/cadeira refinados e fundos do laboratório/interface. |
| `assets/audio/` | Nove efeitos WAV próprios e trilha original OGG em loop. |
| `scripts/game_audio.gd` | Canais de áudio, ambiente, alerta e silêncio. |
| `tests/polish_tests.gd` | Pausa, som, áudio de resultado e faíscas. |
| `tests/art_pack_tests.gd` | Poses, portas dos sprites, resoluções e preservação da partida ao trocar a arte. |
| `scripts/circuit_board.gd` | Modelo do tabuleiro e busca de conectividade. |
| `scripts/game_session.gd` | Estados e regras da tentativa. |
| `scripts/circuit_solution.gd` | Busca da solução mínima do tabuleiro atual, usada pelas dicas. |
| `scripts/player_profile.gd` | Recordes por fase, preferências, migração e persistência com backup. |
| `scripts/level_card.gd` | Cartões do seletor com estado, estrelas e recordes. |
| `scripts/board_view.gd` | Desenho da grade e entrada por mouse/toque. |
| `levels/level_01.json` a `level_24.json` | Fases, instruções e soluções de referência. |
| `tests/` | Verificação automatizada e capturas com renderer real. |
| `tests/profile_tests.gd` | Testes de recordes, migração e recuperação do save. |
| `tools/validate_levels.py` | Auditor independente e busca da solução mínima. |
| `tools/validate_hint_states.py` | Estados de teste variados e auditoria independente das dicas reais. |
| `tests/hint_stress_tests.gd` | Dicas, cache e conclusão em partidas parciais e com erros. |
| `tools/create_five_by_five_levels.py` | Autoria determinística dos arquivos 9–16, a partir de rotas explícitas; não é geração procedural durante o jogo. |
| `tools/create_six_by_six_levels.py` | Autoria determinística e auditoria prévia dos arquivos 17–24. |
| `tools/` | Comandos de desenvolvimento e obtenção de templates. |
| `docs/TESTES_FASES.md` | Soluções e aprovação de jogabilidade por fase. |
| `docs/VALIDACAO_PROTOTIPO.md` | Evidências, limites e próximos passos. |

## Referências e recursos

Os sprites SVG são fontes próprias deste projeto; os nove sons WAV são sintetizados pela ferramenta de autoria, sem imagens ou áudios externos. `tools/create_polish_assets.py` reproduz o pacote v2 e os sons. `tools/create_starter_art.py` reproduz apenas o conjunto inicial e recusa sobrescrever arquivos sem `--overwrite`. O runtime Godot tem licença MIT, incluída em `assets/GODOT_LICENSE.txt` e nos pacotes exportados.

- [Documentação de exportação Android](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html).
- [Distribuição oficial Godot 4.7.2](https://godotengine.org/download/archive/4.7.2-stable/).
- [Licenças e avisos de terceiros do Godot](https://github.com/godotengine/godot/blob/4.7.2-stable/COPYRIGHT.txt).

## Pacote para playtest

Distribuição local: `builds/playtest/ZapFry-0.14.3/`, com APK, ZIP Windows, hashes e roteiro. Avaliação humana: [docs/ROTEIRO_PLAYTEST.md](docs/ROTEIRO_PLAYTEST.md). A preparação e os testes automáticos estão concluídos; escuta no aparelho, compreensão por novos jogadores e desempenho/bateria continuam pendentes.
