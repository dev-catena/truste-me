import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../../../core/providers/user_data_cubit.dart';
import '../../../../core/utils/exception_handler.dart';
import '../../data/data_source/login_datasource.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginDataSource dataSource;
  final UserDataCubit userData;

  LoginCubit(this.userData, this.dataSource) : super(LoginInitial()) {
    initialize();
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _pwdFocusNode = FocusNode();

  void initialize() {
    emit(
      LoginReady(
        emailController: _emailController,
        pwdController: _pwdController,
        emailFocusNode: _emailFocusNode,
        pwdFocusNode: _pwdFocusNode,
        isPwdObscure: true,
        isSubmitting: false,
        loginSuccess: false,
        error: false,
        errorMsg: null,
      ),
    );
  }

  void obscurePassword() {
    final internalState = state as LoginReady;

    emit(internalState.copyWith(isPwdObscure: !internalState.isPwdObscure, error: false, errorMsg: null));
  }

  Future<void> loginSubmitted() async {
    final internalState = state as LoginReady;

    if (internalState.emailController.text.trim() == '' || internalState.pwdController.text.trim() == '') {
      emit(internalState.copyWith(error: true, errorMsg: 'Preencha os campos de usuário e senha!'));
      return;
    } else {
      emit(internalState.copyWith(isSubmitting: true, error: false, errorMsg: null));

      try {
        final bool isAuthenticated =
            await dataSource.login(internalState.emailController.text, internalState.pwdController.text);
        if (isAuthenticated) {
          emit(internalState.copyWith(
            loginSuccess: true,
            isSubmitting: false,
            error: false,
            errorMsg: null,
          ));
        } else {
          emit(internalState.copyWith(
            loginSuccess: false,
            isSubmitting: false,
            error: true,
            errorMsg: 'Usuário ou senha incorretos',
          ));
        }
      } catch (e, s) {
        final String msg = ExceptionHandler(e, s).getMessage();
        emit(internalState.copyWith(loginSuccess: false, isSubmitting: false, error: true, errorMsg: msg));
      }
    }
  }

  @override
  Future<void> close() {
    _emailController.dispose();
    _pwdController.dispose();
    _emailFocusNode.dispose();
    _pwdFocusNode.dispose();
    return super.close();
  }
}
