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

  Future<void> _onClauseSet(ContractDetailClauseSet event, Emitter<ContractDetailState> emit) async {
    if (state is! ContractDetailReady) return;
    final internState = state as ContractDetailReady;

    final clauseId = event.selectedClause.id;
    if (_clausesBeingProcessed.contains(clauseId)) return;

    final originalClauses = List<Clause>.of(internState.contract.clauses);
    final clauseIndex = originalClauses.indexWhere((c) => c.id == event.selectedClause.id);
    if (clauseIndex == -1) return;

    final clauseToUpdate = originalClauses[clauseIndex];
    final newPendingFor = List<int>.from(clauseToUpdate.pendingFor)..remove(userLoggedIn.id);
    final newAcceptedBy = List<int>.from(clauseToUpdate.acceptedBy);
    final newDeniedBy = List<int>.from(clauseToUpdate.deniedBy);

    if (event.hasAccepted) {
      if (!newAcceptedBy.contains(userLoggedIn.id)) newAcceptedBy.add(userLoggedIn.id);
      newDeniedBy.remove(userLoggedIn.id);
    } else {
      if (!newDeniedBy.contains(userLoggedIn.id)) newDeniedBy.add(userLoggedIn.id);
      newAcceptedBy.remove(userLoggedIn.id);
    }

    final updatedClause = clauseToUpdate.copyWith(
      pendingFor: newPendingFor,
      acceptedBy: newAcceptedBy,
      deniedBy: newDeniedBy,
    );

    final updatedClauses = List<Clause>.from(originalClauses);
    updatedClauses[clauseIndex] = updatedClause;

    final optimisticContract = internState.contract.copyWith(clauses: updatedClauses);
    emit(internState.copyWith(contract: optimisticContract));

    _clausesBeingProcessed.add(clauseId);

    try {
      await datasource.acceptOrDenyClause(internState.contract, event.selectedClause, event.hasAccepted);
      emit(internState.copyWith(
        contract: optimisticContract,
        event: ContractDetailActionResult(isSuccess: true, message: 'Cláusula atualizada com sucesso!'),
      ));
    } on HttpRequestException catch (e) {
      final revertedContract = internState.contract.copyWith(clauses: originalClauses);
      emit(internState.copyWith(contract: revertedContract));
      emit(internState.copyWith(event: ContractDetailActionResult(isSuccess: false, message: e.message)));
    } catch (e) {
      final revertedContract = internState.contract.copyWith(clauses: originalClauses);
      emit(internState.copyWith(contract: revertedContract));
      emit(internState.copyWith(event: ContractDetailActionResult(isSuccess: false, message: 'Ocorreu um erro: ${e.toString()}')));
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

    emit(internState.copyWith(contract: updatedContract));
  }

  Future<void> _onPracticeSet(ContractDetailPracticeSet event, Emitter<ContractDetailState> emit) async {
    if (state is! ContractDetailReady) return;
    final internState = state as ContractDetailReady;

    final practiceId = event.selectedPractice.id;
    if (_clausesBeingProcessed.contains(practiceId)) return;

    final originalPractices = List<SexualPractice>.of(internState.contract.sexualPractices);
    final practiceIndex = originalPractices.indexWhere((p) => p.id == event.selectedPractice.id);

    if (practiceIndex == -1) return;

    final practiceToUpdate = originalPractices[practiceIndex];
    final newPendingFor = List<int>.from(practiceToUpdate.pendingFor ?? [])..remove(userLoggedIn.id);
    final newAcceptedBy = List<int>.from(practiceToUpdate.acceptedBy ?? []);
    final newDeniedBy = List<int>.from(practiceToUpdate.deniedBy ?? []);

    if (event.hasAccepted) {
      if (!newAcceptedBy.contains(userLoggedIn.id)) newAcceptedBy.add(userLoggedIn.id);
      newDeniedBy.remove(userLoggedIn.id);
    } else {
      if (!newDeniedBy.contains(userLoggedIn.id)) newDeniedBy.add(userLoggedIn.id);
      newAcceptedBy.remove(userLoggedIn.id);
    }

    final updatedPractice = practiceToUpdate.copyWith(
      pendingFor: newPendingFor,
      acceptedBy: newAcceptedBy,
      deniedBy: newDeniedBy,
    );

    final updatedPractices = List<SexualPractice>.from(originalPractices);
    updatedPractices[practiceIndex] = updatedPractice;

    final optimisticContract = internState.contract.copyWith(sexualPractices: updatedPractices);
    emit(internState.copyWith(contract: optimisticContract));

    _clausesBeingProcessed.add(practiceId);

    try {
      await datasource.acceptOrDenyClause(
        internState.contract,
        event.selectedPractice.toClause(),
        event.hasAccepted,
      );
      emit(internState.copyWith(
        contract: optimisticContract,
        event: ContractDetailActionResult(isSuccess: true, message: 'Prática atualizada com sucesso!'),
      ));
    } on HttpRequestException catch (e) {
      final revertedContract = internState.contract.copyWith(sexualPractices: originalPractices);
      emit(internState.copyWith(contract: revertedContract));
      emit(internState.copyWith(event: ContractDetailActionResult(isSuccess: false, message: e.message)));
    } catch (e) {
      final revertedContract = internState.contract.copyWith(sexualPractices: originalPractices);
      emit(internState.copyWith(contract: revertedContract));
      emit(internState.copyWith(event: ContractDetailActionResult(isSuccess: false, message: 'Ocorreu um erro: ${e.toString()}')));
    } finally {
      _clausesBeingProcessed.remove(practiceId);
    }
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

  Future<void> _onContractSigned(ContractDetailContractSigned event, Emitter<ContractDetailState> emit) async {
    if (state is! ContractDetailReady) return;
    final internState = state as ContractDetailReady;

    final originalSignatures = List<ContractSignature>.of(internState.contract.signatures);
    final originalStatus = internState.contract.status;

    final newSignature = ContractSignature(userId: userLoggedIn.id, dateTime: DateTime.now(), hasAccepted: true);
    final optimisticSignatures = List.of(originalSignatures)
      ..removeWhere((element) => element.userId == userLoggedIn.id)
      ..add(newSignature);

    Contract optimisticContract = internState.contract.copyWith(signatures: optimisticSignatures);
    final shouldFinishContract = optimisticSignatures.every((element) => element.hasAccepted);
    if (shouldFinishContract) {
      optimisticContract = optimisticContract.copyWith(status: ContractStatus.active);
    }

    emit(internState.copyWith(contract: optimisticContract));

    try {
      await datasource.signContract(internState.contract);
      if (shouldFinishContract) {
        await datasource.finishContract(optimisticContract);
      }

      emit(internState.copyWith(
        contract: optimisticContract,
        event: ContractDetailActionResult(isSuccess: true, message: 'Contrato assinado com sucesso!'),
      ));
    } on HttpRequestException catch (e) {
      final revertedContract = internState.contract.copyWith(signatures: originalSignatures, status: originalStatus);
      emit(internState.copyWith(
          contract: revertedContract,
          event: ContractDetailActionResult(isSuccess: false, message: e.message)));
    } catch (e) {
      final revertedContract = internState.contract.copyWith(signatures: originalSignatures, status: originalStatus);
      emit(internState.copyWith(
          contract: revertedContract,
          event: ContractDetailActionResult(isSuccess: false, message: 'Ocorreu um erro: ${e.toString()}')));
    }
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
    final oldAnswersBK = List.of(internState.contract.answers);

    for (final ele in updatedAnswers) {
      Log.d('$runtimeType', 'updatedAnswers question id ${ele.questionId} - ${ele.answer}');
    }
    updatedAnswers.removeWhere((element) => element.questionId == event.question.id && element.userId == userLoggedIn.id);
    updatedAnswers.add(newAnswer);

    final updatedContract = internState.contract.copyWith(answers: updatedAnswers);
    emit(internState.copyWith(contract: updatedContract));

    try {
      await datasource.answerQuestion(internState.contract, [newAnswer]);
      emit(internState.copyWith(
        contract: updatedContract,
        event: ContractDetailActionResult(isSuccess: true, message: 'Resposta enviada!'),
      ));
    } on HttpRequestException catch (e) {
      final oldContract = internState.contract.copyWith(answers: oldAnswersBK);
      emit(internState.copyWith(contract: oldContract));
      emit(internState.copyWith(event: ContractDetailActionResult(isSuccess: false, message: e.message)));
    } catch (e) {
      final oldContract = internState.contract.copyWith(answers: oldAnswersBK);
      emit(internState.copyWith(contract: oldContract));
      emit(internState.copyWith(event: ContractDetailActionResult(isSuccess: false, message: 'Ocorreu um erro: ${e.toString()}')));
    }
  }
}
