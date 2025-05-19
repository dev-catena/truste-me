part of 'login_bloc.dart';

@immutable
class LoginState extends Equatable {
  final String email;
  final String password;
  final bool isSubmitting;
  final bool isPwdObscured;
  final bool isSuccess;
  final bool isFailure;
  final String? errorMsg;

  const LoginState({
    required this.email,
    required this.password,
    required this.isSubmitting,
    required this.isPwdObscured,
    required this.isSuccess,
    required this.isFailure,
    this.errorMsg,
  });

  factory LoginState.initial() {
    return const LoginState(
      email: '',
      password: '',
      isPwdObscured: true,
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
      errorMsg: '',
    );
  }

  LoginState copyWith({
    String? email,
    String? password,
    bool? isSubmitting,
    bool? isPwdObscure,
    bool? isSuccess,
    bool? isFailure,
    String? errorMsg,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isPwdObscured: isPwdObscure ?? this.isPwdObscured,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
      errorMsg: errorMsg,
    );
  }

  @override
  List<Object?> get props => [email, password, isSubmitting, isPwdObscured, isSuccess, isFailure];
}
