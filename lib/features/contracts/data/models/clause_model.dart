import '../../domain/entities/clause.dart';

class ClauseModel extends Clause {
  Clause toEntity() {
    return Clause(
      id: id,
      description: description,
      name: name,
      code: code,
      pendingFor: pendingFor,
      acceptedBy: acceptedBy,
      deniedBy: deniedBy,
    );
  }

  ClauseModel.fromJson(Map<String, dynamic> json)
      : super(
          id: json['id'] ?? json['clausula_id'],
          name: json['nome'],
          code: json['codigo'],
          description: json['descricao'],
          pendingFor: (json['pendente_para'] as List?)?.cast<int>() ?? [],
          acceptedBy: (json['aceito_por'] as List?)?.cast<int>() ?? [],
          deniedBy: (json['recusado_por'] as List?)?.cast<int>() ?? [],
        );

  const ClauseModel({
    required super.id,
    required super.code,
    required super.description,
    required super.name,
    required super.pendingFor,
    required super.acceptedBy,
    required super.deniedBy,
  });
}
