import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:trustme/core/utils/http/custom_http_error.dart';

import '../../../../../core/enums/contract_status.dart';
import '../../../../../core/utils/log/log.dart';
import '../../../../common/domain/entities/user.dart';
import '../../../data/data_source/contract_datasource.dart';
import '../../../domain/entities/clause.dart';
import '../../../domain/entities/contract.dart';
import '../../../domain/entities/contract_answer.dart';
import '../../../domain/entities/contract_signature.dart';
import '../../../domain/entities/sexual_practice.dart';

part 'contract_detail_event.dart';

part 'contract_detail_state.dart';

class ContractDetailBloc extends Bloc<ContractDetailEvent, ContractDetailState> {
  final ContractDataSource datasource;
  final Contract preliminaryContract;

  final Set<int> _clausesBeingProcessed = {};


  ContractDetailBloc(this.datasource, this.preliminaryContract) : super(ContractDetailInitial()) {
    on<ContractDetailStarted>(_onStarted);
    on<ContractDetailClauseAdded>(_onClauseAdded);
    on<ContractDetailClauseRemoved>(_onClauseRemoved);
    on<ContractDetailClauseSet>(_onClauseSet);
    on<ContractDetailPracticeAdded>(_onPracticeAdded);
    on<ContractDetailPracticeSet>(_onPracticeSet);
    on<ContractDetailContractFinished>(_onContractFinished); // TODO: Check it... it is not used?
    on<ContractDetailContractSigned>(_onContractSigned);
    on<ContractDetailContractQuestionAnswered>(_onQuestionAnswered);
    on<ContractDetailClearEvent>(_onClearEvent); // Register the handler
  }

  // Handler to clear the event
  void _onClearEvent(ContractDetailClearEvent event, Emitter<ContractDetailState> emit) {
    if (state is ContractDetailReady) {
      final internState = state as ContractDetailReady;
      emit(internState.copyWith(event: null));
    }
  }

  void _validateModification(ContractDetailReady internState) {
    if (internState.contract.signatures.isNotEmpty) {
      // return internState.contract.copyWith(signatures: []);
    }
  }

  // CHECKED
  Future<void> _onStarted(ContractDetailStarted event, Emitter<ContractDetailState> emit) async {
    emit(ContractDetailLoadInProgress());
    try {
      List<Clause> possibleClauses = [];
      List<SexualPractice> possiblePracs = [];
      late final Contract contract;

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
    } on HttpRequestException catch (e) {
      emit(ContractDetailError('Falha ao carregar o contrato: ${e.message}'));
    } catch (e) {
      emit(ContractDetailError('Ocorreu um erro inesperado: ${e.toString()}'));
    }
  }

