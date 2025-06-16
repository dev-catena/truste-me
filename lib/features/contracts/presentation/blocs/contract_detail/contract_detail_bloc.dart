import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import '../../../../common/domain/entities/user.dart';
import '../../../data/data_source/contract_datasource.dart';
import '../../../domain/entities/clause.dart';
import '../../../domain/entities/contract.dart';
import '../../../domain/entities/sexual_practice.dart';

part 'contract_detail_event.dart';

part 'contract_detail_state.dart';

class ContractDetailBloc extends Bloc<ContractDetailEvent, ContractDetailState> {
  final ContractDataSource datasource;
  final Contract preliminaryContract;

  ContractDetailBloc(this.datasource, this.preliminaryContract) : super(ContractDetailInitial()) {
    on<ContractDetailStarted>(_onStarted);
    on<ContractDetailClauseAdded>(_onClauseAdded);
    on<ContractDetailClauseRemoved>(_onClauseRemoved);
    on<ContractDetailClauseSet>(_onClauseSet);
    on<ContractDetailPracticeAdded>(_onPracticeAdded);
    on<ContractDetailPracticeSet>(_onPracticeSet);
    on<ContractDetailContractFinished>(_onContractFinished);
    on<ContractDetailContractSigned>(_onContractSigned);
    on<ContractDetailContractQuestionAnswered>(_onQuestionAnswered);
  }

  void _validateModification(ContractDetailReady internState) {
    if (internState.contract.signatures.isNotEmpty) {
      // return internState.contract.copyWith(signatures: []);
    }
  }

  Future<void> _onStarted(ContractDetailStarted event, Emitter<ContractDetailState> emit) async {
    emit(ContractDetailLoadInProgress());

    List<Clause> possibleClauses = [];
    List<SexualPractice> possiblePracs = [];
    late final Contract contract;

    // try {
    await Future.wait([
      datasource.getClausesForContractType(preliminaryContract.type).then((value) {
        possibleClauses = value.clauses;
        possiblePracs = value.practices;
      }),
      datasource.getContractFullInfo(preliminaryContract).then((value) => contract = value),
    ]);

    final List<Clause> contractClauses = List<Clause>.of(contract.clauses);

    final filteredClauses = _removeCurrentClausesFromAll(possibleClauses, contractClauses);

    emit(ContractDetailReady(
      contract: contract,
      possibleClauses: filteredClauses,
      possiblePractices: possiblePracs,
    ));
    // } catch(e, s){
    //   emit(ContractDetailError(e.toString()));
    // }
  }

  Future<void> _onClauseAdded(ContractDetailClauseAdded event, Emitter<ContractDetailState> emit) async {
    if (state is! ContractDetailReady) return;
    final internState = state as ContractDetailReady;
    final updatedContract = internState.contract
      ..clauses.add(
        event.selectedClause.copyWith(
          acceptedBy: [internState.contract.contractor!.id],
          pendingFor: internState.contract.stakeHolders.map((e) => e.id).toList(),
        ),
      );

    // final possibleClauses = internState.possibleClauses..remove(event.selectedClause);
    final filteredClauses = List<Clause>.of(internState.possibleClauses);
    filteredClauses.remove(event.selectedClause);

    // emit(internState.copyWith(contract: updatedContract, possibleClauses: filteredClauses));
    emit(internState.copyWith(contract: updatedContract));
  }

  Future<void> _onClauseRemoved(ContractDetailClauseRemoved event, Emitter<ContractDetailState> emit) async {
    if (state is! ContractDetailReady) return;
    final internState = state as ContractDetailReady;
    final updatedContract = internState.contract..clauses.remove(event.selectedClause);

    // final possibleClauses = internState.possibleClauses..remove(event.selectedClause);
    final filteredClauses = List<Clause>.of(internState.possibleClauses);
    filteredClauses.remove(event.selectedClause);

    // emit(internState.copyWith(contract: updatedContract, possibleClauses: filteredClauses));
    emit(internState.copyWith(contract: updatedContract));
  }

  Future<void> _onClauseSet(ContractDetailClauseSet event, Emitter<ContractDetailState> emit) async {
    if (state is! ContractDetailReady) return;
    final internState = state as ContractDetailReady;

    await datasource.acceptOrDenyClause(internState.contract, event.selectedClause, event.hasAccepted);
    final updatedClause = internState.contract.clauses.firstWhere((element) => element == event.selectedClause);

    // late final Clause updatedClause;
    // late final int clauseIndex;
    //
    // if (isSexual) {
    //   updatedClause =
    //       internState.contract.sexualPractices.firstWhere((element) => element == event.selectedClause).toClause();
    //   clauseIndex = internState.contract.sexualPractices.indexOf(updatedClause);
    // } else {
    //   updatedClause = internState.contract.clauses.firstWhere((element) => element == event.selectedClause);
    //   clauseIndex = internState.contract.clauses.indexOf(event.selectedClause);
    // }

    updatedClause.pendingFor.remove(userLoggedIn.id);

    if (event.hasAccepted) {
      updatedClause.deniedBy.remove(userLoggedIn.id);
      updatedClause.acceptedBy.add(userLoggedIn.id);
    } else {
      updatedClause.acceptedBy.remove(userLoggedIn.id);
      updatedClause.deniedBy.add(userLoggedIn.id);
    }

    final index = internState.contract.clauses.indexOf(event.selectedClause);
    final updatedClauseList = List.of(internState.contract.clauses);

    updatedClauseList.removeAt(index);
    updatedClauseList.insert(index, updatedClause);

    final updatedContract = internState.contract;
    updatedContract.clauses.clear();
    updatedContract.clauses.addAll(updatedClauseList);

    emit(internState.copyWith(contract: updatedContract));
  }

