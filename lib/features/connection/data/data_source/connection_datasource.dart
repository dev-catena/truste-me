import 'dart:convert';

import 'package:trustme/core/api_provider.dart';
import 'package:trustme/core/utils/http/custom_http_result.dart';
import 'package:trustme/core/utils/log/log.dart';
import 'package:trustme/features/connection/domain/entities/connection.dart';
import 'package:trustme/features/connection/data/models/connection_model.dart';

class ConnectionDataSource {
  final _apiProvider = ApiProvider();

  Future<List<Connection>> getConnectionsForUser() async {
    final httpResult = await _apiProvider.get('usuario/conexoes');
    // final httpResult = _MockData().connections;
    final List<Connection> connectionList = [];

    for (final ele in httpResult.result['pendentes']) {
      connectionList.add(ConnectionModel.fromJson(ele..['status'] = 'Solicitação Recebida').toEntity());
    }

    for (final ele in httpResult.result['ativas']) {
      connectionList.add(ConnectionModel.fromJson(ele..['status'] = 'Aceita').toEntity());
    }


    for (final ele in httpResult.result['aguardando_resposta']) {
      connectionList.add(ConnectionModel.fromJson(ele..['status'] = 'Solicitação Enviada').toEntity());
    }

    return connectionList;
  }

  // CHECKED
  Future<HttpResult> requestConnection(int code) async {
    final content = {'usuario_codigo': code};
    final httpResult = await _apiProvider.post('conexao/solicitar', jsonEncode(content));

    //Log.d('$runtimeType', 'httpResult $httpResult');
    return httpResult;
  }

  // CHECKED
  Future<HttpResult> acceptConnection(Connection connection, bool hasAccepted)async  {
    final content = {
      'conexao_id': connection.id,
      'aceito': hasAccepted ? 1 : 0,
    };

    final httpResult = await _apiProvider.post('conexao/responder', jsonEncode(content));

    return httpResult;
  }

  // CHECKED
  Future<HttpResult> deleteConnection(Connection user) async {
    final httpResult = await _apiProvider.delete('conexao/excluir/${user.id}');

    return httpResult;
  }
}
