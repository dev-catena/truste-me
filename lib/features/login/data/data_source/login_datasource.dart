import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../../core/api_provider.dart';
import '../../../../core/providers/user_data_cubit.dart';
import '../../../common/data/models/person_model.dart';
import '../../../common/domain/entities/person.dart';

class LoginDataSource {
  final bool useToken;
  final UserDataCubit userData;

  LoginDataSource(this.useToken, this.userData);

  late final ApiProvider _apiProvider = ApiProvider(useToken);

  Future<bool> login(String cpf, String pwd) async {
    final content = {'CPF': cpf, 'password': pwd};
    final rawData = await _apiProvider.post('login', jsonEncode(content));

    if (rawData['user'] != null) {
      final user = PersonModel.fromJson(rawData).toEntity();
      await userData.initialize(user);
      // setLoggedInUser(user);
      return true;
    } else {
      return false;
    }
  }

  Future<void> logout() async {
    await _apiProvider.post('logout', jsonEncode({}));
    // setLoggedInUser(
    //   Person(
    //     id: 0,
    //     fullName: '',
    //     cpf: '',
    //     birthDate: DateTime.now(),
    //     memberSince: DateTime.now(),
    //     connectionCode: '',
    //     authToken: '',
    //   ),
    // );
  }
}
