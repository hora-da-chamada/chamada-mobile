class Usuario {
  final int? id;
  final String nome;
  final String email;
  final String matricula;
  final String tipo;
  final String? token;

  Usuario({
    this.id,
    required this.nome,
    required this.email,
    required this.matricula,
    required this.tipo,
    this.token,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      matricula: json['matricula'] ?? '',
      tipo: json['tipo'] ?? 'ALUNO',
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'matricula': matricula,
      'tipo': tipo,
      'token': token,
    };
  }
}