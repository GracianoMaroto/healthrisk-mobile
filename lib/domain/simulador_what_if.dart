import 'dart:math' as math;

import 'package:healthrisk_mobile/domain/respostas.dart';

/// Intervenção "e se?" da tela de resultado: hábitos protetores + cintura.
///
/// Nunca piora um fator. Cintura só cai se a razão cintura/altura já está
/// alta (>= 0,50); caso contrário o piso de 6 cm poderia *aumentar* a medida
/// em alguém magro e inflar o risco.
class SimuladorWhatIf {
  static const deltaCinturaCm = 6.0;
  static const limiarRce = 0.50;
  static const pisoRce = 0.45;

  static Respostas aplicar(Respostas atual) {
    return atual.copyWith(
      cinturaCm: _cinturaAlvo(atual),
      cumpre150min: true,
      sentado8hOuMais: false,
      hortalicaQuaseTodoDia: true,
      comidaProntaFrequente: false,
      bebidaAcucaradaFrequente: false,
      embutidoFrequente: false,
    );
  }

  static double _cinturaAlvo(Respostas atual) {
    final rce = atual.cinturaCm / atual.alturaCm;
    if (rce < limiarRce) return atual.cinturaCm;
    final proposto = atual.cinturaCm - deltaCinturaCm;
    final piso = atual.alturaCm * pisoRce;
    return math.min(atual.cinturaCm, math.max(proposto, piso));
  }
}
