class SessaoChamada {
  final int id;
  final String disciplina;
  final String professorNome;
  final DateTime dataHoraInicio;
  final DateTime? dataHoraFim;
  final bool ativa;
  final String? codigoAcesso;

  SessaoChamada({
    required this.id,
    required this.disciplina,
    required this.professorNome,
    required this.dataHoraInicio,
    this.dataHoraFim,
    required this.ativa,
    this.codigoAcesso,
  });

  factory SessaoChamada.fromJson(Map<String, dynamic> json) {
    return SessaoChamada(
      id: json['id'],
      disciplina: json['disciplina'] ?? 'Disciplina',
      professorNome: json['professorNome'] ?? json['professor']?['nome'] ?? 'Professor',
      dataHoraInicio: DateTime.parse(json['dataHoraInicio']),
      dataHoraFim: json['dataHoraFim'] != null ? DateTime.parse(json['dataHoraFim']) : null,
      ativa: json['ativa'] ?? true,
      codigoAcesso: json['codigoAcesso'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'disciplina': disciplina,
      'professorNome': professorNome,
      'dataHoraInicio': dataHoraInicio.toIso8601String(),
      'dataHoraFim': dataHoraFim?.toIso8601String(),
      'ativa': ativa,
      'codigoAcesso': codigoAcesso,
    };
  }
}