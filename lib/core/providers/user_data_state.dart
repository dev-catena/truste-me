part of 'user_data_cubit.dart';

@immutable
sealed class UserDataState {}

final class UserDataInitial extends UserDataState {}

final class UserDataReady extends UserDataState {
  final User user;
  final List<Contract> contracts;
  final List<Connection> connections;
  final ConnectionRequestStatus connectionRequestStatus;
  final String message;

  UserDataReady({
    required this.user,
    required this.contracts,
    required this.connections,
    this.connectionRequestStatus = ConnectionRequestStatus.initial,
    this.message = '',
  });

  static const _sentinel = Object();

  UserDataReady copyWith({
    Object? user = _sentinel,
    Object? userInfo = _sentinel,
    Object? contracts = _sentinel,
    Object? connections = _sentinel,
    Object? connectionRequestStatus = _sentinel,
    Object? message = _sentinel,
  }) {
    return UserDataReady(
      user: identical(user, _sentinel) ? this.user : user as User,
      contracts: identical(contracts, _sentinel) ? this.contracts : contracts as List<Contract>,
      connections: identical(connections, _sentinel) ? this.connections : connections as List<Connection>,
      connectionRequestStatus: identical(connectionRequestStatus, _sentinel) ? this.connectionRequestStatus : connectionRequestStatus as ConnectionRequestStatus,
      message: identical(message, _sentinel) ? this.message : message as String,
    );
  }
}
