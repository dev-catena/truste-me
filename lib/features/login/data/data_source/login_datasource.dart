import 'dart:convert';


import '../../../../core/api_provider.dart';
import '../../../../core/providers/app_data_cubit.dart';
import '../../../../core/providers/user_data_cubit.dart';
import '../../../common/data/models/user_model.dart';

class LoginDataSource {
  final bool useToken;
  final UserDataCubit userData;
  final AppDataCubit appData;

  LoginDataSource(this.useToken, this.userData, this.appData);

  late final ApiProvider _apiProvider = ApiProvider(useToken);

  Future<bool> login(String cpf, String pwd) async {
    final content = {'CPF': cpf, 'password': pwd};
    final rawData = await _apiProvider.post('login', jsonEncode(content));

    if (rawData['user'] != null) {
      final user = UserModel.fromJson(rawData).toEntity();
      await userData.initialize(user);
      await appData.initialize();
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
