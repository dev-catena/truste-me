import 'package:flutter/foundation.dart';

import '../../../../core/api_provider.dart';
import '../../../home/data/data_source/home_datasource.dart';
import '../../domain/entities/seal.dart';
import '../../domain/entities/user.dart';
import '../models/seal_model.dart';

class UserDataSource {
  final ApiProvider _apiProvider = ApiProvider();

  Future<GeneralUserInfo> getGeneralInfo() async {
    final rawData = await _apiProvider.get('usuario/info');

    return GeneralUserInfo.fromJson(rawData);
  }

  Future<List<Seal>> getSeals(User user) async {
    final rawData = await _apiProvider.get('usuario/${user.id}/selos');

    debugPrint('$runtimeType - rawData $rawData');
    final allRawSeals = [
      ...(rawData['ativos'] as List).map((e) => e..['status'] = 'Ativo'),

      ...(rawData['pendentes'] as List).map((e) => e..['status'] = 'Ausente'),

      ...(rawData['expirados'] as List).map((e) => e..['status'] = 'Ausente'),
      // ...(rawData['expirados'] as List).map((e)=> e..['status'] = 'Expirado'),
      // ...(rawData['cancelados'] as List).map((e)=> e..['status'] = rawData['id'] == 1 ? 'Ausente' :'Indisponível'),
    ];

    final List<Seal> seals = [];

    for (final ele in allRawSeals) {
      seals.add(SealModel.fromJson(ele).toEntity());
    }

    return seals;
  }
}
