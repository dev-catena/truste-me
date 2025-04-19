import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/data_source/login_datasource.dart';

part 'login_event.dart';

part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginDataSource dataSource;
  LoginBloc(this.dataSource) : super(LoginState.initial()) {
    on<EmailChanged>((event, emit) {
      emit(state.copyWith(email: event.email));
    });

    on<PasswordChanged>((event, emit) {
      emit(state.copyWith(password: event.password));
    });

    on<LoginSubmitted>((event, emit) async {
      emit(state.copyWith(isSubmitting: true));

      await Future.delayed(const Duration(seconds: 2));

      final bool isAuthenticated = await dataSource.login(event.cpf, event.password);
      if (isAuthenticated) {
        emit(state.copyWith(isSuccess: true, isFailure: false, isSubmitting: false));
      } else {
        emit(state.copyWith(isFailure: true, isSuccess: false, isSubmitting: false));
      }
    });
  }
}
