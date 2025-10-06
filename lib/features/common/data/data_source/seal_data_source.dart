import 'package:trustme/core/api_provider.dart';
import 'package:trustme/features/common/domain/entities/seal.dart';

class SealDataSource {
  final ApiProvider _apiProvider = ApiProvider();
  
  Future<Map<String, dynamic>> requestSeal(Seal seal) async {
    if(seal.id == 1){
      return await _apiProvider.post('usuario/enviar-verificacao', '');
    } else {
      return {};
    }
  }
}