import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:trustme/core/utils/http/custom_http_error.dart';

import 'package:trustme/core/providers/user_data_cubit.dart';
import 'package:trustme/core/utils/log/log.dart';
import 'package:trustme/features/contracts/data/data_source/contract_datasource.dart';
import 'package:trustme/features/contracts/domain/entities/contract.dart';

part 'contract_panel_event.dart';
part 'contract_panel_state.dart';

// WARNING: This class is not been used. UserDataCubit is used instead for ContractPanelScreen.
class ContractPanelBloc extends Bloc<ContractPanelEvent, ContractPanelState> {
  final ContractDataSource datasource;
  final UserDataCubit userData;

  ContractPanelBloc(this.datasource, this.userData) : super(ContractPanelInitial()) {
    on<ContractPanelStarted>(_onStarted);
  }

  // CHECKED
  Future<void> _onStarted(ContractPanelEvent event, Emitter<ContractPanelState> emit) async {
    emit(ContractPanelLoadInProgress());
    try {
      Log.d('$runtimeType', 'started');

      List<Contract> contracts = [];

      await Future.wait([
        datasource.getContractsForUser().then((value) => contracts = value),
      ]);

      emit(ContractPanelReady(contracts: contracts));
    } on HttpRequestException catch (e) {
      emit(ContractPanelError('Falha ao carregar contratos: ${e.message}'));
    } catch (e) {
      emit(ContractPanelError('Ocorreu um erro inesperado: ${e.toString()}'));
    }
  }
}