  Future<void> _onPracticeAdded(ContractDetailPracticeAdded event, Emitter<ContractDetailState> emit) async {
    if (state is! ContractDetailReady) return;
    final internState = state as ContractDetailReady;
    final updatedContract = internState.contract
      ..sexualPractices.add(
        event.selectedPractice.copyWith(
          acceptedBy: [internState.contract.contractor!.id],
          pendingFor: internState.contract.stakeHolders.map((e) => e.id).toList(),
        ),
      );

    // final possibleClauses = internState.possibleClauses..remove(event.selectedClause);
    // final filteredClauses = List<Clause>.of(internState.possibleClauses);
    // filteredClauses.remove(event.selectedPractice);

    emit(internState.copyWith(contract: updatedContract));
  }

  Future<void> _onPracticeSet(ContractDetailPracticeSet event, Emitter<ContractDetailState> emit) async {
    if (state is! ContractDetailReady) return;
    final internState = state as ContractDetailReady;

    await datasource.acceptOrDenyClause(internState.contract, event.selectedPractice.toClause(), event.hasAccepted);
    final updatedPractice =
        internState.contract.sexualPractices.firstWhere((element) => element == event.selectedPractice);

    updatedPractice.pendingFor!.remove(userLoggedIn.id);

    if (event.hasAccepted) {
      updatedPractice.deniedBy!.remove(userLoggedIn.id);
      updatedPractice.acceptedBy!.add(userLoggedIn.id);
    } else {
      updatedPractice.acceptedBy!.remove(userLoggedIn.id);
      updatedPractice.deniedBy!.add(userLoggedIn.id);
    }

    final index = internState.contract.sexualPractices.indexOf(event.selectedPractice);
    final updatedClauseList = List.of(internState.contract.sexualPractices);

    updatedClauseList.removeAt(index);
    updatedClauseList.insert(index, updatedPractice);

    final updatedContract = internState.contract;
    updatedContract.sexualPractices.clear();
    updatedContract.sexualPractices.addAll(updatedClauseList);

    emit(internState.copyWith(contract: updatedContract));
  }

  List<Clause> _removeCurrentClausesFromAll(List<Clause> allClauses, List<Clause> currentClauses) {
    for (final ele in currentClauses) {
      allClauses.remove(ele);
    }

    return allClauses;
  }

  Future<void> _onContractFinished(ContractDetailContractFinished event, Emitter<ContractDetailState> emit) async {
    if (state is! ContractDetailReady) return;
    final internState = state as ContractDetailReady;
    final refreshedContract = await datasource.getContractFullInfo(internState.contract);
    final updatedContract = refreshedContract.copyWith(status: ContractStatus.active);

    await datasource.updateContract(updatedContract);
    final evenNewer = await datasource.getContractFullInfo(internState.contract);

    emit(internState.copyWith(contract: evenNewer));
  }

  Future<void> _onContractSigned(ContractDetailContractSigned event, Emitter<ContractDetailState> emit) async {
    if (state is! ContractDetailReady) return;
    final internState = state as ContractDetailReady;
    final refreshedContract = await datasource.getContractFullInfo(internState.contract);
    final updatedContract = refreshedContract.copyWith(status: ContractStatus.active);

    await datasource.updateContract(updatedContract);
    final evenNewer = await datasource.signContract(internState.contract);

    // emit(internState.copyWith(contract: evenNewer));
  }

  Future<void> _onQuestionAnswered(
    ContractDetailContractQuestionAnswered event,
    Emitter<ContractDetailState> emit,
  ) async {
    if (state is! ContractDetailReady) return;
    final internState = state as ContractDetailReady;

    final newAnswer = ContractAnswer(
      questionId: event.question.id,
      answer: event.answer,
      userId: userLoggedIn.id,
    );

    final updatedAnswers = List.of(internState.contract.answers);
    for(final ele in updatedAnswers){
      debugPrint('updatedAnswers question id ${ele.questionId} - ${ele.answer}');
    }
    updatedAnswers.removeWhere((element) => element.questionId == event.question.id && element.userId == userLoggedIn.id);
    updatedAnswers.add(newAnswer);

    await datasource.answerQuestion(internState.contract, [newAnswer]);
    final updatedContract = internState.contract.copyWith(answers: updatedAnswers);

    emit(internState.copyWith(contract: updatedContract));
  }
}
