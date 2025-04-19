import 'package:flutter/material.dart';

import '../../../../core/api_provider.dart';

class HomeDataSource {
  final ApiProvider _apiProvider = ApiProvider();

  Future<GeneralUserInfo> getGeneralInfo() async {
    final rawData = await _apiProvider.get('usuario/info');

    return GeneralUserInfo.fromJson(rawData);
  }
}

class GeneralUserInfo {
  final int activeContracts;
  final int pendingContracts;
  final int pendingSeals;
  final int activeConnections;
  final int pendingConnections;

  GeneralUserInfo.fromJson(Map<String, dynamic> json):this(
    activeContracts: json['contratos_por_status']['Ativo'],
    pendingContracts: json['contratos_por_status']['Pendente'],
    pendingSeals: json['selos_por_status']['pendentes'],
    activeConnections: json['conexoes']['ativas'],
    pendingConnections: json['conexoes']['ativas'],
  );

  GeneralUserInfo({required this.activeContracts, required this.pendingContracts, required this.pendingSeals, required this.activeConnections, required this.pendingConnections});

}