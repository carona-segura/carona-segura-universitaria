class Notificacao {
  final int? id;
  final int? destinatarioId;
  final String tipo;
  final String titulo;
  final String mensagem;
  final bool lida;
  final String? criadoEm;

  Notificacao({
    this.id,
    this.destinatarioId,
    required this.tipo,
    required this.titulo,
    required this.mensagem,
    required this.lida,
    this.criadoEm,
  });

  factory Notificacao.fromJson(Map<String, dynamic> json) {
    return Notificacao(
      id: json['id'] as int?,
      destinatarioId: json['destinatarioId'] as int?,
      tipo: json['tipo'] as String? ?? 'INFO',
      titulo: json['titulo'] as String? ?? '',
      mensagem: json['mensagem'] as String? ?? '',
      lida: json['lida'] as bool? ?? false,
      criadoEm: json['criadoEm'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destinatarioId': destinatarioId,
      'tipo': tipo,
      'titulo': titulo,
      'mensagem': mensagem,
      'lida': lida,
      'criadoEm': criadoEm,
    };
  }
}
