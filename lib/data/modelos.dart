class Perfil {
  const Perfil({
    required this.nascimento,
    required this.sexo,
    required this.pesoKg,
    required this.alturaCm,
    required this.cinturaCm,
    required this.familiarPrimeiroGrau,
    required this.pressaoAlta,
    required this.diagnosticoInformado,
    this.escolaridadeOrd,
    this.hdl,
    this.insegurancaAlimentar,
    this.termoAceito = true,
  });

  final DateTime nascimento;
  final int sexo;
  final double pesoKg;
  final double alturaCm;
  final double cinturaCm;
  final bool familiarPrimeiroGrau;
  final bool pressaoAlta;
  final bool diagnosticoInformado;
  final int? escolaridadeOrd;
  final double? hdl;
  final bool? insegurancaAlimentar;
  final bool termoAceito;

  double get imc {
    if (alturaCm <= 0) {
      throw ArgumentError('Altura zerada não entra na conta');
    }
    return pesoKg / ((alturaCm / 100.0) * (alturaCm / 100.0));
  }

  double get razaoCinturaEstatura {
    if (alturaCm <= 0) {
      throw ArgumentError('Altura zerada não entra na conta');
    }
    return cinturaCm / alturaCm;
  }
}

class Avaliacao {
  const Avaliacao({
    this.id,
    required this.data,
    required this.faixa,
    required this.fatores,
    required this.respostasJson,
    this.probabilidade,
    this.pontos,
  });

  final int? id;
  final DateTime data;
  final String faixa;
  final double? probabilidade;
  final int? pontos;
  final List<String> fatores;
  final String respostasJson;
}

class Medicamento {
  const Medicamento({
    this.id,
    required this.nome,
    required this.dose,
    required this.horarios,
    required this.diasSemana,
    this.ativo = true,
  });

  final int? id;
  final String nome;
  final String dose;
  final List<String> horarios;
  final List<int> diasSemana;
  final bool ativo;

  Medicamento copyWith({
    int? id,
    String? nome,
    String? dose,
    List<String>? horarios,
    List<int>? diasSemana,
    bool? ativo,
  }) {
    return Medicamento(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      dose: dose ?? this.dose,
      horarios: horarios ?? this.horarios,
      diasSemana: diasSemana ?? this.diasSemana,
      ativo: ativo ?? this.ativo,
    );
  }
}

class Dose {
  const Dose({
    this.id,
    required this.medicamentoId,
    required this.data,
    required this.tomada,
  });

  final int? id;
  final int medicamentoId;
  final String data;
  final bool tomada;
}

class Consulta {
  const Consulta({
    this.id,
    required this.quando,
    required this.profissional,
    required this.especialidade,
    required this.local,
    this.situacao = 'agendada',
  });

  final int? id;
  final DateTime quando;
  final String profissional;
  final String especialidade;
  final String local;
  final String situacao;

  Consulta copyWith({
    int? id,
    DateTime? quando,
    String? profissional,
    String? especialidade,
    String? local,
    String? situacao,
  }) {
    return Consulta(
      id: id ?? this.id,
      quando: quando ?? this.quando,
      profissional: profissional ?? this.profissional,
      especialidade: especialidade ?? this.especialidade,
      local: local ?? this.local,
      situacao: situacao ?? this.situacao,
    );
  }
}

class Exame {
  const Exame({
    this.id,
    required this.tipo,
    required this.valor,
    required this.unidade,
    required this.data,
  });

  final int? id;
  final String tipo;
  final double valor;
  final String unidade;
  final DateTime data;

  Exame copyWith({
    int? id,
    String? tipo,
    double? valor,
    String? unidade,
    DateTime? data,
  }) {
    return Exame(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      valor: valor ?? this.valor,
      unidade: unidade ?? this.unidade,
      data: data ?? this.data,
    );
  }
}

class AgendamentoRegistrado {
  const AgendamentoRegistrado({
    required this.id,
    required this.quando,
    required this.canal,
    required this.texto,
  });

  final int id;
  final DateTime quando;
  final String canal;
  final String texto;
}

abstract class Relogio {
  DateTime agora();
}

class RelogioSistema implements Relogio {
  @override
  DateTime agora() => DateTime.now();
}

class RelogioFixo implements Relogio {
  RelogioFixo(this._agora);
  DateTime _agora;
  set agoraPara(DateTime valor) => _agora = valor;
  @override
  DateTime agora() => _agora;
}
