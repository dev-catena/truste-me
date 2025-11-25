import 'package:trustme/features/contracts/domain/entities/clause.dart';
import 'package:trustme/features/contracts/domain/entities/contract.dart';
import 'package:trustme/features/contracts/domain/entities/sexual_practice.dart';

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

class SealRequestResult extends UserDataEvent {
  final bool isSuccess;
  final String message;

  SealRequestResult({required this.isSuccess, required this.message});
}

class ClausesFetchResult extends UserDataEvent {
  final bool isSuccess;
  final String? message; // Optional message for failure
  final List<Clause>? clauses;
  final List<SexualPractice>? practices;

  ClausesFetchResult({
    required this.isSuccess,
    this.message,
    this.clauses,
    this.practices,
  });
}
