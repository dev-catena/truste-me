import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../../../core/providers/app_data_cubit.dart';
import '../../../../core/providers/user_data_cubit.dart';
import '../../../../core/services/app_lifecycle_service.dart';
import '../../../../core/utils/log/log.dart';
import '../../../../core/utils/preferences/app_preferences.dart';
import '../../../../main.dart';
import '../../../common/data/models/user_model.dart';
import '../../../common/domain/entities/user.dart';
import '../../data/data_source/home_datasource.dart';

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
      if(!await AppLifecycleService().isUserLastIterationThresholdValid()) {
        TrustMeApp.logout();
        return;
      }

      // Set User last iteration as NOW
      await AppPreferences().setInt(KeyPrefs.USER_LAST_ITERATION, DateTime.now().millisecondsSinceEpoch);
      //endregion

      //region ## LOAD APP VARIABLES IF NEEDED
      if(appData.state is AppDataInitial) {
        await appData.initialize();
      }
      //endregion

      //region ## LOAD USER DATA / INFO
      late GeneralUserInfo info;
      late UserModel user;

      await Future.wait([
        dataSource.getUserData().then((value) => user = value),
        dataSource.getGeneralInfo().then((value) => info = value),
      ]);

      await userData.initialize(user);
      Log.d('$runtimeType', 'USER DATA: ${userData.getUser.toString()}');
      //endregion
      
      //await Future.delayed(Duration(seconds: 5));

      emit(HomeReady(info: info));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
