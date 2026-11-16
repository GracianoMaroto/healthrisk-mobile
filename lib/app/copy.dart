class Copy {
  static const appNome = 'HealthRisk';

  static const termoTitulo = 'Antes de começar';
  static const termoCorpo =
      'Este aplicativo guarda seus dados de saúde somente neste celular. '
      'A faixa de hábitos não é diagnóstico de diabetes e não muda remédio. '
      'Consulta, exame e tratamento são com o serviço de saúde. '
      'Você pode apagar tudo em Ajustes.';
  static const aceitar = 'Aceitar e continuar';
  static const naoAceitar = 'Não aceitar';

  static const disclaimer =
      'Isto não é diagnóstico de diabetes e não muda remédio.';
  static const procurarUbs =
      'Procure a unidade básica de saúde para conversar sobre esses hábitos.';
  static const fraseRisco =
      'Esta faixa estima chance de diabetes a partir dos hábitos, não substitui consulta.';
  static const fraseCuidado =
      'Fatores do seu dia a dia ligados ao cuidado. Isto não mede chance de ter diabetes.';

  static const faixaAlto = 'Alto';
  static const faixaModerado = 'Moderado';
  static const faixaBaixo = 'Baixo';

  static const tomei = 'Tomei';
  static const apagarTudo = 'Apagar tudo';
  static const confirmarApagar = 'Apagar todos os dados deste celular?';
  static const confirmar = 'Confirmar apagar';
  static const cancelar = 'Cancelar';

  static const obrigatorio = '(obrigatório)';
  static const opcional = '(opcional)';
  static const pinBeneficio =
      'O PIN impede outra pessoa de abrir seus dados neste celular.';
  static const pinAtivo = 'PIN ativo';
  static const pinSalvo = 'PIN salvo.';
  static const pinCurto = 'Use pelo menos 4 números.';
  static const glicemiaEmJejum = 'Glicemia em jejum';
  static const consultaSalva = 'Consulta salva.';
  static const consultaExcluida = 'Consulta excluída.';
  static const consultaRealizada = 'Consulta marcada como realizada.';
  static const exameSalvo = 'Exame salvo.';
  static const exameExcluido = 'Exame excluído.';
  static const medicamentoSalvo = 'Medicamento salvo.';
  static const medicamentoExcluido = 'Medicamento excluído.';
  static const doseRegistrada = 'Dose registrada.';
  static const marcarRealizada = 'Marcar como realizada';
  static const historico = 'Histórico';
  static const nenhumRegistro = 'Nenhum registro.';
  static const naoSei = 'Não sei';
  static const continuar = 'Continuar';
  static const sim = 'Sim';
  static const nao = 'Não';

  static const qHortalica =
      'Na última semana, comeu hortaliça ou fruta quase todo dia?';
  static const qComidaPronta =
      'Na última semana, comeu comida pronta ou fast-food em 3 dias ou mais?';
  static const qBebida =
      'Na última semana, tomou bebida açucarada em 3 dias ou mais?';
  static const qEmbutido =
      'Na última semana, comeu embutido ou salgadinho em 3 dias ou mais?';
  static const q150 =
      'Na última semana, chegou a 150 minutos de caminhada ou esforço moderado?';
  static const qSentado = 'Num dia típico, fica sentado(a) 8 horas ou mais?';
  static const qAjuda = 'Pode voltar e mudar a resposta quando quiser.';
  static const qBase =
      'A faixa não é um chute. O cálculo usa regressão logística treinada em dados reais de saúde (NHANES), '
      'com imputação, padronização e tercis exportados para este celular — o mesmo modelo da mineração, offline, sem glicemia.';

  static const pNascimento = 'Qual é a sua data de nascimento?';
  static const pNascimentoAjuda = 'Digite dia, mês e ano. Exemplo: 15/01/1968.';
  static const pSexo = 'Sexo';
  static const pPeso = 'Qual é o seu peso, em quilos?';
  static const pAltura = 'Qual é a sua altura, em centímetros?';
  static const pCintura = 'Qual é a medida da cintura, em centímetros?';
  static const pFamiliar = 'Pai, mãe, irmão ou filho tem diabetes?';
  static const pPressao = 'Tem pressão alta (140/90 ou mais)?';
  static const pDiagnostico = 'Um médico já disse que você tem diabetes?';
  static const pEscolaridade = 'Qual é o seu grau de escolaridade?';
  static const pEscolaridadeAjuda =
      'Usado só no cálculo. Se não souber, toque em Não sei.';
  static const pHdl = 'Colesterol bom (HDL), se souber, em mg/dL.';
  static const pHdlAjuda =
      'É o número do exame de sangue. Se não souber, pule.';
  static const pInseguranca = 'Faltou comida em casa nos últimos 12 meses?';

  static const esc1 = 'Não completou o fundamental';
  static const esc2 = 'Fundamental incompleto';
  static const esc3 = 'Ensino médio completo';
  static const escMedio = esc3;
  static const esc4 = 'Faculdade incompleta';
  static const esc5 = 'Faculdade completa';

  static const whatIf = 'E se eu caminhar 150 min e reduzir 6 cm de cintura?';
  static const hipoteseHabito = 'Hipótese de mudança de hábito';
  static const irInicio = 'Ir para o início';
  static const alturaZero = 'Altura zerada não entra na conta. Informe de novo.';

  static const exameGlicemiaAjuda = 'Exemplo: 98 ou 126.';
  static const exameHba1cAjuda = 'Exemplo: 5,6 ou 7,0.';

  static String rotuloTipoExame(String tipo) => switch (tipo) {
        'glicemia_jejum' => glicemiaEmJejum,
        'hba1c' => 'HbA1c',
        _ => tipo,
      };
}
