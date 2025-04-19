part of 'contract_panel_bloc.dart';

@immutable
sealed class ContractPanelState {}

final class ContractPanelInitial extends ContractPanelState {}

class ContractPanelLoadInProgress extends ContractPanelState {}

class ContractPanelReady extends ContractPanelState {
  final List<Contract> contracts;

  ContractPanelReady({required this.contracts});
}

class ContractPanelError extends ContractPanelState {
  final String msg;

  ContractPanelError(this.msg);
}
