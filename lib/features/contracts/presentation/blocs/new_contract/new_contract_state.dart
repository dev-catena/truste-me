part of 'new_contract_bloc.dart';

@immutable
sealed class NewContractState {}

final class NewContractInitial extends NewContractState {}

final class NewContractLoadInProgress extends NewContractState {}

final class NewContractReady extends NewContractState {
  final List<Connection> acceptedConnections;
  final List<Clause> possibleClauses;
  final List<Clause> clausesChosen;
  final Person? stakeHolderSelected;
  final ContractType? contractTypeSelected;

  NewContractReady copyWith({
    List<Connection>? acceptedConnections,
    List<Clause>? possibleClauses,
    List<Clause>? clausesChosen,
    Person? stakeHolderSelected,
    ContractType? contractTypeSelected,
  }) {
    return NewContractReady(
      acceptedConnections: acceptedConnections ?? this.acceptedConnections,
      stakeHolderSelected: stakeHolderSelected ?? this.stakeHolderSelected,
      contractTypeSelected: contractTypeSelected ?? this.contractTypeSelected,
      possibleClauses: possibleClauses ?? this.possibleClauses,
      clausesChosen: clausesChosen ?? this.clausesChosen,
    );
  }

  NewContractReady({
    required this.acceptedConnections,
    required this.stakeHolderSelected,
    required this.contractTypeSelected,
    required this.possibleClauses,
    required this.clausesChosen,
  });
}

final class NewContractCreationSuccess extends NewContractState {}

final class NewContractInsufficientData extends NewContractState {}