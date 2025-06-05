part of 'contract_detail_bloc.dart';

@immutable
sealed class ContractDetailState {}

final class ContractDetailInitial extends ContractDetailState {}

final class ContractDetailLoadInProgress extends ContractDetailState {}

final class ContractDetailReady extends ContractDetailState {
  final Contract contract;
  final List<Clause> possibleClauses;
  final List<SexualPractice> possiblePractices;

  static const _sentinel = Object();

  ContractDetailReady copyWith({
    Object? contract = _sentinel,
    Object? possibleClauses = _sentinel,
    Object? possiblePractices = _sentinel,
  }) {
    return ContractDetailReady(
      contract: contract == _sentinel ? this.contract : contract as Contract,
      possibleClauses: possibleClauses == _sentinel ? this.possibleClauses : possibleClauses as List<Clause>,
      possiblePractices: possiblePractices == _sentinel ? this.possiblePractices : possiblePractices as List<SexualPractice>,
    );
  }

  ContractDetailReady({
    required this.contract,
    required this.possibleClauses,
    required this.possiblePractices,
  });
}

final class ContractDetailError extends ContractDetailState {
  final String msg;

  ContractDetailError(this.msg);
}
