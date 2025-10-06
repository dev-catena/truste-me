part of 'new_password_cubit.dart';

@immutable
sealed class NewPasswordState extends Equatable {
  const NewPasswordState();
  @override
  List<Object?> get props => [];
}

final class NewPasswordInitial extends NewPasswordState {}

final class NewPasswordFlow extends NewPasswordState {
  //Flow control
  final int currentStep;

  // Controllers and FocusNodes
  final TextEditingController emailController;
  final TextEditingController codeController;
  final TextEditingController firstPwdController;
  final TextEditingController secondPwdController;

  final FocusNode emailFocus;
  final FocusNode codeFocus;
  final FocusNode firstPwdFocus;
  final FocusNode secondPwdFocus;

  // UI Control
  final bool isLoading;

  // Touch validation
  final bool wasEmailTouched;
  final bool wasCodeTouched;
  final bool wasFirstPwdTouched;
  final bool wasSecondPwdTouched;

  // Computed properties for validation (logic remains in the state)
  bool get isEmailValid => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text.trim());
  bool get isCodeValid => codeController.text.length == 6;
  bool get isFirstPwdValid => firstPwdController.text.length >= 8;
  bool get arePasswordsMatching => firstPwdController.text == secondPwdController.text;

  const NewPasswordFlow({
    this.currentStep = 1,
    required this.emailController,
    required this.codeController,
    required this.firstPwdController,
    required this.secondPwdController,
    required this.emailFocus,
    required this.codeFocus,
    required this.firstPwdFocus,
    required this.secondPwdFocus,
    this.isLoading = false,
    this.wasEmailTouched = false,
    this.wasCodeTouched = false,
    this.wasFirstPwdTouched = false,
    this.wasSecondPwdTouched = false,
  });

  NewPasswordFlow copyWith({
    int? currentStep,
    bool? isLoading,
    bool? wasEmailTouched,
    bool? wasCodeTouched,
    bool? wasFirstPwdTouched,
    bool? wasSecondPwdTouched,
  }) {
    return NewPasswordFlow(
      currentStep: currentStep ?? this.currentStep,
      emailController: emailController,
      codeController: codeController,
      firstPwdController: firstPwdController,
      secondPwdController: secondPwdController,
      emailFocus: emailFocus,
      codeFocus: codeFocus,
      firstPwdFocus: firstPwdFocus,
      secondPwdFocus: secondPwdFocus,
      isLoading: isLoading ?? this.isLoading,
      wasEmailTouched: wasEmailTouched ?? this.wasEmailTouched,
      wasCodeTouched: wasCodeTouched ?? this.wasCodeTouched,
      wasFirstPwdTouched: wasFirstPwdTouched ?? this.wasFirstPwdTouched,
      wasSecondPwdTouched: wasSecondPwdTouched ?? this.wasSecondPwdTouched,
    );
  }

  @override
  List<Object?> get props => [
    currentStep,
    isLoading,
    wasEmailTouched,
    wasCodeTouched,
    wasFirstPwdTouched,
    wasSecondPwdTouched,
  ];
}
