import '../../../common/data/models/person_model.dart';
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
    super.startDate,
    super.endDate,
  });

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    final cont = json['contratante'] != null ? PersonModel.fromJson(json['contratante']).toEntity() : null;
    final stakeHold = (json['participantes'] as List? ?? []).map((e) => PersonModel.fromJson(e).toEntity()).toList()
      ..remove(cont);
    final List<Clause> clau = [];
    final List<SexualPractice> pract = [];

    for (final ele in json['clausulas'] as List? ?? []) {
      if (ele['sexual'] != null) {
        if (ele['sexual'] == 0) {
          clau.add(ClauseModel.fromJson(ele).toEntity());
        } else if (ele['sexual'] == 1) {
          pract.add(SexualPractice.fromJson(ele));
        }
      }
    }

    return ContractModel(
      id: json['id'],
      contractNumber: json['codigo'],
      status: ContractStatus.fromString(json['status']),
      type: ContractType.fromJson(json['tipo']),
      clauses: clau,
      sexualPractices: pract,
      contractor: cont,
      // contractor: json['contratante'] != null ? PersonModel.fromJson(json['contratante']).toEntity() : null,
      stakeHolders: stakeHold,
      // stakeHolder: json['participantes']?[0] != null
      //     ? PersonModel.fromJson(json['participantes'][0]).toEntity()
      //     : null,
      startDate: DateTime.tryParse(json['inicio_vigencia'] ?? ''),
      endDate: DateTime.tryParse(json['fim_vigencia'] ?? ''),
    );
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
      startDate: startDate,
      endDate: endDate,
    );
  }
}
