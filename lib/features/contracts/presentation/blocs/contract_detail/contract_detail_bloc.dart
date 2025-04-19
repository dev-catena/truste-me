import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/data_source/contract_datasource.dart';
import '../../../domain/entities/clause.dart';
import '../../../domain/entities/contract.dart';

part 'contract_detail_event.dart';

part 'contract_detail_state.dart';

class ContractDetailBloc extends Bloc<ContractDetailEvent, ContractDetailState> {
  final ContractDataSource datasource;
  final Contract preliminaryContract;

  ContractDetailBloc(this.datasource, this.preliminaryContract) : super(ContractDetailInitial()) {
    on<ContractDetailStarted>(_onStarted);
    on<ContractDetailClauseSet>(_onClauseSet);
  }

  Future<void> _onStarted(ContractDetailStarted event, Emitter<ContractDetailState> emit) async {
    emit(ContractDetailLoadInProgress());

    List<Clause> possibleClauses = [];
    late final Contract contract;

    await Future.wait([
      datasource.getClausesForContractType(preliminaryContract.type).then((value) => possibleClauses = value),
      datasource.getContractFullInfo(preliminaryContract).then((value) => contract = value),
    ]);

    possibleClauses = _removeCurrentClausesFromAll(preliminaryContract.clauses, possibleClauses);

    emit(ContractDetailReady(contract: contract, possibleClauses: possibleClauses));
  }

  Future<void> _onClauseSet(ContractDetailClauseSet event, Emitter<ContractDetailState> emit) async {
    if (state is! ContractDetailReady) return;
    final internState = state as ContractDetailReady;
    final updatedContract = internState.contract..clauses.remove(event.selectedClause);

    final possibleClauses = internState.possibleClauses..remove(event.selectedClause);
    emit(internState.copyWith(contract: updatedContract, possibleClauses: possibleClauses));
  }

  List<Clause> _removeCurrentClausesFromAll(List<Clause> allClauses, List<Clause> currentClauses){

    for (final ele in currentClauses) {
      allClauses.removeWhere((element) => element == ele);
    }

    return allClauses;
  }
}
