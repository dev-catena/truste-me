import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:trustme/core/providers/user_data_cubit.dart';
import 'package:trustme/features/common/data/data_source/user_data_source.dart';
import 'package:trustme/features/common/domain/entities/location.dart';
import 'package:trustme/features/common/domain/entities/user.dart';
import 'package:trustme/features/register/domain/entities/address_info_data.dart';
import 'package:trustme/features/register/domain/entities/complemenary_info_data.dart';
import 'package:trustme/features/register/domain/entities/user_info_data.dart';
import 'package:trustme/features/register/presentation/widgets/complementary_info_form.dart';

part 'profile_detail_event.dart';
part 'profile_detail_state.dart';

class ProfileDetailBloc extends Bloc<ProfileDetailEvent, ProfileDetailState> {
  final UserDataSource datasource;
  final UserDataCubit userData;

  ProfileDetailBloc(this.datasource, this.userData) : super(ProfileDetailInitial()) {
    on<ProfileDetailStarted>(_onStarted);
    on<PersonalDataChanged>(_onPersonalDataChanged);
    on<AddressDataChanged>(_onAddressDataChanged);
    on<ComplementaryDataChanged>(_onComplementaryDataChanged);
    on<ClearMessage>(_onClearMessage);
    on<ProfileDetailSave>(_onSave);
  }

  Future<void> _onStarted(ProfileDetailStarted event, Emitter<ProfileDetailState> emit) async {
    emit(ProfileDetailLoadInProgress());

    // GET DATA FROM DATASOURCE OR Get it from UserDataCubit
    final userEdition = userData.getUser;
    final personalData = UserInfoData(id: userEdition.id, name: userEdition.fullName, cpf: userEdition.cpf, email: userEdition.email, birthDate: userEdition.birthDate);
    final addressData = AddressInfoData(isEdition: true, loc: Location(id: userEdition.id, cep: userEdition.cep ?? '', state: userEdition.state ?? '', city: userEdition.city ?? '', neighborhood: userEdition.neighborhood ?? '', street: userEdition.address ?? '', number: userEdition.addressNumber ?? '', complement: userEdition.addressComplement ?? ''));
    final complementaryInfoData = ComplementaryInfoData(isEdition: true, userProfession: userEdition.profession, userIncome: IncomeRange.values.firstWhereOrNull( (x) => x.description == userEdition.income ));

    emit(ProfileDetailReady(
      user: userEdition,
      personalData: personalData,
      addressData: addressData,
      complementaryInfoData: complementaryInfoData,
    ));
  }

  void _onPersonalDataChanged(PersonalDataChanged event, Emitter<ProfileDetailState> emit) {
    if (state is ProfileDetailReady) {
      final currentState = state as ProfileDetailReady;
      emit(currentState.copyWith(personalData: event.newData));
    }
  }

  void _onAddressDataChanged(AddressDataChanged event, Emitter<ProfileDetailState> emit) {
    if (state is ProfileDetailReady) {
      final currentState = state as ProfileDetailReady;
      emit(currentState.copyWith(addressData: event.newAddress));
    }
  }

  void _onComplementaryDataChanged(ComplementaryDataChanged event, Emitter<ProfileDetailState> emit) {
    if (state is ProfileDetailReady) {
      final currentState = state as ProfileDetailReady;
      emit(currentState.copyWith(complementaryInfoData: event.newInfo));
    }
  }

  void _onClearMessage(ClearMessage event, Emitter<ProfileDetailState> emit) {
    if (state is ProfileDetailReady) {
      final currentState = state as ProfileDetailReady;
      emit(currentState.copyWith(message: () => null));
    }
  }


  Future<void> _onSave(ProfileDetailSave event, Emitter<ProfileDetailState> emit) async {
    if (state is! ProfileDetailReady) return;
    final currentState = state as ProfileDetailReady;

    if (!currentState.personalData.isValid) {
      emit(currentState.copyWith(message: () => currentState.personalData.getWarningMessage()));
      return;
    }
    if (!currentState.addressData.isValid) {
      emit(currentState.copyWith(message: () => currentState.addressData.getWarningMessage()));
      return;
    }
    if (!currentState.complementaryInfoData.isValid) {
      emit(currentState.copyWith(message: () => currentState.complementaryInfoData.getWarningMessage()));
      return;
    }

    emit(currentState.copyWith(isSaving: true));

    final personalData = currentState.personalData;
    final addressData = currentState.addressData;
    final complementaryInfoData = currentState.complementaryInfoData;
    final String? professionValue = complementaryInfoData.userProfession?.trim().isNotEmpty == true
        ? complementaryInfoData.userProfession!.trim()
        : null;

    final userDataUpdated = {
      'email': personalData.email,
      'CPF': personalData.cpf,
      'nome_completo': personalData.name,
      'pais': 'Brasil',
      ...addressData.loc!.toModel().toJson(), // loc can't be null if isValid
      'profissao': professionValue,
      'dt_nascimento': personalData.birthDate.toString(),
      'renda_classe': complementaryInfoData.userIncome?.description,
    };

    try {
      // TODO: Change it to updateUser2 and call await userData.initialize(updatedUser); properly
      await datasource.updateUser(userDataUpdated);

      // Manuel reconstruction to call initialize() method
      final currentUser = userData.getUser;

      final updatedUser = currentUser.copyWith(
        fullName: personalData.name,
        email: personalData.email,
        cpf: personalData.cpf,
        birthDate: personalData.birthDate,

        cep: addressData.loc!.cep,
        state: addressData.loc!.state,
        city: addressData.loc!.city,
        neighborhood: addressData.loc!.neighborhood,
        address: addressData.loc!.street,
        addressNumber: addressData.loc!.number,
        addressComplement: addressData.loc!.complement,

        profession: professionValue,
        income: complementaryInfoData.userIncome?.description,
      );

      // Refresh user data globally
      //await datasource.loadUser();

      // Update user data properly
      await userData.initialize(updatedUser);

      emit(currentState.copyWith(isSaving: false, message: () => 'Dados atualizados com sucesso!'));
    } on Exception catch (e) {
      emit(currentState.copyWith(isSaving: false, message: () => 'Erro ao salvar: $e'));
    }
  }
}