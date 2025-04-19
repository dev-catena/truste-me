import 'dart:ui';

import 'package:equatable/equatable.dart';

import '../../../../core/utils/custom_colors.dart';
import '../../../common/domain/entities/person.dart';
import '../../presentation/widgets/components/connection_tile.dart';

class Connection extends Equatable {
  final int id;
  final Person user;
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

  @override
  List<Object?> get props => [id, user, status];
}

enum ConnectionStatus {
  pending('Pendente', CustomColor.pendingYellow),
  accepted('Aceito', CustomColor.activeColor),
  cancelled('Cancelada', CustomColor.vividRed);

  final String description;
  final Color color;

  factory ConnectionStatus.fromString(final String value) {
    return ConnectionStatus.values.firstWhere((element) => element.description == value);
  }

  const ConnectionStatus(this.description, this.color);
}