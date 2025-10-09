import 'dart:convert';

import 'package:trustme/core/api_provider.dart';
import 'package:trustme/core/utils/log/log.dart';
import 'package:trustme/features/home/data/data_source/home_datasource.dart';
import 'package:trustme/features/common/domain/entities/seal.dart';
import 'package:trustme/features/common/domain/entities/user.dart';
import 'package:trustme/features/common/data/models/seal_model.dart';
import 'package:trustme/features/common/data/models/user_model.dart';

class UserDataSource {
  final ApiProvider _apiProvider = ApiProvider();

  // CHECKED: 1
  Future<User?> createUser(Map<String, dynamic> usr) async { // TODO: Change to User entity
    //final content = usr.toModel().toJson();
    final rawData = await ApiProvider().post('usuario/gravar', jsonEncode(usr), useToken: false);
    final converted = UserModel.fromJson(rawData).toEntity();

    return converted;
  }

  Future<Map<String, dynamic>> updateUser(Map<String, dynamic> usr) async { // TODO: Change to User entity
    //final content = cont.toModel().toJson();
    final rawData = await _apiProvider.put('usuario/atualizar', jsonEncode(usr));
    //final converted = UserModel.fromJson(rawData).toEntity();

    return rawData;
  }

  Future<UserModel> getUserData() async {
    final rawData = await _apiProvider.get('usuario/dados');

    return UserModel.fromJson(rawData);
  }

  Future<GeneralUserInfo> getGeneralInfo() async {
    final rawData = await _apiProvider.get('usuario/info');

    return GeneralUserInfo.fromJson(rawData);
  }

  Future<List<Seal>> getSeals(User user) async {
    final rawData = await _apiProvider.get('usuario/${user.id}/selos');

    Log.d('$runtimeType', 'rawData $rawData');
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
