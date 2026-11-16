import 'package:flutter_test/flutter_test.dart';
import 'package:healthrisk_mobile/app/copy.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('fluxo protetor → faixa Baixo', (tester) async {
    final h = await montarHarness();
    addTearDown(h.fechar);
    await pumpApp(tester, h);
    await fluxoBaixo(tester);
    expect(find.text(Copy.faixaBaixo), findsWidgets);
  });
}
