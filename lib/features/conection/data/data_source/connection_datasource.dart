import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../../core/api_provider.dart';
import '../../../common/domain/entities/user.dart';
import '../../domain/entities/connection.dart';
import '../models/connection_model.dart';

class ConnectionDataSource {
  final _apiProvider = ApiProvider();

  Future<List<Connection>> getConnectionsForUser(User user) async {
    final rawData = await _apiProvider.get('usuario/${user.id}/conexoes');
    // final rawData = _MockData().connections;
    final List<Connection> connectionList = [];

    for (final ele in rawData['pendentes']) {
      connectionList.add(ConnectionModel.fromJson(ele..['status'] = 'Pendente').toEntity());
    }

    for (final ele in rawData['ativas']) {
      connectionList.add(ConnectionModel.fromJson(ele..['status'] = 'Aceito').toEntity());
    }


    for (final ele in rawData['aguardando_resposta']) {
      connectionList.add(ConnectionModel.fromJson(ele..['status'] = 'Aguardando resposta').toEntity());
    }

    return connectionList;
  }

  Future<Map<String, dynamic>> requestConnection(int code) async {
    final content = {'usuario_codigo': code};
    final rawData = await _apiProvider.post('conexao/solicitar', jsonEncode(content));

    debugPrint('$runtimeType - rawData $rawData');
    return rawData;
  }

  Future<void> acceptConnection(Connection connection, bool hasAccepted)async  {
    final content = {
      'conexao_id': connection.id,
      'aceito': hasAccepted ? 1 : 0,
    };

    final rawData = await _apiProvider.post('conexao/responder', jsonEncode(content));
  }

  Future<void> deleteConnection(Connection user) async {
    await _apiProvider.delete('conexao/excluir/${user.id}');
  }
}
