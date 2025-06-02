part of 'login_cubit.dart';

@immutable
sealed class LoginState {}

final class LoginInitial extends LoginState {}

final class LoginReady extends LoginState {
  final String version;

  final TextEditingController emailController;
  final TextEditingController pwdController;
  final FocusNode emailFocusNode;
  final FocusNode pwdFocusNode;

  final bool isSubmitting;
  final bool loginSuccess;
  final bool isPwdObscure;
  final bool error;
  final String? errorMsg;

  static const _sentinel = Object();

  LoginReady copyWith({
    Object? version = _sentinel,
    Object? emailController = _sentinel,
    Object? pwdController = _sentinel,
    Object? emailFocusNode = _sentinel,
    Object? pwdFocusNode = _sentinel,
    Object? isSubmitting = _sentinel,
    Object? loginSuccess = _sentinel,
    Object? isPwdObscure = _sentinel,
    Object? error = _sentinel,
    Object? errorMsg = _sentinel,
  }) {
    return LoginReady(
      version: identical(version, _sentinel) ? this.version : version as String,
      emailController:
          identical(emailController, _sentinel) ? this.emailController : emailController as TextEditingController,
      pwdController: identical(pwdController, _sentinel) ? this.pwdController : pwdController as TextEditingController,
      emailFocusNode: identical(emailFocusNode, _sentinel) ? this.emailFocusNode : emailFocusNode as FocusNode,
      pwdFocusNode: identical(pwdFocusNode, _sentinel) ? this.pwdFocusNode : pwdFocusNode as FocusNode,
      isSubmitting: identical(isSubmitting, _sentinel) ? this.isSubmitting : isSubmitting as bool,
      loginSuccess: identical(loginSuccess, _sentinel) ? this.loginSuccess : loginSuccess as bool,
      isPwdObscure: identical(isPwdObscure, _sentinel) ? this.isPwdObscure : isPwdObscure as bool,
      error: identical(error, _sentinel) ? this.error : error as bool,
      errorMsg: identical(errorMsg, _sentinel) ? this.errorMsg : errorMsg as String?,
    );
  }

  LoginReady({
    required this.version,
    required this.emailController,
    required this.pwdController,
    required this.emailFocusNode,
    required this.pwdFocusNode,
    required this.isPwdObscure,
    required this.isSubmitting,
    required this.loginSuccess,
    required this.error,
    required this.errorMsg,
  });
}
