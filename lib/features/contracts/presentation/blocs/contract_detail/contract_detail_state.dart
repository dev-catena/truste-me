part of 'contract_detail_bloc.dart';

@immutable
sealed class ContractDetailState {}

final class ContractDetailInitial extends ContractDetailState {}

final class ContractDetailLoadInProgress extends ContractDetailState {}

final class ContractDetailReady extends ContractDetailState {
  final Contract contract;
  final List<Clause> possibleClauses;

  ContractDetailReady copyWith({
    Contract? contract,
    List<Clause>? possibleClauses,
  }) {
    return ContractDetailReady(
      contract: contract ?? this.contract,
      possibleClauses: possibleClauses ?? this.possibleClauses,
    );
  }

  ContractDetailReady({
    required this.contract,
    required this.possibleClauses,
  });
}

final class ContractDetailError extends ContractDetailState {
  final String msg;

  ContractDetailError(this.msg);
}
