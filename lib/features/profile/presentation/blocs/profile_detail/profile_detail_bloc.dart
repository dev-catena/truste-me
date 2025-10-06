import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import 'package:trustme/core/providers/user_data_cubit.dart';
import 'package:trustme/features/common/data/data_source/user_data_source.dart';
import 'package:trustme/features/common/domain/entities/user.dart';

part 'profile_detail_event.dart';
part 'profile_detail_state.dart';

class ProfileDetailBloc extends Bloc<ProfileDetailEvent, ProfileDetailState> {
  final UserDataSource datasource;
  final UserDataCubit userData;

  ProfileDetailBloc(this.datasource, this.userData) : super(ProfileDetailInitial()) {
    on<ProfileDetailStarted>(_onStarted);
    on<ProfileDetailSave>(_onSave);
  }

  Future<void> _onStarted(ProfileDetailStarted event, Emitter<ProfileDetailState> emit) async {
    emit(ProfileDetailLoadInProgress());

    // GET DATA FROM DATASOURCE OR Get it from UserDataCubit

    emit(ProfileDetailReady(
      user: userData.getUser
    ));

  }

  Future<void> _onSave(ProfileDetailSave event, Emitter<ProfileDetailState> emit) async {
    if (state is! ProfileDetailReady) return;
    final internState = state as ProfileDetailReady;

    final result = await datasource.updateUser(event.user);

    if(result.isNotEmpty) {
      emit(internState.copyWith(message: "Dados atualizados com sucesso!"));
      //emit(internState.copyWith(message: result['msg']));

      final updatedUser = userData.getUser.copyWith(
          email: event.user['email'],
          cpf: event.user['CPF'],
          fullName: event.user['nome_completo'],
          country: event.user['pais'],
          cep: event.user['cep'],
          city: event.user['cidade'],
          state: event.user['estado'],
          neighborhood: event.user['bairro'],
          address: event.user['endereco'],
          addressNumber: event.user['endereco_numero'],
          addressComplement: event.user['complemento'],
          profession: event.user['profissao'],
          birthDate: DateTime.tryParse(event.user['dt_nascimento'] ?? ''),
          income: event.user['renda_classe']
      );

      // Update user data properly
      await userData.initialize(updatedUser);
      internState.copyWith(user: updatedUser, message: "Dados atualizados com sucesso!");
    }

    //final userUpdated = UserModel.fromJson(event.user).toEntity();

    //emit(internState.copyWith(user: userUpdated, message: "Dados atualizados com sucesso!"));


    // emit(ProfileDetailReady(
    //     user: userUpdated,
    //     message: "Dados atualizados com sucesso!"
    // ));
  }

}