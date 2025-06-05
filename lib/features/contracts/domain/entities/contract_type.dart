import 'package:equatable/equatable.dart';

class ContractType extends Equatable {
  final int id;
  final String description;
  final String code;

  const ContractType({required this.id, required this.description, required this.code});

  ContractType.fromJson(Map<String, dynamic> json): this(
    id: json['id'],
    code: json['codigo'],
    description: json['descricao'],
  );

  @override
  List<Object?> get props => [id, code, description];
}