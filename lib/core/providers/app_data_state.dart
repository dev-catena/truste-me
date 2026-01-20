part of 'app_data_cubit.dart';

@immutable
sealed class AppDataState {}

final class AppDataInitial extends AppDataState {}

final class AppDataLoading extends AppDataState {}

final class AppDataError extends AppDataState {
  final String message;

  AppDataError(this.message);
}

final class AppDataReady extends AppDataState {
  final List<ContractType> contractTypes;
  final List<Seal> seals;

  AppDataReady({
    required this.contractTypes,
    required this.seals,
  });
}
