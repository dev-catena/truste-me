
import 'package:trustme/core/api_provider.dart';
import 'package:trustme/core/utils/http/custom_http_result.dart';
import 'package:trustme/core/utils/log/log.dart';
import 'package:trustme/features/contracts/domain/entities/contract_type.dart';
import 'package:trustme/features/common/domain/entities/seal.dart';
import 'package:trustme/features/common/data/models/seal_model.dart';

class AppDataSource {
  final _apiProvider = ApiProvider();

  // Future<List<SexualPractice>> getSexualPractices() async {
  //   final httpResult = _MockData().practices;
  //   final practices = httpResult.map((e)=> SexualPractice.fromJson(e)).toList();
  //
  //   return practices;
  // }

  Future<List<ContractType>> getContractTypes() async {
    final HttpResult httpResult = await _apiProvider.get('contrato-tipos/listar');

    if(httpResult.success) {
      final List<ContractType> types = [];

      for (final ele in httpResult.result['data']) {
        types.add(ContractType.fromJson(ele));
      }

      return types;
    } else {
      return [];
    }
  }

  Future<List<Seal>> getSeals() async {
    final HttpResult httpResult = await _apiProvider.get('selos/listar');

    if(httpResult.success) {
      final List<Seal> seals = [];

      //Log.d('$runtimeType', 'httpResult $httpResult');

      for(final ele in httpResult.result['data']){
        // seals.add(SealModel.fromJson(ele..['status'] = ele['id']== 1 ? 'Ausente' :'Indisponível').toEntity());
        seals.add(SealModel.fromJson(ele..['status'] = ele['id']== 1 ? 'Ausente' :'Indisponível').toEntity());
      }

      return seals;
    } else {
      return [];
    }
  }
}
