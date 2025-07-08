part of 'user_data_cubit.dart';

@immutable
sealed class UserDataState {}

final class UserDataInitial extends UserDataState {}

final class UserDataReady extends UserDataState {
  final User user;
  final List<Contract> contracts;
  final List<Connection> connections;
  final ConnectionRequestStatus connectionRequestStatus;
  final String requestMessage;

  UserDataReady({
    required this.user,
    required this.contracts,
    required this.connections,
    this.connectionRequestStatus = ConnectionRequestStatus.initial,
    this.requestMessage = '',
  });

  static const _sentinel = Object();

  UserDataReady copyWith({
    Object? user = _sentinel,
    Object? userInfo = _sentinel,
    Object? contracts = _sentinel,
    Object? connections = _sentinel,
    Object? connectionRequestStatus = _sentinel,
    Object? requestMessage = _sentinel,
  }) {
    return UserDataReady(
      user: identical(user, _sentinel) ? this.user : user as User,
      contracts: identical(contracts, _sentinel) ? this.contracts : contracts as List<Contract>,
      connections: identical(connections, _sentinel) ? this.connections : connections as List<Connection>,
      connectionRequestStatus: identical(connectionRequestStatus, _sentinel) ? this.connectionRequestStatus : connectionRequestStatus as ConnectionRequestStatus,
      requestMessage: identical(requestMessage, _sentinel) ? this.requestMessage : requestMessage as String,
    );
  }
}
