class Usuario {
  final int? id;
  final String nome;
  final String email;
  final String telefone;
  final bool motorista;
  final bool emailValidado;
  final String role;
  final String? criadoEm;

  Usuario({
    this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.motorista,
    required this.emailValidado,
    required this.role,
    this.criadoEm,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int?,
      nome: json['nome'] as String? ?? '',
      email: json['email'] as String? ?? '',
      telefone: json['telefone'] as String? ?? '',
      motorista: json['motorista'] as bool? ?? false,
      emailValidado: json['emailValidado'] as bool? ?? false,
      role: json['role'] as String? ?? 'PASSAGEIRO',
      criadoEm: json['criadoEm'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'motorista': motorista,
      'emailValidado': emailValidado,
      'role': role,
      'criadoEm': criadoEm,
    };
  }
}
