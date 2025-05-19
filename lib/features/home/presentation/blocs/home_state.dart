part of 'home_bloc.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoadInProgress extends HomeState {}

final class HomeReady extends HomeState {
  final GeneralUserInfo info;

  HomeReady({required this.info});
}

final class HomeError extends HomeState {
  final String msg;

  HomeError(this.msg);
}
