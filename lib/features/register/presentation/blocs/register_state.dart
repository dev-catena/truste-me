
part of 'register_cubit.dart';

@immutable
sealed class RegisterState extends Equatable {
  const RegisterState();
  @override
  List<Object?> get props => [];
}

final class RegisterInitial extends RegisterState {}

final class RegisterFlow extends RegisterState {
  final int currentStep;
  final int totalSteps;
  final PageController pageController;

  final UserInfoData personalData;
  final bool emailExists;
  final bool cpfExists;
  final Location? userLocation;
  final String userProfession;
  final IncomeRange? userIncome;
  final String userPwd;
  final String userPwdConfirmation;

  final bool isSubmitting;

  const RegisterFlow({
    required this.pageController,
    this.currentStep = 0,
    this.totalSteps = 5,
    this.personalData = const UserInfoData.empty(),
    this.emailExists = false,
    this.cpfExists = false,
    this.userLocation,
    this.userProfession = '',
    this.userIncome,
    this.userPwd = '',
    this.userPwdConfirmation = '',
    this.isSubmitting = false,
  });

  RegisterFlow copyWith({
    int? currentStep,
    UserInfoData? personalData,
    bool? emailExists,
    bool? cpfExists,
    Location? userLocation,
    String? userProfession,
    IncomeRange? userIncome,
    String? userPwd,
    String? userPwdConfirmation,
    bool? isSubmitting,
  }) {
    return RegisterFlow(
      pageController: pageController,
      currentStep: currentStep ?? this.currentStep,
      personalData: personalData ?? this.personalData,
      emailExists: emailExists ?? this.emailExists,
      cpfExists: cpfExists ?? this.cpfExists,
      userLocation: userLocation ?? this.userLocation,
      userProfession: userProfession ?? this.userProfession,
      userIncome: userIncome ?? this.userIncome,
      userPwd: userPwd ?? this.userPwd,
      userPwdConfirmation: userPwdConfirmation ?? this.userPwdConfirmation,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
    currentStep,
    totalSteps,
    pageController,
    personalData,
    emailExists,
    cpfExists,
    userLocation,
    userProfession,
    userIncome,
    userPwd,
    userPwdConfirmation,
    isSubmitting
  ];
}
