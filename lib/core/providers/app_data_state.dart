part of 'app_data_cubit.dart';

@immutable
sealed class AppDataState {}

final class AppDataInitial extends AppDataState {}

final class AppDataReady extends AppDataState {
  final List<SexualPractice> sexualPractices;

  AppDataReady({required this.sexualPractices});
}
