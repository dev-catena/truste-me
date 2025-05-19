import '../../../../core/api_provider.dart';
import '../../../home/data/data_source/home_datasource.dart';

class UserDataSource {
  final ApiProvider _apiProvider = ApiProvider();

  Future<GeneralUserInfo> getGeneralInfo() async {
    final rawData = await _apiProvider.get('usuario/info');

    return GeneralUserInfo.fromJson(rawData);
  }
}