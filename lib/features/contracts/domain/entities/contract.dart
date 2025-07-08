import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


import '../../../../core/enums/contract_status.dart';
import '../../../../core/routes.dart';
import '../../../../core/utils/custom_colors.dart';
import '../../../common/domain/entities/user.dart';
import '../../data/models/contract_model.dart';
import '../../presentation/widgets/components/time_left_ticker.dart';
import 'clause.dart';
import 'contract_answer.dart';
import 'contract_signature.dart';
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
  final User contractor;
  final List<User> stakeHolders;
  final List<ContractSignature> signatures;
  final List<ContractAnswer> answers;
  final int duration;
  final DateTime startDt;
  final DateTime endDt;

  ContractCard buildCard({required final void Function(Contract contract) onExpire}) {
    return ContractCard(this, onExpire: onExpire);
  }

  ContractDetailSummaryCard buildDetailCard() {
    return ContractDetailSummaryCard(this);
  }

  const Contract({
    required this.id,
    required this.contractNumber,
    required this.status,
    required this.type,
    required this.contractor,
    required this.stakeHolders,
    required this.clauses,
    required this.sexualPractices,
    required this.signatures,
    required this.answers,
    required this.duration,
    required this.startDt,
    required this.endDt,
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
      signatures: signatures,
      answers: answers,
      contractor: contractor,
      duration: duration,
      startDt: startDt,
      endDt: endDt,
    );
  }

  Contract copyWith({
    int? id,
    String? contractNumber,
    ContractStatus? status,
    ContractType? type,
    List<Clause>? clauses,
    List<SexualPractice>? sexualPractices,
    User? contractor,
    List<User>? stakeHolders,
    List<ContractSignature>? signatures,
    List<ContractAnswer>? answers,
    int? duration,
    DateTime? startDt,
    DateTime? endDt,
  }) {
    return Contract(
      id: id ?? this.id,
      contractNumber: contractNumber ?? this.contractNumber,
      status: status ?? this.status,
      type: type ?? this.type,
      contractor: contractor ?? this.contractor,
      stakeHolders: stakeHolders ?? this.stakeHolders,
      clauses: clauses ?? this.clauses,
      sexualPractices: sexualPractices ?? this.sexualPractices,
      signatures: signatures ?? this.signatures,
      answers: answers ?? this.answers,
      duration: duration ?? this.duration,
      startDt: startDt ?? this.startDt,
      endDt: endDt ?? this.endDt,
    );
  }

  @override
  List<Object?> get props => [id, contractNumber, status, type];
}


