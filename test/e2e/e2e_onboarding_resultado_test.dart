import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthrisk_mobile/app/copy.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('termo → perfil alto → questionário → faixa Alto + disclaimer', (tester) async {
    final h = await montarHarness();
    addTearDown(h.fechar);
    await pumpApp(tester, h);
    await fluxoAlto(tester);
    expect(find.text(Copy.faixaAlto), findsWidgets);
    expect(find.byKey(const Key('txt_disclaimer')), findsOneWidget);
  });
}
