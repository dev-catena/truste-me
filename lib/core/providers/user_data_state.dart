part of 'user_data_cubit.dart';

@immutable
sealed class UserDataState {}

final class UserDataInitial extends UserDataState {}

final class UserDataReady extends UserDataState {
  final Person user;
  final List<Contract> contracts;
  final List<Connection> connections;
  final GeneralUserInfo userInfo;
  final ConnectionRequestStatus connectionRequestStatus;

  UserDataReady({
    required this.user,
    required this.userInfo,
    required this.contracts,
    required this.connections,
    this.connectionRequestStatus = ConnectionRequestStatus.initial,
  });

  static const _sentinel = Object();

  UserDataReady copyWith({
    Object? user = _sentinel,
    Object? userInfo = _sentinel,
    Object? contracts = _sentinel,
    Object? connections = _sentinel,
    Object? connectionStatus = _sentinel,
  }) {
    return UserDataReady(
      user: identical(user, _sentinel) ? this.user : user as Person,
      userInfo: identical(userInfo, _sentinel) ? this.userInfo : userInfo as GeneralUserInfo,
      contracts: identical(contracts, _sentinel) ? this.contracts : contracts as List<Contract>,
      connections: identical(connections, _sentinel) ? this.connections : connections as List<Connection>,
      connectionRequestStatus: identical(connectionStatus, _sentinel) ? this.connectionRequestStatus : connectionStatus as ConnectionRequestStatus,
    );
  }
}
