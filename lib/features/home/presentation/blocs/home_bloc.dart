import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'package:trustme/core/providers/app_data_cubit.dart';
import 'package:trustme/core/providers/user_data_cubit.dart';
import 'package:trustme/core/services/app_lifecycle_service.dart';
import 'package:trustme/core/utils/http/custom_http_error.dart';
import 'package:trustme/core/utils/log/log.dart';
import 'package:trustme/core/utils/preferences/app_preferences.dart';
import 'package:trustme/main.dart';
import 'package:trustme/features/common/data/models/user_model.dart';
import 'package:trustme/features/home/data/data_source/home_datasource.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeDataSource dataSource;
  final UserDataCubit userData;
  final AppDataCubit appData;

  HomeBloc(this.dataSource, this.userData, this.appData) : super(HomeInitial()) {
    on<HomeStarted>(_onStarted);

    // Start it on load (bloc created)
    add(HomeStarted());
  }

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(HomeLoadInProgress());
    try {
      //region ## CHECK if this session is VALID
      if (!await AppLifecycleService().isUserLastIterationThresholdValid()) {
        TrustMeApp.logout();
        return;
      }
      // Set User last iteration as NOW
      await AppPreferences().setInt(KeyPrefs.USER_LAST_ITERATION, DateTime.now().millisecondsSinceEpoch);
      //endregion

      //region ## LOAD APP VARIABLES IF NEEDED
      if (appData.state is! AppDataReady) {
        await appData.initialize();
        // After awaiting, check if the initialization failed.
        if (appData.state is AppDataError) {
          final errorState = appData.state as AppDataError;
          emit(HomeError(errorState.message));
          return; // Stop execution.
        }
      }
      //endregion

      //region ## LOAD USER DATA / INFO
      late final GeneralUserInfo info;
      late final UserModel user;

      // Fetch user data and general info concurrently for optimization
      await Future.wait([
        dataSource.getUserData().then((value) => user = value),
        dataSource.getGeneralInfo().then((value) => info = value),
      ]);

      // Initialize UserDataCubit, passing the already fetched info to avoid a second network call.
      await userData.initialize(user, userInfo: info);
      if (userData.state is UserDataError) {
        final errorState = userData.state as UserDataError;
        emit(HomeError(errorState.message));
        return; // Stop execution.
      }
      
      Log.d('$runtimeType', 'USER DATA: ${userData.getUser.toString()}');
      //endregion

      emit(HomeReady(info: info));
    } on HttpRequestException catch (e) {
      emit(HomeError('Falha ao carregar dados: ${e.message}'));
    } catch (e) {
      emit(HomeError('Ocorreu um erro inesperado: ${e.toString()}'));
    }
  }
}
