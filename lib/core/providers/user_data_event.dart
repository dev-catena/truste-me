import 'package:trustme/features/contracts/domain/entities/contract.dart';

abstract class UserDataEvent {}

class ConnectionRequestResult extends UserDataEvent {
  final bool isSuccess;
  final String message;

  ConnectionRequestResult({required this.isSuccess, required this.message});
}

class RefreshResult extends UserDataEvent {
  final bool isSuccess;
  final String message;

  RefreshResult({required this.isSuccess, required this.message});
}

class ContractCreationResult extends UserDataEvent {
  final bool isSuccess;
  final String message;
  final Contract? contract;

  ContractCreationResult({
    required this.isSuccess,
    required this.message,
    this.contract,
  });
}
