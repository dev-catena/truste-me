part of 'user_data_cubit.dart';

@immutable
sealed class UserDataState {}

final class UserDataInitial extends UserDataState {}

final class UserDataLoading extends UserDataState {}

final class UserDataError extends UserDataState {
  final String message;

  UserDataError(this.message);
}

final class UserDataReady extends UserDataState {
  final User user;
  final GeneralUserInfo userInfo;
  final List<Contract> contracts;
  final List<Connection> connections;
  final ConnectionRequestStatus connectionRequestStatus;
  final UserDataEvent? event;

  UserDataReady({
    required this.user,
    required this.userInfo,
    required this.contracts,
    required this.connections,
    this.connectionRequestStatus = ConnectionRequestStatus.initial,
    this.event,
  });

  static const _sentinel = Object();

  UserDataReady copyWith({
    Object? user = _sentinel,
    Object? userInfo = _sentinel,
    Object? contracts = _sentinel,
    Object? connections = _sentinel,
    Object? connectionRequestStatus = _sentinel,
    UserDataEvent? event,
  }) {
    return UserDataReady(
      user: identical(user, _sentinel) ? this.user : user as User,
      userInfo: identical(userInfo, _sentinel) ? this.userInfo : userInfo as GeneralUserInfo,
      contracts: identical(contracts, _sentinel) ? this.contracts : contracts as List<Contract>,
      connections: identical(connections, _sentinel) ? this.connections : connections as List<Connection>,
      connectionRequestStatus: identical(connectionRequestStatus, _sentinel) ? this.connectionRequestStatus : connectionRequestStatus as ConnectionRequestStatus,
      event: event,
    );
  }
}
