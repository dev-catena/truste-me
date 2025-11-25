part of 'contract_detail_bloc.dart';

@immutable
sealed class ContractDetailState {}

final class ContractDetailInitial extends ContractDetailState {}

class ContractDetailLoadInProgress extends ContractDetailState {}

class ContractDetailReady extends ContractDetailState {
  final Contract contract;
  final List<Clause> possibleClauses;
  final List<SexualPractice> possiblePractices;
  final ContractDetailEvent? event;

  ContractDetailReady({
    required this.contract,
    required this.possibleClauses,
    required this.possiblePractices,
    this.event,
  });

  static const _sentinel = Object();

  ContractDetailReady copyWith({
    Object? contract = _sentinel,
    Object? possibleClauses = _sentinel,
    Object? possiblePractices = _sentinel,
    ContractDetailEvent? event,
  }) {
    return ContractDetailReady(
      contract: identical(contract, _sentinel) ? this.contract : contract as Contract,
      possibleClauses: identical(possibleClauses, _sentinel) ? this.possibleClauses : possibleClauses as List<Clause>,
      possiblePractices: identical(possiblePractices, _sentinel) ? this.possiblePractices : possiblePractices as List<SexualPractice>,
      event: event,
    );
  }
}

class ContractDetailError extends ContractDetailState {
  final String msg;

  ContractDetailError(this.msg);
}
