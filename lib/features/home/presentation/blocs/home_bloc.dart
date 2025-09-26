import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../../../core/providers/user_data_cubit.dart';
import '../../../common/data/models/user_model.dart';
import '../../../common/domain/entities/user.dart';
import '../../data/data_source/home_datasource.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeDataSource dataSource;
  final UserDataCubit userData;

  HomeBloc(this.dataSource, this.userData) : super(HomeInitial()) {
    on<HomeStarted>(_onStarted);

    // Start it on load (bloc created)
    add(HomeStarted());
  }

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(HomeLoadInProgress());
    try {
      late GeneralUserInfo info;
      late UserModel user;

      await Future.wait([
        dataSource.getUserData().then((value) => user = value),
        dataSource.getGeneralInfo().then((value) => info = value),
      ]);

      // TODO: Update user data properly to avoid initialize it again
      user.authToken = userData.getUser.authToken;
      await userData.initialize(user);

      debugPrint('USER DATA: ${userData.getUser.toString()}');
      
      //await Future.delayed(Duration(seconds: 5));

      emit(HomeReady(info: info));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
