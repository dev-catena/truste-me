import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes.dart';
import '../../../../core/utils/custom_colors.dart';
import '../../../common/data/models/person_model.dart';
import '../../../common/domain/entities/person.dart';
import 'clause.dart';

part '../../presentation/widgets/components/contract_card.dart';

part '../../presentation/widgets/components/contract_detail_summary_card.dart';

class Contract extends Equatable {
  final int id;
  final String contractNumber;
  final ContractStatus status;
  final ContractType type;
  final List<Clause> clauses;
  final Person? stakeHolder;
  final DateTime? startDate;
  final DateTime? endDate;

  ContractCard buildCard() {
    return ContractCard(this);
  }

  ContractDetailSummaryCard buildDetailCard() {
    return ContractDetailSummaryCard(this);
  }

  const Contract({
    required this.id,
    required this.contractNumber,
    required this.status,
    required this.type,
    this.stakeHolder,
    required this.clauses,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [id, contractNumber, status, type];
}

class ContractModel extends Contract {
  const ContractModel({
    required super.id,
    required super.contractNumber,
    required super.status,
    required super.type,
    super.stakeHolder,
    required super.clauses,
    super.startDate,
    super.endDate,
  });

  ContractModel.fromJson(Map<String, dynamic> json)
      : super(
          id: json['id'],
          contractNumber: json['codigo'],
          status: ContractStatus.fromString(json['status']),
          type: ContractType.fromCode(json['contrato_tipo_id']),
          clauses: (json['clausulas'] as List? ?? json['clausulas_unicas'] as List? ?? []).map((e) => ClauseModel.fromJson(e).toEntity()).toList(),
          stakeHolder: json['participantes'][0]['usuario'] != null
              ? PersonModel.fromJson(json['participantes'][0]['usuario']).toEntity()
              : null,
          startDate: DateTime.tryParse(json['inicio_vigencia'] ?? ''),
          endDate: DateTime.tryParse(json['fim_vigencia'] ?? ''),
        );

  Contract toEntity() {
    return Contract(
      id: id,
      contractNumber: contractNumber,
      status: status,
      clauses: clauses,
      type: type,
      stakeHolder: stakeHolder,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

enum ContractStatus {
  pending(0, 'Pendente', CustomColor.pendingYellow),
  active(1, 'Ativo', CustomColor.activeColor),
  completed(3, 'Concluido', CustomColor.successGreen),
  suspended(4, 'Cancelado', CustomColor.vividRed);

  final int code;
  final String description;

  final Color color;

  factory ContractStatus.fromString(String json) {
    return ContractStatus.values.firstWhere((element) => element.description == json);
  }

  const ContractStatus(this.code, this.description, this.color);
}

// class ContractType extends Equatable {
//   final int id;
//   final String description;
//
//   ContractType.fromJson(Map<String, dynamic> json)
//       : this(
//           json['id'],
//           json['descricao'],
//         );
//
//   const ContractType(this.id, this.description);
//
//   @override
//   List<Object?> get props => [id, description];
// }

enum ContractType {
  sexual(1, 'Sexual'),
  buyAndSale(2, 'Compra e venda');

  final int code;
  final String description;

  factory ContractType.fromString(String value) {
    return ContractType.values.firstWhere(
      (element) => element.description == value,
    );
  }

  factory ContractType.fromCode(int value) {
    return ContractType.values.firstWhere(
      (element) => element.code == value,
    );
  }

  const ContractType(this.code, this.description);
}
