import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../data/data_source/home_datasource.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeDataSource dataSource;

  HomeBloc(this.dataSource) : super(HomeInitial()) {
    on<HomeStarted>(_onStarted);
  }

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(HomeLoadInProgress());
    try {
      late GeneralUserInfo info;

      await Future.wait([
        dataSource.getGeneralInfo().then((value) => info = value),
      ]);

      emit(HomeReady(info: info));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
