part of 'connection_panel_bloc.dart';

@immutable
sealed class ConnectionPanelEvent {}

class ConnectionPanelStarted extends ConnectionPanelEvent {}

class ConnectionPanelRequested extends ConnectionPanelEvent {
  final int userCode;

  ConnectionPanelRequested(this.userCode);
}
