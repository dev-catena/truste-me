import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';

import '../../../../core/providers/user_data_cubit.dart';
import '../../../../core/utils/exception_handler.dart';
import '../../data/data_source/login_datasource.dart';

part 'login_event.dart';

part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginDataSource dataSource;
  final UserDataCubit userData;

  LoginBloc(this.dataSource, this.userData) : super(LoginState.initial()) {
    on<EmailChanged>((event, emit) {
      emit(state.copyWith(email: event.email));
    });

    on<PasswordChanged>((event, emit) {
      emit(state.copyWith(password: event.password));
    });

    on<LoginSubmitted>((event, emit) async {
      emit(state.copyWith(isSubmitting: true));

      try {
        final bool isAuthenticated = await dataSource.login(event.cpf, event.password);
        if (isAuthenticated) {
          emit(state.copyWith(isSuccess: true, isFailure: false, isSubmitting: false));
        } else {
          emit(state.copyWith(
              isFailure: true, isSuccess: false, isSubmitting: false, errorMsg: 'Usuário ou senha incorretos'));
        }
      } catch (e, s) {
        final String msg = ExceptionHandler(e, s).getMessage();
        emit(state.copyWith(isSuccess: false, isSubmitting: false, isFailure: true, errorMsg: msg));
      }
    });

    on<LoginPwdObscured>((event, emit) {
      emit(state.copyWith(isPwdObscure: !state.isPwdObscured));
    });
  }
}
