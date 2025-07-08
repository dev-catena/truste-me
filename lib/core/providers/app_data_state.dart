part of 'app_data_cubit.dart';

@immutable
sealed class AppDataState {}

final class AppDataInitial extends AppDataState {}

final class AppDataReady extends AppDataState {
  final List<ContractType> contractTypes;
  final List<Seal> seals;

  AppDataReady({
    required this.contractTypes,
    required this.seals,
  });
}
