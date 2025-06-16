import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import '../../features/common/data/data_source/user_data_source.dart';
import '../../features/common/domain/entities/user.dart';
import '../../features/conection/data/data_source/connection_datasource.dart';
import '../../features/conection/domain/entities/connection.dart';
import '../../features/contracts/data/data_source/contract_datasource.dart';
import '../../features/contracts/domain/entities/clause.dart';
import '../../features/contracts/domain/entities/contract.dart';
import '../../features/contracts/domain/entities/contract_type.dart';
import '../../features/contracts/domain/entities/sexual_practice.dart';
import '../../features/home/data/data_source/home_datasource.dart';
import '../enums/connection_status.dart';

part 'user_data_state.dart';

class UserDataCubit extends Cubit<UserDataState> {
  final UserDataSource userDataSource;
  final ContractDataSource contractDataSource;
  final ConnectionDataSource connectionDataSource;

  late GeneralUserInfo _userInfo;

  UserDataCubit(
    this.userDataSource,
    this.contractDataSource,
    this.connectionDataSource,
  ) : super(UserDataInitial());

  User get getUser => (state as UserDataReady).user;

  GeneralUserInfo get getUserInfo => (state as UserDataReady).userInfo;

  List<Contract> get getContracts => (state as UserDataReady).contracts;

  List<Connection> get getConnections => (state as UserDataReady).connections;

  Future<void> initialize(User user) async {
    final List<Contract> contracts = [];
    final List<Connection> connections = [];

    setLoggedInUser(user);

    await Future.wait([
      userDataSource.getGeneralInfo().then((value) => _userInfo = value),
      contractDataSource.getContractsForUser(user).then((value) => contracts.addAll(value)),
      connectionDataSource.getConnectionsForUser(user).then((value) => connections.addAll(value)),
    ]);

    final activeContracts = contracts.where((element) => element.status == ContractStatus.active).length;
    final pendingContracts = contracts.where((element) => element.status == ContractStatus.pending).length;
    const pendingSeals = 0;
    final activeConnections = connections.where((element) => element.status == ConnectionStatus.accepted).length;
    final pendingConnections = connections.where((element) => element.status == ConnectionStatus.pending).length;

    final info = GeneralUserInfo(
      activeContracts: activeContracts,
      pendingContracts: pendingContracts,
      pendingSeals: pendingSeals,
      activeConnections: activeConnections,
      pendingConnections: pendingConnections,
    );
    emit(UserDataReady(
      user: user,
      userInfo: info,
      contracts: contracts,
      connections: connections,
    ));
  }

  Future<void> refreshUserInfo() async {
    final internState = state as UserDataReady;
    final info = await userDataSource.getGeneralInfo();

    emit(internState.copyWith(userInfo: info));
  }

  Future<void> establishConnection(final Connection connection, final bool accepted) async {
    final internState = state as UserDataReady;

    await connectionDataSource.acceptConnection(connection, accepted);
    final connectionIndex = internState.connections.indexOf(connection);
    final updatedConnections = List<Connection>.of(internState.connections);

    updatedConnections.removeAt(connectionIndex);

    if (accepted) {
      updatedConnections.insert(connectionIndex, connection.copyWith(status: ConnectionStatus.accepted));
    }

    emit(internState.copyWith(connections: updatedConnections));
  }

  Future<void> requestConnection(int userCode) async {
    final internState = state as UserDataReady;

    try {
      final resp = await connectionDataSource.requestConnection(userCode);

      if (resp.containsKey('error')) {
        emit(internState.copyWith(connectionRequestStatus: ConnectionRequestStatus.failure, requestMessage: (resp['error'] as String).toLowerCase()));
      } else {
        emit(internState.copyWith(connectionRequestStatus: ConnectionRequestStatus.success));
      }

      emit(internState.copyWith(connectionRequestStatus: ConnectionRequestStatus.initial));
    } catch (_) {
      final internState = state as UserDataReady;
      emit(internState.copyWith(connectionRequestStatus: ConnectionRequestStatus.failure));
    }
  }

  Future<void> deleteConnection(Connection connection) async {
    final internState = state as UserDataReady;

    await connectionDataSource.deleteConnection(connection);

    final connectionIndex = internState.connections.indexOf(connection);
    final updatedConnections = List<Connection>.of(internState.connections);

    updatedConnections.removeAt(connectionIndex);

    emit(internState.copyWith(connections: updatedConnections));
  }

  // Future<void> createContract(User user, ContractType type, List<Clause> clauses, List<SexualPractice> practicesTaken) async {
  //   final internState = state as UserDataReady;
  //
  //   final clausesId = clauses.map((e) => e.id).toList();
  //   clausesId.addAll(practicesTaken.map((e) => e.id));
  //
  //   final newContract = await contractDataSource.createContract(type, [user], clausesId);
  //   final updatedContracts = List<Contract>.of(internState.contracts)..insert(0, newContract);
  //   final updatedQuantity = internState.userInfo.pendingContracts + 1;
  //   final updatedInfo = internState.userInfo.copyWith(pendingContracts: updatedQuantity);
  //
  //   emit(internState.copyWith(contracts: updatedContracts, userInfo: updatedInfo));
  // }


  Future<void> createContract(Contract contract) async {
    final internState = state as UserDataReady;

    final model = contract.toModel();

    final newContract = await contractDataSource.createContract(model);
    final updatedContracts = List<Contract>.of(internState.contracts)..insert(0, newContract);
    final updatedQuantity = internState.userInfo.pendingContracts + 1;
    final updatedInfo = internState.userInfo.copyWith(pendingContracts: updatedQuantity);

    emit(internState.copyWith(contracts: updatedContracts, userInfo: updatedInfo));
  }

  Future<void> refreshContracts() async {
    final internState = state as UserDataReady;
    final newContracts = await contractDataSource.getContractsForUser(internState.user);

    emit(internState.copyWith(contracts: newContracts));
  }

  Future<void> refreshConnections(User user) async {
    final internState = state as UserDataReady;

    final updatedConnections = await connectionDataSource.getConnectionsForUser(user);
    debugPrint('$runtimeType - connections refreshed');

    emit(internState.copyWith(connections: updatedConnections));
  }
}
