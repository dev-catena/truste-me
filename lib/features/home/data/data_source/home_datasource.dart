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

  GeneralUserInfo copyWith({
    int? activeContracts,
    int? pendingContracts,
    int? pendingSeals,
    int? activeConnections,
    int? pendingConnections,
  }) {
    return GeneralUserInfo(
      activeContracts: activeContracts ?? this.activeContracts,
      pendingContracts: pendingContracts ?? this.pendingContracts,
      pendingSeals: pendingSeals ?? this.pendingSeals,
      activeConnections: activeConnections ?? this.activeConnections,
      pendingConnections: pendingConnections ?? this.pendingConnections,
    );
  }

  @override
  String toString() {
    return 'GeneralUserInfo('
        'activeContracts: $activeContracts, '
        'pendingContracts: $pendingContracts, '
        'pendingSeals: $pendingSeals, '
        'activeConnections: $activeConnections, '
        'pendingConnections: $pendingConnections)';
  }

  GeneralUserInfo({required this.activeContracts, required this.pendingContracts, required this.pendingSeals, required this.activeConnections, required this.pendingConnections});
}