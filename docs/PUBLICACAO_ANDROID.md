# Publicação Android

Pacote: `com.mprovensi.zapfry`. Versão atual: 0.24.0, código 41, target API 36, mínimo API 24. O primeiro pacote de loja foi 0.23.0/código 40; a narrativa usa o próximo código. Cada novo envio deve aumentar `version/code` nos dois presets Android. O pacote antigo `com.zapfry.prototype` é um app separado; seus dados não são removidos nem migrados por esta exportação.

## Gerar a entrega

```powershell
./tools/dev.ps1 android -Release
```

O comando executa obrigatoriamente os testes de regras/interface, efeitos com renderer real e áudio. Depois exporta o APK de release pelo preset Android e o AAB pelo preset Google Play. Instala o template Gradle fornecido pela engine caso necessário. A primeira compilação Gradle requer acesso à internet.

- `builds/release/ZapFry.aab`: arquivo para enviar à Play Console.
- `builds/release/ZapFry-release.apk`: instalação direta para testes, assinado com a chave de upload.
- `builds/release/release-audit.json`: hashes, certificado e verificações da entrega.

As duas saídas passam pela auditoria dos dados e texturas. A auditoria de release também confere assinatura, ausência de debug, identidade e versão, API 36 e alinhamento ELF de 16 KB; usa o bundletool oficial para validar o AAB e ler seu manifesto. O APK também passa por `zipalign -P 16`.

Pré-requisito local: JDK, SDK Android com API 36 e build-tools, templates Godot da versão do projeto e `.tools/bundletool-all-*.jar`, obtido em [google/bundletool](https://github.com/google/bundletool/releases).

## Chave de upload

A chave foi gerada por solicitação do usuário, para o primeiro envio. `.tools/signing/` contém a chave privada `zapfry-upload.jks`, a senha/alias em `upload.json` e o certificado público `upload-certificate.pem`. A pasta inteira está excluída do Git e dos recursos exportados. **Faça um backup privado dessa pasta em local seguro.** Não envie a chave nem o JSON ao repositório ou junto do AAB.

O fluxo lê as credenciais locais e passa os valores à engine por variáveis de ambiente, restauradas ao terminar. A preparação recusa sobrescrever uma chave existente. Para preparar uma chave em outro projeto/primeiro ambiente, existe `tools/prepare_android_signing.py --java-home CAMINHO_JDK`; não execute para substituir a chave já criada.

Na primeira publicação, use Play App Signing e permita que o Google gerencie a chave de assinatura do app. A chave local é a de upload. O APK distribuído pela loja usará a assinatura gerenciada pelo Google e pode ter assinatura diferente do APK local.

## Play Console

Envie `ZapFry.aab` para a faixa de teste desejada. A preparação não publica nem envia arquivos automaticamente. A revisão da loja, os formulários de conteúdo e a configuração da ficha são etapas da Play Console.

## Entrega de 13 de novembro de 2026

`tools/dev.ps1 android -Release` concluído com saída 0. A execução final aprovou 71 testes Python, 42.330 verificações na engine, 831 estados de dicas, 3.685 verificações visuais/temporais e 48 de áudio. APK e AAB contêm os dados das 24 fases idênticos às fontes e as 83 texturas auditadas. O AAB usa o módulo `assetPackInstallTime` para os recursos, entregue junto com o app; a auditoria cobre também esse módulo.

Assinatura dos dois arquivos conferida contra a chave de upload; manifesto sem debug, API 36 e quatro bibliotecas 64-bit com alinhamento de 16 KB em cada pacote. O bundletool oficial 1.18.3 validou o AAB. A compilação Gradle usa daemon descartável para permitir que o console da exportação termine automaticamente.

| Arquivo | Bytes | SHA-256 |
| --- | --- | --- |
| `ZapFry-release.apk` | 65.059.664 | `4da0ececde2ee31ed9619c94dbdcc1738fca779d9ad65459d1d5cedee32e65cc` |
| `ZapFry.aab` | 64.978.485 | `99290a0918da79fdc03e9d036bf5c6e894363a077d31f7132fd4b53b8a577000` |

Certificado de upload, SHA-256: `05761c4d24a4968b5d861850df7139e5c7ffda88677a876cf13c556b448ea601`. Registros locais: `builds/publish-release.log`, `builds/verification.json` e `builds/release/release-audit.json`. Nenhum envio à loja ou instalação foi realizado nesta entrega.

Fontes: [formato AAB e assinatura no Godot](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html), [exigência de API da Google Play](https://support.google.com/googleplay/android-developer/answer/11926878) e [Play App Signing](https://support.google.com/googleplay/android-developer/answer/9842756).
