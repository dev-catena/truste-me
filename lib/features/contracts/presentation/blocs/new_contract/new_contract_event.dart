part of 'new_contract_bloc.dart';

@immutable
sealed class NewContractEvent {}

class NewContractStarted extends NewContractEvent {}

class NewContractStakeHolderSelected extends NewContractEvent {
  final Person stakeHolder;

  NewContractStakeHolderSelected(this.stakeHolder);
}

class NewContractTypeSelected extends NewContractEvent {
  final ContractType contractType;

  NewContractTypeSelected(this.contractType);
}

class NewContractClauseAdded extends NewContractEvent {
  final Clause clause;

  NewContractClauseAdded(this.clause);
}

class NewContractContractCreated extends NewContractEvent {
  NewContractContractCreated();
}
