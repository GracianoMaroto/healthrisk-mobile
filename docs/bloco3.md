# HealthRisk Mobile — Bloco 3 (Etapas 1 e 2)

Complemento da documentação técnica do Bloco 2: o que o app **realmente** faz neste repositório.

## 1. Arquitetura

Telas Flutter → `Sessao` (estado da navegação, MVVM com `provider`) → `TradutorPerguntas` → `AvaliadorRisco.avaliar`. Produção usa `AvaliadorLogistico`. `AvaliadorChecklist` (18 / 0 pontos) existe **só nos testes**.

O vetor de 19 features, imputador, scaler, coeficientes e tercis vêm de `assets/models/mobile_lr_bundle.json` (export de `logistic_regression.joblib` no repositório do algoritmo). Não há pesos inventados no Dart.

Persistência: SQLite privado (`perfil`, `questionario`, `medicamento`, `dose`, `consulta`, `exame`). Widget/E2E no Windows usam repositórios em memória — o `sqlite3.dll` no `flutter_tester` travava a suíte. O caminho SQLite é coberto por `test/data/sqlite_test.dart`.

PIN opcional: SHA-256 em `flutter_secure_storage` (não vai para o SQLite). Apagar tudo zera tabelas, apaga o PIN e cancela alarmes. Notificações reais (`AgendaLocal`) no Android/iOS; no Windows a agenda é em memória.

Contrato:

```dart
abstract class AvaliadorRisco {
  Resultado avaliar(Respostas respostas);
}
```

Faixas pelos tercis **0,2189** / **0,5124**. Fatores na tela: cintura, movimento, comida, familiar, idade. Sexo, escolaridade e renda imputada entram no cálculo e **não** na frase.

Regra de vazamento: `Respostas` não tem glicemia, HbA1c, insulina nem nome de remédio. Cadastrar glicemia 200 **não muda** a faixa.

Visual 60+: teal `#0D9488`, fonte ≥ 18, alvos ≥ 56 dp, um campo por passo.

## 2. Tabela de tradução (tela → 19 features)

| Pergunta na tela | Feature / equivalência |
| --- | --- |
| Hortaliça/fruta quase todo dia | fibra ~28 g (sim) / valor baixo (não) |
| Bebida açucarada 3+ dias | açúcar ~145 g (sim) |
| Embutido/salgadinho 3+ | sódio e gordura saturada de ultraprocessado |
| Comida pronta 3+ | `refeicao_pronta` + gordura saturada |
| 150 min na semana | MET OMS (`cumpre_oms_150`) |
| Sentada 8 h ou mais | `minutos_sentado` / `sedentarismo_alto` |
| Peso, altura, cintura | IMC e razão cintura/estatura |
| Familiar 1º grau, pressão alta | flags 0/1 |
| Escolaridade, HDL, faltou comida | opcional; vazio → imputação |
| Renda | **não perguntada** → `razao_renda_pobreza` nula (imputada) |
| Diagnóstico informado | não pontua; só troca a frase e a ordem da home |
| Exame (glicemia, HbA1c) | tabela à parte; o avaliador não lê |

What-If na tela de resultado: 150 min + −6 cm de cintura, sem ler exame.

## 3. PIN e LGPD (mínimo)

- Dados de saúde ficam **somente neste celular**.
- Termo de uso: Aceitar / Não aceitar; sem aceite não segue.
- PIN opcional, hash SHA-256 no cofre do sistema, não no SQLite.
- Apagar tudo: perfil, questionário, remédios, consultas, exames, PIN e alarmes.
- Sem conta, sem Firebase, sem API, sem faixa de renda.

## 4. Como reproduzir

Nesta máquina o Flutter está em `%USERPROFILE%\develop\flutter`. Pasta do app: `Bloco 3 - des mobile`. O diretório `build` aponta por junction para `%USERPROFILE%\develop\healthrisk-mobile-build` (OneDrive trava o cache de teste).

**Como abrir o app** (Chrome, emulador Android e APK no celular): seção destacada **«Como rodar»** no `README.md` da raiz.

```powershell
$env:Path = "$env:USERPROFILE\develop\flutter\bin;" + $env:Path
flutter pub get
.\scripts\rodar_suite.ps1
```

Regenerar o JSON (repo do algoritmo):

```powershell
python -m src.export_mobile_artifacts
```

Copie `artifacts/mobile_lr_bundle.json` para `assets/models/`. Não copie `.joblib`.

E2E desta entrega: `testWidgets` em `test/e2e/` (VM). `flutter test integration_test` exigiria device, Developer Mode (symlinks) e caminho sem espaço.

## 5. Método 3D — evidências

1. Definir o teste.  
2. Vermelho registrado.  
3. Mínimo até ficar verde.

| Fatia | Vermelho | Verde |
| --- | --- | --- |
| Etapa 1 domínio (16 testes) | `reports/tdd/etapa1_dominio_vermelho.txt` | `reports/tdd/etapa1_dominio_verde.txt` |
| Etapa 2 suíte (31 testes: domínio, SQLite, widgets, E2E) | testes escritos antes das telas; widgets falhavam/travavam com FFI | `reports/tdd/etapa2_suite_verde.txt` |

Porta final: `.\scripts\rodar_suite.ps1` → `flutter test --no-pub --concurrency=1`.

Falhas mitigadas: PATH do Flutter; pasta com espaço; OneDrive no `build`; `sqlite3.dll` + `flutter_tester`; `ensureVisible` eterno; `flutter test integration_test` pedindo symlink.

## 6. Referências e rastreabilidade

- Bloco 2: Documentação Técnica DM (termo, perfil, questionário, home, remédios, consultas, exames, PIN, apagar tudo, acessibilidade 60+).
- Mineração (`healthrisk-algoritmo` / `Bloco 3 - min dados`): NHANES; `src/features.py` (19 colunas); `models/risk_thresholds.json` (tercis); `data/processed/model_metrics.json` (AUC 0,8376; Recall 85,6% no limiar 0,40); `src/export_mobile_artifacts.py`.
- O app **não** copia as 4 abas B2B do Streamlit nem Random Forest.

## 7. Pitch (30 s)

Dor (Bloco 1): faixa de hábitos, não diagnóstico, dados só no aparelho. Recorte da mineração: regressão logística AUC 0,8376 / Recall 85,6% no limiar 0,40, **on-device**. Demo: termo → questionário → faixa → What-If → remédio “Tomei”. Prontidão: não é diagnóstico, não é nuvem, glicemia 200 não muda a faixa.

## 8. Checklist no aparelho (manual, depois da suíte)

- Alto risco → **Alto**; protetor → **Baixo**
- Glicemia 200 não muda a faixa
- Dose às 8 h em modo avião; sobrevive a reinício (Android)
- Permissão de alarme negada ainda mostra o card das doses
- Consulta gera lembretes 24 h / 2 h
- Apagar tudo zera SQLite e cancela toques
- Disclaimer na tela de resultado
- Diagnóstico informado troca a frase e não apaga remédios
