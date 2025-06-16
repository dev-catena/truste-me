import 'dart:ui';

import 'package:equatable/equatable.dart';

import '../../../../core/utils/custom_colors.dart';
import '../../../common/domain/entities/user.dart';
import '../../presentation/widgets/components/connection_tile.dart';

class Connection extends Equatable {
  final int id;
  final User user;
  final ConnectionStatus status;
  final DateTime since;

  ConnectionTile buildTile(){
    return ConnectionTile(this);
  }

  const Connection({
    required this.id,
    required this.user,
    required this.status,
    required this.since,
  });

  static const _sentinel = Object();

  Connection copyWith({
    Object? id = _sentinel,
    Object? user = _sentinel,
    Object? status = _sentinel,
    Object? since = _sentinel,
  }) {
    return Connection(
      id: identical(id, _sentinel) ? this.id : id as int,
      user: identical(user, _sentinel) ? this.user : user as User,
      status: identical(status, _sentinel) ? this.status : status as ConnectionStatus,
      since: identical(since, _sentinel) ? this.since : since as DateTime,
    );
  }

  @override
  List<Object?> get props => [id, user, status];
}

enum ConnectionStatus {
  pending('Pendente', CustomColor.pendingYellow),
  accepted('Aceito', CustomColor.activeColor),
  // cancelled('Aguardando aceitação', CustomColor.activeGreyed);
  cancelled('Aguardando resposta', CustomColor.activeGreyed);

  final String description;
  final Color color;

  factory ConnectionStatus.fromString(final String value) {
    return ConnectionStatus.values.firstWhere((element) => element.description == value);
  }

  const ConnectionStatus(this.description, this.color);
}