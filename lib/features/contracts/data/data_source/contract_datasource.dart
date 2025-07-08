import 'dart:convert';

import '../../../../core/api_provider.dart';
import '../../../common/domain/entities/user.dart';
import '../../domain/entities/clause.dart';
import '../../domain/entities/contract.dart';
import '../../domain/entities/contract_answer.dart';
import '../../domain/entities/contract_type.dart';
import '../../domain/entities/sexual_practice.dart';
import '../models/clause_model.dart';
import '../models/contract_model.dart';

class ContractDataSource {
  final _apiProvider = ApiProvider();

  Future<Contract> getContractFullInfo(Contract cont) async {
    final rawData = await _apiProvider.get('contrato/buscar-completo/${cont.id}');

    final contract = ContractModel.fromJson(rawData).toEntity();

    return contract;
  }

  Future<Contract> updateContract(Contract cont) async {
    final content = cont.toModel().toJson();
    final rawData = await _apiProvider.patch('contrato/atualizar/${cont.id}', jsonEncode(content));
    final converted = ContractModel.fromJson(rawData).toEntity();

    return converted;
  }

  Future<List<Contract>> getContractsForUser(final User user) async {
    final rawData = await _apiProvider.get('usuario/${user.id}/contratos');
    final List<Contract> convertedData = [];

    for (final ele in rawData['contratos_como_contratante']) {
      convertedData.add(ContractModel.fromJson(ele).toEntity());
    }

    for (final ele in rawData['contratos_como_participante']) {
      convertedData.add(ContractModel.fromJson(ele).toEntity());
    }

    return convertedData;
  }

  Future<ClauseAndPractice> getClausesForContractType(ContractType type) async {
    final rawData = await _apiProvider.get('contrato-tipos/${type.id}/clausulas-perguntas');

    final List<Clause> clau = [];
    final List<SexualPractice> pract = [];

    for (final ele in rawData['clausulas'] as List? ?? []) {
      if (ele['sexual'] != null) {
        if (ele['sexual'] == 0) {
          clau.add(ClauseModel.fromJson(ele).toEntity());
        } else if (ele['sexual'] == 1) {
          pract.add(SexualPractice.fromJson(ele));
        }
      }
    }
    final convertedData = ClauseAndPractice(clau, pract);

    return convertedData;
  }

  // Future<Contract> createContract(ContractType type, List<Person> participants, List<int> clausesId) async {
  //   final personsId = participants.map((p) => p.id).toList();
  //
  //   final content = {
  //     'contrato_tipo_id': type.id,
  //     'status': 'Pendente',
  //     'participantes': personsId,
  //     'clausulas': clausesId,
  //   };
  //
  //   final response = await _apiProvider.post('contrato/gravar', jsonEncode(content));
  //
  //   final newContract = ContractModel.fromJson(response).toEntity();
  //
  //   return newContract;
  // }

  Future<Contract> createContract(ContractModel contract) async {
    final response = await _apiProvider.post('contrato/gravar', jsonEncode(contract.toJson()));

    final newContract = ContractModel.fromJson(response).toEntity();

    return newContract;
  }

  Future<void> acceptOrDenyClause(Contract contract, Clause clause, bool hasAccepted) async {
    final content = [
      {
        'contrato_id': contract.id,
        'clausula_id': clause.id,
        'aceito': hasAccepted ? 1 : 0,
      }
    ];

    await _apiProvider.post('contrato/clausula/aceitar', jsonEncode(content));
  }

  Future<void> signContract(Contract contract) async {
    await _apiProvider.post('contrato/${contract.id}/responder', jsonEncode({'aceito': true}));
  }

  Future<void> answerQuestion(Contract contract, List<ContractAnswer> answers) async {
    final Map<String, dynamic> content = {
      'contrato_id': contract.id,
      'respostas': answers.map((e) => e.toJson()).toList(),
    };

    await _apiProvider.post('contrato/pergunta/responder', jsonEncode(content));
  }

  Future<void> finishContract (Contract contract) async {
    final content = {'status': 'Ativo'};
    await _apiProvider.patch('contrato/atualizar/${contract.id}', jsonEncode(content));
  }
}