  Future<void> _onClauseAdded(ContractDetailClauseAdded event, Emitter<ContractDetailState> emit) async {
    if (state is! ContractDetailReady) return;
    final internState = state as ContractDetailReady;
    final updatedContract = internState.contract
      ..clauses.add(
        event.selectedClause.copyWith(
          acceptedBy: [internState.contract.contractor.id],
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

  // FIXME: catch errors properly
  Future<void> _onClauseSet(ContractDetailClauseSet event, Emitter<ContractDetailState> emit) async {
    if (state is! ContractDetailReady) return;
    final internState = state as ContractDetailReady;


    final clauseId = event.selectedClause.id; // Assuming it has an ID
    if (_clausesBeingProcessed.contains(clauseId)) return;

    _clausesBeingProcessed.add(clauseId);
    try {
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
    } finally {
      _clausesBeingProcessed.remove(clauseId);
    }
  }

  Future<void> _onPracticeAdded(ContractDetailPracticeAdded event, Emitter<ContractDetailState> emit) async {
    if (state is! ContractDetailReady) return;
    final internState = state as ContractDetailReady;
    final updatedContract = internState.contract
      ..sexualPractices.add(
        event.selectedPractice.copyWith(
          acceptedBy: [internState.contract.contractor.id],
          pendingFor: internState.contract.stakeHolders.map((e) => e.id).toList(),
        ),
      );

    // final possibleClauses = internState.possibleClauses..remove(event.selectedClause);
    // final filteredClauses = List<Clause>.of(internState.possibleClauses);
    // filteredClauses.remove(event.selectedPractice);

    emit(internState.copyWith(contract: updatedContract));
  }

  // FIXME: catch errors properly
  Future<void> _onPracticeSet(ContractDetailPracticeSet event, Emitter<ContractDetailState> emit) async {
    if (state is! ContractDetailReady) return;
    final internState = state as ContractDetailReady;

    final clauseId = event.selectedPractice.id; // Assuming it has an ID
    if (_clausesBeingProcessed.contains(clauseId)) return;

    _clausesBeingProcessed.add(clauseId);
    try {
      await datasource.acceptOrDenyClause(
        internState.contract,
        event.selectedPractice.toClause(),
        event.hasAccepted,
      );

      final updatedPractice = internState.contract.sexualPractices
          .firstWhere((element) => element == event.selectedPractice);

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
      updatedClauseList[index] = updatedPractice;

      final updatedContract = internState.contract;
      updatedContract.sexualPractices
        ..clear()
        ..addAll(updatedClauseList);

      emit(internState.copyWith(contract: updatedContract));
    } finally {
      _clausesBeingProcessed.remove(clauseId);
    }
  }

  List<Clause> _removeCurrentClausesFromAll(List<Clause> allClauses, List<Clause> currentClauses) {
    for (final ele in currentClauses) {
      allClauses.remove(ele);
    }

    return allClauses;
  }

  // CHECKED
  // TODO: Check it... it is not used?
  Future<void> _onContractFinished(ContractDetailContractFinished event, Emitter<ContractDetailState> emit) async {
    if (state is! ContractDetailReady) return;
    final internState = state as ContractDetailReady;
    try {
      final refreshedContract = await datasource.getContractFullInfo(internState.contract);
      final updatedContract = refreshedContract.copyWith(status: ContractStatus.active);

      await datasource.updateContract(updatedContract);
      final finalContractState = await datasource.getContractFullInfo(internState.contract);

      emit(internState.copyWith(
        contract: finalContractState,
        event: ContractDetailActionResult(isSuccess: true, message: 'Contrato finalizado com sucesso!'),
      ));
    } on HttpRequestException catch (e) {
      emit(internState.copyWith(event: ContractDetailActionResult(isSuccess: false, message: e.message)));
    } catch (e) {
      emit(internState.copyWith(event: ContractDetailActionResult(isSuccess: false, message: 'Ocorreu um erro: ${e.toString()}')));
    }
  }

  // FIXME: catch errors properly
  Future<void> _onContractSigned(ContractDetailContractSigned event, Emitter<ContractDetailState> emit) async {
    if (state is! ContractDetailReady) return;
    final internState = state as ContractDetailReady;

    await datasource.signContract(internState.contract);
    final newSignature = ContractSignature(userId: userLoggedIn.id, dateTime: DateTime.now(), hasAccepted: true);
    final signaturesList = List.of(internState.contract.signatures)
      ..removeWhere((element) => element.userId == userLoggedIn.id)
      ..add(newSignature);

    Contract updatedContract = internState.contract.copyWith(signatures: signaturesList);
    // final refreshedContract = await datasource.getContractFullInfo(internState.contract);
    // final updatedContract = refreshedContract.copyWith(status: ContractStatus.active);
    //
    // await datasource.updateContract(updatedContract);
    // final evenNewer = await datasource.signContract(internState.contract);
    if (_isFullSigned(updatedContract)) {
      updatedContract = updatedContract.copyWith(status: ContractStatus.active);
      await datasource.finishContract(updatedContract);
    }
    emit(internState.copyWith(contract: updatedContract));
  }

  // FIXME: catch errors properly
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
    for (final ele in updatedAnswers) {
      Log.d('$runtimeType', 'updatedAnswers question id ${ele.questionId} - ${ele.answer}');
    }
    updatedAnswers.removeWhere((element) => element.questionId == event.question.id && element.userId == userLoggedIn.id);
    updatedAnswers.add(newAnswer);

    await datasource.answerQuestion(internState.contract, [newAnswer]);
    final updatedContract = internState.contract.copyWith(answers: updatedAnswers);

    emit(internState.copyWith(contract: updatedContract));
  }

  bool _isFullSigned(Contract contract) {
    final isSigned = contract.signatures.every((element) => element.hasAccepted);

    return isSigned;
  }
}
