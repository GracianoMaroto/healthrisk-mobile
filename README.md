# HealthRisk Mobile

Aplicativo Flutter **offline** do projeto semestral UNEX (BSI). Estima faixa de risco de diabetes **neste celular**, com a regressão logística treinada no Bloco 3 de mineração — **sem** API, Firebase ou dados de exame (glicemia, HbA1c, insulina).

Repositórios: [healthrisk-mobile](https://github.com/GracianoMaroto/healthrisk-mobile) · [healthrisk-algoritmo](https://github.com/GracianoMaroto/healthrisk-algoritmo).

## O algoritmo já está no app?

Sim. Produção usa `AvaliadorLogistico` e o JSON `assets/models/mobile_lr_bundle.json` (coeficientes, scaler, imputação e tercis exportados do Python). Não há pesos “chutados” no código. Exame fica em outra tabela e **não entra** no cálculo.

O que ainda é da máquina (não vai para o celular): treino, `.joblib`, NHANES e o Streamlit B2B.

## Como rodar (Chrome, emulador e APK no celular)

> **Leia esta seção primeiro.** São os três jeitos oficiais de abrir o HealthRisk nesta entrega.
> Sempre rode os comandos **nesta pasta do projeto**, no PowerShell.
> Se o `flutter` não for reconhecido, comece **toda sessão** com o PATH abaixo.

```powershell
$env:Path = "$env:USERPROFILE\develop\flutter\bin;" + $env:Path
```

Na primeira vez (ou depois de clonar): `flutter pub get`. Testes: `.\scripts\rodar_suite.ps1`.

O Flutter desta máquina fica em `%USERPROFILE%\develop\flutter`. No Cursor o SDK já aponta para essa pasta.

---

### 1) Preview no Chrome

Rápido para ver telas no computador. **Não é o app de produção:** não usa SQLite, PIN no cofre nem alarme real. Recarregar a aba **zera** perfil, questionário e rotina.

```powershell
flutter run -d chrome
```

O navegador abre sozinho (em geral em `http://localhost:8080`). Feche com `q` no terminal.

---

### 2) Emulador Android (celular virtual)

Aqui vale persistência, PIN e notificações, como no telefone.

1. Abra o **Android Studio** → **More Actions → Virtual Device Manager** (ou *Device Manager*).
2. Crie um aparelho se ainda não tiver: **Pixel 7** (ou Pixel 8), system image **API 35 ou 36 com Google Play**. Evite API 37 nesta máquina — o emulador tende a travar.
3. Clique no **Play** do AVD e espere a **tela inicial** do Android (não só a janela preta).
4. No PowerShell desta pasta:

```powershell
flutter devices
flutter run
```

O emulador deve aparecer como `sdk gphone64 …` / `emulator-5554`. Se houver mais de um dispositivo:

```powershell
flutter run -d emulator-5554
```

Na **primeira** compilação o Gradle baixa NDK, CMake e plataformas — pode levar vários minutos. As seguintes são bem mais rápidas. Permita notificação se o sistema pedir.

**Celular no cabo (opcional):** no telefone, ative *Opções do desenvolvedor* → *Depuração USB*, conecte, autorize o PC. `flutter devices` lista o aparelho; `flutter run` instala em modo debug. A máquina precisa ficar ligada.

---

### 3) APK para instalar no celular (caso geral)

Gera um instalador que o telefone usa **sozinho**, sem cabo e sem o computador ligado.

```powershell
flutter build apk --release
```

Arquivo gerado:

`build\app\outputs\flutter-apk\app-release.apk`

**No celular (qualquer Android, passo a passo):**

1. Copie o `app-release.apk` para o telefone (USB, Google Drive, WhatsApp, e-mail, etc.).
2. Abra o arquivo no aparelho.
3. Se o Android bloquear: **Configurações → Segurança** (ou a mensagem do instalador) → permita instalar deste app / **fontes desconhecidas**.
4. Toque em **Instalar** → **Abrir**.
5. Na primeira execução, permita **notificações** se o sistema pedir.

Esse é o pacote para demonstrar ou entregar. Debug (igual ao `flutter run`, maior): `flutter build apk --debug`.

---

Fora desta máquina: clonar o repo, instalar [Flutter stable](https://docs.flutter.dev/get-started/install) e o [Android Studio](https://developer.android.com/studio) (SDK), `flutter pub get`, os mesmos comandos.

`flutter run -d windows` exige Visual Studio com workload *Desktop development with C++*. Nesta máquina isso **não** está instalado; use Chrome ou o emulador.

## Regenerar o JSON do modelo

No repositório do algoritmo:

```powershell
python -m src.export_mobile_artifacts
```

Copie `artifacts/mobile_lr_bundle.json` para `assets/models/`. Não copie `.joblib`.

## Documentação

Ver `docs/` (arquitetura, reprodução, método 3D, pitch).
