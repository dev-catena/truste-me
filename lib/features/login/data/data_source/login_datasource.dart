import 'dart:convert';

import 'package:trustme/core/api_provider.dart';
import 'package:trustme/core/providers/app_data_cubit.dart';
import 'package:trustme/core/providers/user_data_cubit.dart';
import 'package:trustme/features/common/data/models/auth_model.dart';
import 'package:trustme/features/common/domain/entities/auth.dart';

class LoginDataSource {
  final bool useToken;
  final UserDataCubit userData;
  final AppDataCubit appData;

  LoginDataSource(this.useToken, this.userData, this.appData);

  late final ApiProvider _apiProvider = ApiProvider();

  Future<bool> login(String cpf, String pwd) async {
    final content = {'CPF': cpf, 'password': pwd};
    final rawData = await _apiProvider.post('login', jsonEncode(content), useToken: false);

    if (rawData.result['token'] != null) {
      final auth = AuthModel.fromJson(rawData.result).toEntity();
      await setAuthData(auth);
      await appData.initialize();
      return true;
    } else {
      return false;
    }
  }
}
