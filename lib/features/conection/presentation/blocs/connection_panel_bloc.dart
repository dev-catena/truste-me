import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../data/data_source/connection_datasource.dart';
import '../../domain/entities/connection.dart';

part 'connection_panel_event.dart';
part 'connection_panel_state.dart';

class ConnectionPanelBloc extends Bloc<ConnectionPanelEvent, ConnectionPanelState> {
  final ConnectionDatasource dataSource;

  ConnectionPanelBloc(this.dataSource) : super(ConnectionPanelInitial()) {
    on<ConnectionPanelStarted>(_onStarted);
    on<ConnectionPanelRequested>(_onRequested);
  }

  Future<void> _onStarted(ConnectionPanelStarted event, Emitter<ConnectionPanelState> emit) async {
    List<Connection> connections = [];

    await Future.wait([
      dataSource.getConnectionsForUser().then((value) => connections = value),
    ]);

    emit(ConnectionPanelReady(connections));
  }

  Future<void> _onRequested(ConnectionPanelRequested event, Emitter<ConnectionPanelState> emit) async {
    await dataSource.requestConnection(event.userCode);
  }
}
