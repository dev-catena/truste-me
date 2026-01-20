import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:trustme/core/utils/http/custom_http_error.dart';

import 'package:trustme/features/common/data/data_source/app_data_source.dart';
import 'package:trustme/features/common/domain/entities/seal.dart';
import 'package:trustme/features/contracts/domain/entities/contract_type.dart';

part 'app_data_state.dart';

class AppDataCubit extends Cubit<AppDataState> {
  final AppDataSource _appDataSource;

  AppDataCubit(this._appDataSource) : super(AppDataInitial());

  List<ContractType> get getContractTypes {
    final internState = state as AppDataReady;

    return internState.contractTypes;
  }

  List<Seal> get getSeals {
    final internState = state as AppDataReady;

    return internState.seals;
  }

  Future<void> initialize() async {
    emit(AppDataLoading());
    try {
      final List<ContractType> types = [];
      final List<Seal> seals = [];

      await Future.wait([
        _appDataSource.getContractTypes().then((value) => types.addAll(value)),
        _appDataSource.getSeals().then((value) => seals.addAll(value)),
      ]);

      emit(AppDataReady(contractTypes: types, seals: seals));
    } on HttpRequestException catch (e) {
      emit(AppDataError('Erro ao carregar os dados do aplicativo: ${e.message}'));
    } on Exception catch (e) {
      emit(AppDataError('Ocorreu um erro inesperado: ${e.toString()}'));
    }
  }
}
