import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../core/providers/user_data_cubit.dart';
import '../../data/data_source/connection_datasource.dart';
import '../../domain/entities/connection.dart';

part 'connection_panel_event.dart';
part 'connection_panel_state.dart';

class ConnectionPanelBloc extends Bloc<ConnectionPanelEvent, ConnectionPanelState> {
  final ConnectionDataSource dataSource;
  final UserDataCubit userData;

  ConnectionPanelBloc(this.userData, this.dataSource) : super(ConnectionPanelInitial()) {
    on<ConnectionPanelStarted>(_onStarted);
    on<ConnectionPanelRequested>(_onRequested);
  }

  Future<void> _onStarted(ConnectionPanelStarted event, Emitter<ConnectionPanelState> emit) async {
    try {
      final List<Connection> connections = [];

      // await Future.wait([
      //   dataSource.getConnectionsForUser().then((value) => connections = value),
      // ]);

      emit(ConnectionPanelReady(userData.getConnections));
    } catch (e){
      emit(ConnectionPanelError(e.toString()));
    }
  }

  Future<void> _onRequested(ConnectionPanelRequested event, Emitter<ConnectionPanelState> emit) async {
    await dataSource.requestConnection(event.userCode);
  }
}
