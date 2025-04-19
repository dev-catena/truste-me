import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import '../../../data/data_source/contract_datasource.dart';
import '../../../domain/entities/contract.dart';

part 'contract_panel_event.dart';

part 'contract_panel_state.dart';

class ContractPanelBloc extends Bloc<ContractPanelEvent, ContractPanelState> {
  final ContractDataSource datasource;

  ContractPanelBloc(this.datasource) : super(ContractPanelInitial()) {
    on<ContractPanelStarted>(_onStarted);
  }

  Future<void> _onStarted(ContractPanelEvent event, Emitter<ContractPanelState> emit) async {
    // try {
      emit(ContractPanelLoadInProgress());
      debugPrint('$runtimeType - started');

      List<Contract> contracts = [];

      await Future.wait([
        datasource.getContractsForUser().then((value) => contracts = value),
      ]);

      emit(ContractPanelReady(contracts: contracts));
    // } catch (e, s) {
    //   emit(ContractError(e.toString()));
    // }
  }
}
