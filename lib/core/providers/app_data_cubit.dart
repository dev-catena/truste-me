import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../features/common/data/data_source/app_data_source.dart';
import '../../features/contracts/domain/entities/contract_type.dart';
import '../../features/contracts/domain/entities/sexual_practice.dart';

part 'app_data_state.dart';

class AppDataCubit extends Cubit<AppDataState> {
  final AppDataSource _appDataSource;

  AppDataCubit(this._appDataSource) : super(AppDataInitial());

  // List<SexualPractice> get getPractices {
  //   final internState = state as AppDataReady;
  //
  //   return internState.sexualPractices;
  // }
  List<ContractType> get getContractTypes {
    final internState = state as AppDataReady;

    return internState.contractTypes;
  }

  Future<void> initialize() async {
    final List<ContractType> types = [];
    await Future.wait([
      _appDataSource.getContractTypes().then((value) => types.addAll(value)),
    ]);

    emit(AppDataReady(contractTypes: types));
  }
}
