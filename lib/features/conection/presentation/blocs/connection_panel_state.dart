part of 'connection_panel_bloc.dart';

@immutable
sealed class ConnectionPanelState {}

final class ConnectionPanelInitial extends ConnectionPanelState {}

final class ConnectionPanelLoadInProgress extends ConnectionPanelState {}

final class ConnectionPanelReady extends ConnectionPanelState {
  final List<Connection> connections;

  ConnectionPanelReady(this.connections);
}

final class ConnectionPanelError extends ConnectionPanelState {
  final String error;

  ConnectionPanelError(this.error);
}
