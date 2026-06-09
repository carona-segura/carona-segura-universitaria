class Viagem {
  final int? id;
  final int motoristaId;
  final String origem;
  final String destino;
  final String dataHoraSaida;
  final int vagas;
  final int vagasOcupadas;
  final double valorContribuicao;
  final String status;
  final String? criadoEm;

  Viagem({
    this.id,
    required this.motoristaId,
    required this.origem,
    required this.destino,
    required this.dataHoraSaida,
    required this.vagas,
    required this.vagasOcupadas,
    required this.valorContribuicao,
    required this.status,
    this.criadoEm,
  });

  factory Viagem.fromJson(Map<String, dynamic> json) {
    return Viagem(
      id: json['id'] as int?,
      motoristaId: json['motoristaId'] as int? ?? 0,
      origem: json['origem'] as String? ?? '',
      destino: json['destino'] as String? ?? '',
      dataHoraSaida: json['dataHoraSaida'] as String? ?? '',
      vagas: json['vagas'] as int? ?? 0,
      vagasOcupadas: json['vagasOcupadas'] as int? ?? 0,
      valorContribuicao: (json['valorContribuicao'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'ABERTA',
      criadoEm: json['criadoEm'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'motoristaId': motoristaId,
      'origem': origem,
      'destino': destino,
      'dataHoraSaida': dataHoraSaida,
      'vagas': vagas,
      'vagasOcupadas': vagasOcupadas,
      'valorContribuicao': valorContribuicao,
      'status': status,
      'criadoEm': criadoEm,
    };
  }
}
