# HealthRisk Mobile

Aplicativo Flutter **offline** do projeto semestral UNEX (BSI). Estima faixa de risco de diabetes **neste celular**, com a regressão logística treinada no Bloco 3 de mineração — **sem** API, Firebase ou dados de exame (glicemia, HbA1c, insulina).

Repositórios: [healthrisk-mobile](https://github.com/GracianoMaroto/healthrisk-mobile) · [healthrisk-algoritmo](https://github.com/GracianoMaroto/healthrisk-algoritmo).

## O algoritmo já está no app?

Sim. Produção usa `AvaliadorLogistico` e o JSON `assets/models/mobile_lr_bundle.json` (coeficientes, scaler, imputação e tercis exportados do Python). Não há pesos “chutados” no código. Exame fica em outra tabela e **não entra** no cálculo.

O que ainda é da máquina (não vai para o celular): treino, `.joblib`, NHANES e o Streamlit B2B.

## Como rodar nesta máquina

O Flutter está em `%USERPROFILE%\develop\flutter`. No PowerShell desta pasta:

```powershell
$env:Path = "$env:USERPROFILE\develop\flutter\bin;" + $env:Path
flutter pub get
.\scripts\rodar_suite.ps1
flutter run -d windows
```

Se `flutter` “não é reconhecido”, use o PATH acima ou o script. No Cursor o SDK já aponta para essa pasta.

- **Windows (já nesta máquina):** `flutter run -d windows` — perfil, questionário e faixa funcionam; alarme real é Android/iOS.
- **Celular Android:** ligue o aparelho (USB + depuração) ou um emulador no Android Studio e `flutter run`. Permita notificação quando o sistema pedir.
- **APK para levar embora:** `flutter build apk`. Instala o arquivo `build/app/outputs/flutter-apk/app-release.apk` no telefone. Não precisa da sua máquina ligada.

Fora desta máquina: clonar o repo, instalar [Flutter stable](https://docs.flutter.dev/get-started/install), `flutter pub get`, os mesmos comandos.

## Regenerar o JSON do modelo

No repositório do algoritmo:

```powershell
python -m src.export_mobile_artifacts
```

Copie `artifacts/mobile_lr_bundle.json` para `assets/models/`. Não copie `.joblib`.

## Documentação

Ver `docs/` (arquitetura, reprodução, método 3D, pitch).
