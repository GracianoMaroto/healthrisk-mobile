import 'package:healthrisk_mobile/domain/avaliador_risco.dart';
import 'package:healthrisk_mobile/domain/respostas.dart';
import 'package:healthrisk_mobile/domain/resultado.dart';

/// Pontuação provisória da seção 3.5 do Bloco 2. Só permanece nos testes.
class AvaliadorChecklist implements AvaliadorRisco {
  @override
  Resultado avaliar(Respostas r) {
    var pontos = 0;
    final fatores = <String>[];

    if (!r.hortalicaQuaseTodoDia) {
      pontos += 2;
      fatores.add('Pouca hortaliça ou fruta: fibra baixa piora a qualidade da dieta.');
    }
    if (r.comidaProntaFrequente) {
      pontos += 2;
      fatores.add('Comida pronta: fast-food ou refeição pronta em 3 dias ou mais.');
    }
    if (r.bebidaAcucaradaFrequente) {
      pontos += 2;
      fatores.add('Bebida açucarada: consumo frequente na semana eleva o açúcar da dieta.');
    }
    if (r.embutidoFrequente) {
      pontos += 2;
      fatores.add('Embutido e salgadinho: sódio alto na semana.');
    }
    if (!r.cumpre150min) {
      pontos += 3;
      fatores.add('Movimento: menos de 150 minutos de caminhada ou esforço na semana.');
    }
    if (r.minutosSentadoDia >= 480) {
      pontos += 2;
      fatores.add('Tempo sentado: 8 horas ou mais num dia típico.');
    }
    if (r.idadeAnos >= 60) {
      pontos += 3;
      fatores.add('Idade: a chance estimada sobe com os anos.');
    } else if (r.idadeAnos >= 45) {
      pontos += 2;
      fatores.add('Idade: a chance estimada sobe com os anos.');
    }
    if (r.imc >= 30) {
      pontos += 3;
      fatores.add('Peso e altura: IMC elevado entra no cálculo.');
    } else if (r.imc >= 25) {
      pontos += 1;
      fatores.add('Peso e altura: IMC elevado entra no cálculo.');
    }
    if (r.razaoCinturaEstatura >= 0.5) {
      pontos += 2;
      fatores.add('Cintura: medida alta em relação à altura aumenta a faixa.');
    }
    if (r.familiarPrimeiroGrau) {
      pontos += 2;
      fatores.add('Histórico familiar: pai, mãe, irmão ou filho com diabetes.');
    }

    return Resultado(
      faixa: faixaDePontos(pontos),
      pontos: pontos,
      fatores: fatores,
    );
  }

  static String faixaDePontos(int pontos) {
    if (pontos <= 6) return 'baixo';
    if (pontos <= 12) return 'moderado';
    return 'alto';
  }
}
