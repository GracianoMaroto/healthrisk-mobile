import 'package:healthrisk_mobile/domain/respostas.dart';
import 'package:healthrisk_mobile/domain/resultado.dart';

abstract class AvaliadorRisco {
  Resultado avaliar(Respostas respostas);
}
