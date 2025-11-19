import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:trustme/core/providers/user_data_event.dart';
import 'package:trustme/core/utils/firebase/crashlytics_util.dart';
import 'package:trustme/core/utils/http/custom_http_error.dart';
import 'package:trustme/core/utils/preferences/app_preferences.dart';
import 'package:trustme/features/home/data/data_source/home_datasource.dart';

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

  UserDataCubit(
    this.userDataSource,
    this.contractDataSource,
    this.connectionDataSource,
  ) : super(UserDataInitial());

  User get getUser => (state as UserDataReady).user;

  List<Contract> get getContracts => (state as UserDataReady).contracts;

  List<Connection> get getConnections => (state as UserDataReady).connections;

  // CHECKED
  Future<void> initialize(User user) async {
    emit(UserDataLoading());
    try {
      final List<Contract> contracts = [];
      final List<Connection> connections = [];
      final List<Seal> seals = [];
      late final GeneralUserInfo userInfo;

      setLoggedInUser(user);

      await Future.wait([
        userDataSource.getGeneralInfo().then((value) => userInfo = value),
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
        userInfo: userInfo,
        contracts: contracts,
        connections: connections,
      ));
    } on HttpRequestException catch (e) {
      emit(UserDataError('Erro ao carregar os dados do usuário: ${e.message}'));
    } on Exception catch (e) {
      emit(UserDataError('Ocorreu um erro inesperado ao carregar os dados: ${e.toString()}'));
    }
  }

  // CHECKED
  Future<void> refreshUserInfo() async {
    final internState = state as UserDataReady;
    try {
      final info = await userDataSource.getGeneralInfo();
      emit(internState.copyWith(
        userInfo: info,
        event: RefreshResult(isSuccess: true, message: 'Informações atualizadas com sucesso!'),
      ));
    } on HttpRequestException catch (e) {
      emit(internState.copyWith(
        event: RefreshResult(isSuccess: false, message: e.message),
      ));
    } on Exception catch (e) {
      emit(internState.copyWith(
        event: RefreshResult(isSuccess: false, message: e.toString()),
      ));
    }
  }

  // CHECKED
  Future<void> establishConnection(final Connection connection, final bool accepted) async {
    final internState = state as UserDataReady;
    try {
      final httpResult = await connectionDataSource.acceptConnection(connection, accepted);

      final updatedConnections = List<Connection>.of(internState.connections);
      final connectionIndex = updatedConnections.indexOf(connection);

      if (connectionIndex != -1) {
        updatedConnections.removeAt(connectionIndex);
        if (accepted) {
          updatedConnections.insert(connectionIndex, connection.copyWith(status: ConnectionStatus.accepted));
        }
      }

      final message = accepted ? 'Conexão aceita com sucesso!' : 'Conexão recusada com sucesso!';

      emit(internState.copyWith(
        connections: updatedConnections,
        connectionRequestStatus: ConnectionRequestStatus.success,
        event: ConnectionRequestResult(isSuccess: true, message: httpResult.message ?? message),
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

  // CHECKED
  Future<void> createContract(Contract contract) async {
    final internState = state as UserDataReady;
    try {
      final model = contract.toModel();
      final newContract = await contractDataSource.createContract(model);
      final updatedContracts = List<Contract>.of(internState.contracts)
        ..insert(0, newContract);
      final updatedInfo = internState.userInfo.copyWith(pendingContracts: internState.userInfo.pendingContracts + 1);

      emit(
        internState.copyWith(
          contracts: updatedContracts,
          userInfo: updatedInfo,
          event: ContractCreationResult(isSuccess: true, message: 'Contrato criado com sucesso!', contract: newContract,),
        ),
      );
    } on HttpRequestException catch (e) {
      emit(
        internState.copyWith(
          event: ContractCreationResult(isSuccess: false, message: e.message,),
        ),
      );
    } on Exception catch (e) {
      emit(
        internState.copyWith(
          event: ContractCreationResult(isSuccess: false, message: e.toString(),),
        ),
      );
    }
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
