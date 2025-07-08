import 'package:flutter/foundation.dart';

import '../../../../core/api_provider.dart';
import '../../../contracts/domain/entities/contract_type.dart';
import '../../domain/entities/seal.dart';
import '../models/seal_model.dart';

class AppDataSource {
  final _apiProvider = ApiProvider();

  // Future<List<SexualPractice>> getSexualPractices() async {
  //   final rawData = _MockData().practices;
  //   final practices = rawData.map((e)=> SexualPractice.fromJson(e)).toList();
  //
  //   return practices;
  // }

  Future<List<ContractType>> getContractTypes() async {
    final rawData = await _apiProvider.get('contrato-tipos/listar');
    final List<ContractType> types = [];

    for (final ele in rawData['data']) {
      types.add(ContractType.fromJson(ele));
    }

    return types;
  }

  Future<List<Seal>> getSeals() async {
    final rawData = await _apiProvider.get('selos/listar');
    final List<Seal> seals = [];

    debugPrint('$runtimeType - rawData $rawData');

    for(final ele in rawData['data']){
      // seals.add(SealModel.fromJson(ele..['status'] = ele['id']== 1 ? 'Ausente' :'Indisponível').toEntity());
      seals.add(SealModel.fromJson(ele..['status'] = ele['id']== 1 ? 'Ausente' :'Indisponível').toEntity());
    }

    return seals;
  }
}
