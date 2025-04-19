part of 'contract_detail_bloc.dart';

@immutable
sealed class ContractDetailEvent {}

class ContractDetailStarted extends ContractDetailEvent {}
class ContractDetailClauseSet extends ContractDetailEvent {
  final Clause selectedClause;

  ContractDetailClauseSet(this.selectedClause);
}
