import 'package:equatable/equatable.dart';

import 'clause.dart';

class ContractType extends Equatable {
  final int id;
  final String description;
  final String code;
  final List<ContractQuestion> questions;

  const ContractType({
    required this.id,
    required this.description,
    required this.code,
    required this.questions,
  });

  ContractType.fromJson(Map<String, dynamic> json)
      : this(
          id: json['id'],
          code: json['codigo'],
          description: json['descricao'],
          questions: (json['perguntas'] as List? ?? []).map((e) => ContractQuestion.fromJson(e)).toList(),
        );

  @override
  List<Object?> get props => [id, code, description];
}
