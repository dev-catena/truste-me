import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes.dart';
import '../../../../core/utils/custom_colors.dart';
import '../../../common/data/models/person_model.dart';
import '../../../common/domain/entities/person.dart';
import '../../data/models/clause_model.dart';
import '../../data/models/contract_model.dart';
import 'clause.dart';
import 'contract_type.dart';
import 'sexual_practice.dart';

part '../../presentation/widgets/components/contract_card.dart';

part '../../presentation/widgets/components/contract_detail_summary_card.dart';

class Contract extends Equatable {
  final int id;
  final String contractNumber;
  final ContractStatus status;
  final ContractType type;
  final List<Clause> clauses;
  final List<SexualPractice> sexualPractices;
  final Person? contractor;
  final List<Person> stakeHolders;
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
    this.contractor,
    required this.stakeHolders,
    required this.clauses,
    required this.sexualPractices,
    this.startDate,
    this.endDate,
  });

  ContractModel toModel() {
    return ContractModel(
      id: id,
      contractNumber: contractNumber,
      status: status,
      type: type,
      stakeHolders: stakeHolders,
      clauses: clauses,
      sexualPractices: sexualPractices,
      startDate: startDate,
      endDate: endDate,
      contractor: contractor,
    );
  }

  @override
  List<Object?> get props => [id, contractNumber, status, type];
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
