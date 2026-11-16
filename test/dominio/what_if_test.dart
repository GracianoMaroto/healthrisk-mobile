import 'package:flutter_test/flutter_test.dart';
import 'package:healthrisk_mobile/domain/avaliador_logistico.dart';

import 'fixtures.dart';

void main() {
  test('150 min + menor cintura reduz p no perfil alto, sem ler exame', () {
    // Nesta LR, minutos_sentado tem coeficiente negativo após o controle
    // das demais 18 features: só "sentar menos" sobe p. O What-If acionável
    // que o modelo de fato recompensa é cumprir 150 min e reduzir a cintura
    // (maior coef. positivo da conta, depois da idade).
    final avaliador = AvaliadorLogistico.fromBundle(bundleLr);
    final alto = respostasGolden('alto');
    final intervencao = alto.copyWith(
      cumpre150min: true,
      cinturaCm: alto.cinturaCm - 6,
    );

    final pAntes = avaliador.avaliar(alto).probabilidade!;
    final pDepois = avaliador.avaliar(intervencao).probabilidade!;

    expect(pAntes, greaterThan(0.5));
    expect(pDepois, lessThan(pAntes));
    expect(alto.toMap().containsKey('glicemia'), isFalse);
    expect(intervencao.toMap().containsKey('hba1c'), isFalse);
  });
}
