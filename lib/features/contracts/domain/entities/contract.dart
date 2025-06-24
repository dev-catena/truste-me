import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes.dart';
import '../../../../core/utils/custom_colors.dart';
import '../../../common/domain/entities/user.dart';
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
  final User? contractor;
  final List<User> stakeHolders;
  final List<ContractSignature> signatures;
  final List<ContractAnswer> answers;
  final int validity;

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
    required this.signatures,
    required this.answers,
    required this.validity,
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
      validity: validity,
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
    int? validity,
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
      validity: validity ?? this.validity,
    );
  }

  @override
  List<Object?> get props => [id, contractNumber, status, type];
}

enum ContractStatus {
  pending(0, 'Pendente', CustomColor.pendingYellow),
  active(1, 'Ativo', CustomColor.activeColor),
  completed(3, 'Concluido', CustomColor.successGreen);
  // suspended(4, 'Cancelado', CustomColor.vividRed);

  final int code;
  final String description;

  final Color color;

  factory ContractStatus.fromString(String json) {
    return ContractStatus.values.firstWhere((element) => element.description == json);
  }

  const ContractStatus(this.code, this.description, this.color);
}

class ContractSignature {
  final int userId;
  final DateTime? dateTime;
  final bool hasAccepted;

  ContractSignature({
    required this.userId,
    required this.dateTime,
    required this.hasAccepted,
  });

  ContractSignature.fromJson(Map<String, dynamic> json)
      : this(
          userId: json['usuario_id'],
          dateTime: DateTime.tryParse(json['dt_aceito'] ?? ''),
          hasAccepted: json['aceito'] == 1 ? true : false,
        );

  ContractSignature copyWith(
    int? userId,
    DateTime? dateTime,
    bool? hasAccepted,
  ) {
    return ContractSignature(
      userId: userId ?? this.userId,
      dateTime: dateTime ?? this.dateTime,
      hasAccepted: hasAccepted ?? this.hasAccepted,
    );
  }
}

class ContractAnswer extends Equatable {
  final int questionId;
  final int userId;
  final String answer;

  const ContractAnswer({required this.questionId, required this.userId, required this.answer});

  @override
  List<Object?> get props => [userId, questionId, answer];

  ContractAnswer.fromJson(Map<String, dynamic> json)
      : this(
          questionId: json['pergunta_id'],
          userId: json['usuario_id'],
          answer: json['resposta'] ?? '',
        );

  Map<String, dynamic> toJson() {
    final content = {
      'pergunta_id': questionId,
      'resposta': answer,
    };

    return content;
  }
}
