# Entregas do Zap & Fry

- Toda exportação ou instalação deve passar por `tools/dev.ps1`: `android`, `windows` ou `install`. Esses comandos executam `test`, `effects-test` e `audio-test` antes de exportar. Falhas bloqueiam a entrega. Não adicionar opções para ignorar testes.
- Para conferir tudo sem gerar pacote, usar `./tools/dev.ps1 verify`. O teste visual exige desktop com OpenGL; indisponibilidade do renderer bloqueia a entrega, não autoriza pular a suíte.
- Instalar com `./tools/dev.ps1 install`; havendo mais de um celular, fornecer `-DeviceSerial` com o serial confirmado. Não usar scripts históricos em `builds/` ou ADB direto para contornar o fluxo.
- Atualizações devem preservar o perfil. Não desinstalar, limpar dados ou automatizar partidas no celular do usuário. O instalador confere o APK transferido, a versão instalada e a preservação do save.
- Após exportar, manter a auditoria dos dados/texturas no APK e o teste de inicialização do EXE Windows. Recursos novos precisam de cobertura de empacotamento, além dos testes nas fontes.
- Testes Godot devem usar `-- --test`, isolando o progresso do jogador. Antes de alterar regras, persistência, navegação ou efeitos, conferir e estender os testes correspondentes.
