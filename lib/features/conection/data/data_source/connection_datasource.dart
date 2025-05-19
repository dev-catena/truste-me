import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../../core/api_provider.dart';
import '../../../common/domain/entities/person.dart';
import '../../domain/entities/connection.dart';
import '../models/connection_model.dart';

class ConnectionDataSource {
  final _apiProvider = ApiProvider();

  Future<List<Connection>> getConnectionsForUser(Person user) async {
    final rawData = await _apiProvider.get('usuario/${user.id}/conexoes');
    // final rawData = _MockData().connections;
    final List<Connection> connectionList = [];

    for (final ele in rawData['pendentes']) {
      connectionList.add(ConnectionModel.fromJson(ele..['status'] = 'Pendente').toEntity());
    }

    for (final ele in rawData['ativas']) {
      connectionList.add(ConnectionModel.fromJson(ele..['status'] = 'Aceito').toEntity());
    }

    return connectionList;
  }

  Future<void> requestConnection(int code) async {
    final content = {'usuario_codigo': code};
    final rawData = await _apiProvider.post('conexao/solicitar', jsonEncode(content));

    debugPrint('$runtimeType - rawData $rawData');
  }

  Future<void> acceptConnection(Connection connection, bool hasAccepted)async  {
    final content = {
      'conexao_id': connection.id,
      'aceito': hasAccepted ? 1 : 0,
    };

    final rawData = await _apiProvider.post('conexao/responder', jsonEncode(content));
  }

  ConnectionDataSource();
}

class _MockData {
  final List<Map<String, dynamic>> connections = [
    {
      'id': 1,
      'usuario': {
        'id': 1,
        'nome': 'Maria das Graças',
        'cpf': '123.456.789-00',
        'idade': 24,
        'pais': 'Brasil',
        'estado': 'São Paulo',
        'profissao': 'Analista de Marketing',
        'caminho_foto': '',
        'codigo': 'maria#213545',
        'created_at': '2024-06-22',
        'selos': [
          {
            'id': 1,
            'descricao': 'Identidade',
            'status': 'Ativo',
            'obtido_em': '2025-10-12',
            'expira_em': '2030-10-12',
          },
          {
            'id': 2,
            'descricao': 'Endereço',
            'status': 'Em validação',
          },
          {
            'id': 3,
            'descricao': 'Renda',
            'status': 'Em validação',
          },
          {
            'id': 4,
            'descricao': 'Escolaridade',
            'status': 'Em validação',
          },
          {
            'id': 5,
            'descricao': 'Antecedentes',
            'status': 'Ausente',
          },
        ]
      },
      'status': 'Pendente',
      'created_at': '2025-01-17 19:58:10'
    },
    {
      'id': 2,
      'usuario': {
        'id': 2,
        'nome': 'Priscila Evangelista',
        'cpf': '123.456.789-00',
        'idade': 31,
        'pais': 'Brasil',
        'estado': 'Minas Gerais',
        'profissao': 'Empresária',
        'caminho_foto': '',
        'codigo': 'priscila#110015',
        'created_at': '2024-06-22',
        'selos': [
          {
            'descricao': 'Identidade',
            'status': 'Ativo',
            'obtido_em': '2025-10-12',
            'expira_em': '2030-10-12',
          },
          {
            'descricao': 'Endereço',
            'status': 'Ativo',
          },
          {
            'descricao': 'Renda',
            'status': 'Ativo',
          },
          {
            'descricao': 'Escolaridade',
            'status': 'Expirado',
          },
        ]
      },
      'status': 'Aceito',
      'created_at': '2025-01-17 19:58:10'
    },
  ];
}
