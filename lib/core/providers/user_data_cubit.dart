import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:trustme/core/providers/user_data_event.dart';
import 'package:trustme/core/utils/firebase/crashlytics_util.dart';
import 'package:trustme/core/utils/http/custom_http_error.dart';
import 'package:trustme/core/utils/preferences/app_preferences.dart';

import 'package:trustme/features/common/data/data_source/user_data_source.dart';
import 'package:trustme/features/common/domain/entities/seal.dart';
import 'package:trustme/features/common/domain/entities/user.dart';
import 'package:trustme/features/connection/data/data_source/connection_datasource.dart';
import 'package:trustme/features/connection/domain/entities/connection.dart';
import 'package:trustme/features/contracts/data/data_source/contract_datasource.dart';
import 'package:trustme/features/contracts/domain/entities/contract.dart';
import 'package:trustme/core/enums/connection_status.dart';

part 'user_data_state.dart';

class UserDataCubit extends Cubit<UserDataState> {
  final UserDataSource userDataSource;
  final ContractDataSource contractDataSource;
  final ConnectionDataSource connectionDataSource;

  // late GeneralUserInfo _userInfo;

  UserDataCubit(
    this.userDataSource,
    this.contractDataSource,
    this.connectionDataSource,
  ) : super(UserDataInitial());

  User get getUser => (state as UserDataReady).user;

  List<Contract> get getContracts => (state as UserDataReady).contracts;

  List<Connection> get getConnections => (state as UserDataReady).connections;

  // FIXME: catch errors properly
  Future<void> initialize(User user) async {
    final List<Contract> contracts = [];
    final List<Connection> connections = [];
    final List<Seal> seals = [];

    setLoggedInUser(user);

    //await refreshUserInfo();

    await Future.wait([
      // userDataSource.getGeneralInfo().then((value) => _userInfo = value),
      userDataSource.getSeals(user).then((value) => seals.addAll(value)),
      contractDataSource.getContractsForUser().then((value) => contracts.addAll(value)),
      connectionDataSource.getConnectionsForUser().then((value) => connections.addAll(value)),
    ]);

    user.sealsObtained.clear();
    user.sealsObtained.addAll(seals);

    //region ## SET USER DATA TO PREFERENCES
    final prefs = AppPreferences();
    await prefs.setString(KeyPrefs.USER_CODE, user.connectionCode.toString());
    await prefs.setString(KeyPrefs.USER_FULL_NAME, user.fullName.toString());
    await prefs.setString(KeyPrefs.USER_CPF, user.cpf.toString());
    await prefs.setString(KeyPrefs.USER_EMAIL, user.email.toString());

    // Set Crashlytics variables
    CrashlyticsUtil.setCrashlyticsCustomVariables();
    CrashlyticsUtil.setUserIdentifier(user.id.toString(), user.fullName);
    //endregion

    emit(UserDataReady(
      user: user,
      contracts: contracts,
      connections: connections,
    ));
  }

  // FIXME: catch errors properly
  Future<void> refreshUserInfo() async {
    final internState = state as UserDataReady;
    final info = await userDataSource.getGeneralInfo();

    emit(internState.copyWith(userInfo: info));
  }

  // FIXME: catch errors properly
  Future<void> establishConnection(final Connection connection, final bool accepted) async {
    final internState = state as UserDataReady;

    // try {
    //
    // } on HttpRequestException catch (e, s) {
    //   emit(internState.copyWith(connectionRequestStatus: ConnectionRequestStatus.failure, message: e.message));
    // } on Exception catch(e, s) {
    //   emit(internState.copyWith(connectionRequestStatus: ConnectionRequestStatus.failure));
    // }
    await connectionDataSource.acceptConnection(connection, accepted);
    final connectionIndex = internState.connections.indexOf(connection);
    final updatedConnections = List<Connection>.of(internState.connections);

    updatedConnections.removeAt(connectionIndex);

    if (accepted) {
      updatedConnections.insert(connectionIndex, connection.copyWith(status: ConnectionStatus.accepted));
    }

    emit(internState.copyWith(connections: updatedConnections));
  }

  // CHECKED
  Future<void> requestConnection(int userCode) async {
    final internState = state as UserDataReady;

    try {
      final httpResult = await connectionDataSource.requestConnection(userCode);
      emit(internState.copyWith(
        connectionRequestStatus: ConnectionRequestStatus.success,
        event: ConnectionRequestResult(isSuccess: true, message: httpResult.message ?? 'Requisição de conexão realizada com sucesso!'),
      ));
    } on HttpRequestException catch (e, s) {
      emit(internState.copyWith(
        connectionRequestStatus: ConnectionRequestStatus.failure,
        event: ConnectionRequestResult(isSuccess: false, message: e.message),
      ));
    } on Exception catch(e, s) {
      emit(internState.copyWith(
        connectionRequestStatus: ConnectionRequestStatus.failure,
        event: ConnectionRequestResult(isSuccess: false, message: e.toString()),
      ));
    }
  }

  /// Method used to clear event after one shot event
  void clearEvent() {
    final internState = state as UserDataReady;
    emit(internState.copyWith(
      event: null,
      connectionRequestStatus: ConnectionRequestStatus.initial,
    ));
  }

  // CHECKED
  Future<void> deleteConnection(Connection connection) async {
    final internState = state as UserDataReady;

    try {
      final httpResult = await connectionDataSource.deleteConnection(connection);

      final updatedConnections = List<Connection>.of(internState.connections)
        ..remove(connection);

      emit(internState.copyWith(
        connections: updatedConnections,
        connectionRequestStatus: ConnectionRequestStatus.success,
        event: ConnectionRequestResult(isSuccess: true, message: httpResult.message ?? 'Conexão removida com sucesso!'),
      ));
    } on HttpRequestException catch (e) {
      emit(internState.copyWith(
        connectionRequestStatus: ConnectionRequestStatus.failure,
        event: ConnectionRequestResult(isSuccess: false, message: e.message),
      ));
    } on Exception catch (e) {
      emit(internState.copyWith(
        connectionRequestStatus: ConnectionRequestStatus.failure,
        event: ConnectionRequestResult(isSuccess: false, message: e.toString()),
      ));
    }
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

  // FIXME: catch errors properly
  Future<void> createContract(Contract contract) async {
    final internState = state as UserDataReady;

    final model = contract.toModel();

    final newContract = await contractDataSource.createContract(model);
    final updatedContracts = List<Contract>.of(internState.contracts)..insert(0, newContract);

    emit(internState.copyWith(contracts: updatedContracts));
  }

  // FIXME: catch errors properly
  Future<void> refreshContracts() async {
    final internState = state as UserDataReady;
    final newContracts = await contractDataSource.getContractsForUser();

    emit(internState.copyWith(contracts: newContracts));
  }

  // FIXME: catch errors properly
  Future<void> refreshConnections(User user) async {
    final internState = state as UserDataReady;

    final updatedConnections = await connectionDataSource.getConnectionsForUser();

    emit(internState.copyWith(connections: updatedConnections));
  }
}
