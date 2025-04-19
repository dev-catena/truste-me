import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../common/domain/entities/person.dart';
import '../../../../conection/data/data_source/connection_datasource.dart';
import '../../../../conection/domain/entities/connection.dart';
import '../../../data/data_source/contract_datasource.dart';
import '../../../domain/entities/clause.dart';
import '../../../domain/entities/contract.dart';

part 'new_contract_event.dart';

part 'new_contract_state.dart';

class NewContractBloc extends Bloc<NewContractEvent, NewContractState> {
  final ConnectionDatasource connectionDatasource;
  final ContractDataSource dataSource;

  NewContractBloc(this.dataSource, this.connectionDatasource) : super(NewContractInitial()) {
    on<NewContractStarted>(_onStated);
    on<NewContractStakeHolderSelected>(_onStakeHolderSelected);
    on<NewContractTypeSelected>(_onTypeSelected);
    on<NewContractClauseAdded>(_onClauseAdded);
    on<NewContractContractCreated>(_onContractCreated);
  }

  Future<void> _onStated(NewContractStarted event, Emitter<NewContractState> emit) async {
    List<Connection> connections = [];

    await Future.wait([
      connectionDatasource.getConnectionsForUser().then(
            (value) => connections = value.where((element) => element.status == ConnectionStatus.accepted).toList(),
          ),
    ]);

    emit(NewContractReady(
      acceptedConnections: connections,
      clausesChosen: const [],
      possibleClauses: const [],
      stakeHolderSelected: null,
      contractTypeSelected: null,
    ));
  }

  Future<void> _onStakeHolderSelected(NewContractStakeHolderSelected event, Emitter<NewContractState> emit) async {
    if (state is! NewContractReady) return;
    final internalState = state as NewContractReady;

    emit(internalState.copyWith(stakeHolderSelected: event.stakeHolder));
  }

  Future<void> _onTypeSelected(NewContractTypeSelected event, Emitter<NewContractState> emit) async {
    if (state is! NewContractReady) return;
    final internalState = state as NewContractReady;
    final possibleClauses = await dataSource.getClausesForContractType(event.contractType);

    emit(internalState.copyWith(contractTypeSelected: event.contractType, possibleClauses: possibleClauses));
  }

  Future<void> _onClauseAdded(NewContractClauseAdded event, Emitter<NewContractState> emit) async {
    if (state is! NewContractReady) return;
    final internalState = state as NewContractReady;
    final clauses = List<Clause>.of(internalState.clausesChosen)..add(event.clause);

    emit(internalState.copyWith(clausesChosen: clauses));
  }

  Future<void> _onContractCreated(NewContractContractCreated event, Emitter<NewContractState> emit) async {
    if (state is! NewContractReady) return;
    final internalState = state as NewContractReady;

    if(internalState.contractTypeSelected == null || internalState.stakeHolderSelected == null){
      emit(NewContractInsufficientData());
      emit(internalState);
      return;
    }

    await dataSource.createContract(
      internalState.contractTypeSelected!,
      [internalState.stakeHolderSelected!],
      internalState.clausesChosen,
    );

    emit(NewContractCreationSuccess());
  }
}
