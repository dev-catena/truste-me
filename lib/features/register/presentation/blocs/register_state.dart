part of 'register_cubit.dart';

//region ## UI Events
@immutable
sealed class RegisterEvent extends Equatable {
  const RegisterEvent();
  @override
  List<Object?> get props => [];
}

// An event to command the UI to show a feedback message (e.g., in a SnackBar).
final class ShowMessageEvent extends RegisterEvent {
  final String message;
  const ShowMessageEvent(this.message);
  @override
  List<Object?> get props => [message];
}

final class RegistrationSuccessEvent extends RegisterEvent {
  const RegistrationSuccessEvent();
}

final class PopFlowEvent extends RegisterEvent {
  const PopFlowEvent();
}

// This event is used to clear the current event from the state
// after it has been handled by the UI.
final class ClearEvent extends RegisterEvent {
  const ClearEvent();
}
//endregion

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

  final RegisterEvent? event;

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
    this.event,
  });

  RegisterFlow copyWith({
    int? currentStep,
    UserInfoData? personalData,
    bool? emailExists,
    bool? cpfExists,
    ValueGetter<Location?>? userLocation,
    String? userProfession,
    ValueGetter<IncomeRange?>? userIncome,
    String? userPwd,
    String? userPwdConfirmation,
    bool? isSubmitting,
    ValueGetter<RegisterEvent?>? event,
  }) {
    return RegisterFlow(
      pageController: pageController,
      currentStep: currentStep ?? this.currentStep,
      personalData: personalData ?? this.personalData,
      emailExists: emailExists ?? this.emailExists,
      cpfExists: cpfExists ?? this.cpfExists,
      userLocation: userLocation != null ? userLocation() : this.userLocation,
      userProfession: userProfession ?? this.userProfession,
      userIncome: userIncome != null ? userIncome() : this.userIncome,
      userPwd: userPwd ?? this.userPwd,
      userPwdConfirmation: userPwdConfirmation ?? this.userPwdConfirmation,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      event: event != null ? event() : this.event,
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
    isSubmitting,
    event,
  ];
}
