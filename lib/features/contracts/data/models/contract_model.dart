import '../../../common/data/models/user_model.dart';
import '../../domain/entities/clause.dart';
import '../../domain/entities/contract.dart';
import '../../domain/entities/contract_type.dart';
import '../../domain/entities/sexual_practice.dart';
import 'clause_model.dart';

class ContractModel extends Contract {
  const ContractModel({
    required super.id,
    required super.contractNumber,
    required super.status,
    required super.type,
    super.contractor,
    required super.stakeHolders,
    required super.clauses,
    required super.sexualPractices,
    required super.signatures,
    required super.answers,
    required super.validity,
  });

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    final cont = json['contratante'] != null ? UserModel.fromJson(json['contratante']).toEntity() : null;
    final stakeHold = (json['participantes'] as List? ?? []).map((e) => UserModel.fromJson(e).toEntity()).toList()
      ..remove(cont);
    final List<Clause> clau = [];
    final List<SexualPractice> pract = [];
    final List<ContractAnswer> repostas = [];

    for (final ele in json['clausulas'] as List? ?? []) {
      if (ele['sexual'] != null) {
        if (ele['sexual'] == 0) {
          clau.add(ClauseModel.fromJson(ele).toEntity());
        } else if (ele['sexual'] == 1) {
          pract.add(SexualPractice.fromJson(ele));
        }
      }
    }

    if (json['participantes'] != null) {
      for (final ele in json['participantes']) {
        if (ele['respostas'] != null) {
          for (final resp in ele['respostas']) {
            repostas.add(ContractAnswer.fromJson(resp..['usuario_id'] = ele['id']));
          }
        }
      }
    }

    return ContractModel(
      id: json['id'],
      contractNumber: json['codigo'],
      status: ContractStatus.fromString(json['status'] ?? 'Pendente'),
      type: ContractType.fromJson(json['tipo']),
      clauses: clau,
      sexualPractices: pract,
      contractor: cont,
      // contractor: json['contratante'] != null ? PersonModel.fromJson(json['contratante']).toEntity() : null,
      stakeHolders: stakeHold,
      // stakeHolder: json['participantes']?[0] != null
      //     ? PersonModel.fromJson(json['participantes'][0]).toEntity()
      //     : null,
      signatures: (json['assinaturas'] as List? ?? []).map((e) => ContractSignature.fromJson(e)).toList(),
      answers: repostas,
      validity: json['duracao'],
    );
  }

  Map<String, dynamic> toJson() {
    final usersId = stakeHolders.map((p) => p.id).toList();
    final clausesWithPractices = [...clauses, ...sexualPractices.map((e) => e.toClause())];

    final content = {
      'contrato_tipo_id': type.id,
      'status': status.description,
      'validade': validity,
      'participantes': usersId,
      'clausulas': clausesWithPractices.map((e) => e.id).toList(),
      'duracao': validity
    };

    return content;
  }

  Contract toEntity() {
    return Contract(
      id: id,
      contractNumber: contractNumber,
      contractor: contractor,
      status: status,
      clauses: clauses,
      sexualPractices: sexualPractices,
      type: type,
      stakeHolders: stakeHolders,
      signatures: signatures,
      answers: answers,
      validity: validity,
    );
  }
}
