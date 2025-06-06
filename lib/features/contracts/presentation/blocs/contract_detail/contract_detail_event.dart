part of 'contract_detail_bloc.dart';

@immutable
sealed class ContractDetailEvent {}

class ContractDetailStarted extends ContractDetailEvent {}

class ContractDetailClauseAdded extends ContractDetailEvent {
  final Clause selectedClause;

  ContractDetailClauseAdded(this.selectedClause);
}

class ContractDetailClauseRemoved extends ContractDetailEvent {
  final Clause selectedClause;

  ContractDetailClauseRemoved(this.selectedClause);
}

class ContractDetailClauseSet extends ContractDetailEvent {
  final Clause selectedClause;
  final bool hasAccepted;

  ContractDetailClauseSet(this.selectedClause, this.hasAccepted);
}

class ContractDetailPracticeAdded extends ContractDetailEvent {
  final SexualPractice selectedPractice;

  ContractDetailPracticeAdded(this.selectedPractice);
}

class ContractDetailPracticeSet extends ContractDetailEvent {
  final SexualPractice selectedPractice;
  final bool hasAccepted;

  ContractDetailPracticeSet(this.selectedPractice, this.hasAccepted);
}
