import '../../../common/data/models/user_model.dart';
import '../../domain/entities/connection.dart';

class ConnectionModel extends Connection {
  ConnectionModel.fromJson(Map<String, dynamic> json)
      : super(
          id: json['id'],
          user: UserModel.fromJson(json['conectado_com']).toEntity(),
          status: ConnectionStatus.fromString(json['status']),
          // since: DateTime.parse(json['created_at'])..subtract(const Duration(hours: 3)),
          since: DateTime.parse(json['created_at']),
        );

  const ConnectionModel({required super.id, required super.user, required super.status, required super.since});

  Connection toEntity() {
    return Connection(
      id: id,
      user: user,
      status: status,
      since: since,
    );
  }
}
