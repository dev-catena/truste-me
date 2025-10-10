import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:trustme/core/utils/http/custom_http_error.dart';
import 'package:trustme/features/common/data/data_source/user_data_source.dart';
import 'package:trustme/features/common/domain/entities/location.dart';
import 'package:trustme/features/register/domain/entities/user_info_data.dart';
import 'package:trustme/features/register/presentation/widgets/complementary_info_form.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final UserDataSource datasource;
  final _pageController = PageController();

  RegisterCubit(this.datasource) : super(RegisterInitial());

  void init() => emit(RegisterFlow(pageController: _pageController));

  //region ## Update data methods
  void onPersonalDataChanged(UserInfoData data, bool email, bool cpf) {
    if (state is RegisterFlow) {
      emit((state as RegisterFlow).copyWith(personalData: data, emailExists: email, cpfExists: cpf));
    }
  }

  void onLocationChanged(Location? location) {
    if (state is RegisterFlow) {
      emit((state as RegisterFlow).copyWith(userLocation: () => location));
    }
  }

  void onComplementaryInfoChanged({String? profession, IncomeRange? income}) {
    if (state is RegisterFlow) {
      emit((state as RegisterFlow).copyWith(userProfession: profession, userIncome: () => income));
    }
  }

  void onPasswordChanged({String? pwd, String? confirmation}) {
    if (state is RegisterFlow) {
      emit((state as RegisterFlow).copyWith(userPwd: pwd, userPwdConfirmation: confirmation));
    }
  }

  // This method is called by the UI to clear the event after handling it.
  void clearEvent() {
    if (state is RegisterFlow) {
      final s = state as RegisterFlow;
      // Emit a copy of the current state, but with the event set to null.
      emit(s.copyWith(event: () => null));
    }
  }
  //endregion

  //region ## Navigation and validation
  void nextStep() {
    if (state is! RegisterFlow) return;
    final s = state as RegisterFlow;

    if (_validateInfo(s)) {
      if (s.currentStep < s.totalSteps - 1) {
        s.pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        emit(s.copyWith(currentStep: s.currentStep + 1, event: () => null));
      }
    }
  }

  void previousStep() {
    if (state is! RegisterFlow) return;
    final s = state as RegisterFlow;

    if (s.currentStep == 0) {
      emit(s.copyWith(event: () => const PopFlowEvent()));
    } else {
      s.pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      emit(s.copyWith(currentStep: s.currentStep - 1, event: () => null));
    }
  }

  // Private validation logic. Emits a ShowMessageEvent on failure.
  bool _validateInfo(RegisterFlow s) {
    bool canProceed;
    switch (s.currentStep) {
      case 0: // Age confirmation
        canProceed = true;
        break;
      case 1: // Personal data
        canProceed = s.personalData.isValid && !s.emailExists && !s.cpfExists;
        if (!canProceed) {
          emit(s.copyWith(event: () => ShowMessageEvent(
            s.emailExists
              ? 'Já existe um login com este email!'
              : s.cpfExists
              ? 'Já existe um cadastro com este CPF!'
              : s.personalData.getWarningMessage(),))
          );
        }
        break;
      case 2: // Address
        canProceed = s.userLocation != null && (s.userLocation?.number.isNotEmpty ?? false);
        if (!canProceed) {
          emit(s.copyWith(event: () => ShowMessageEvent(s.userLocation == null ? 'Preencha o CEP corretamente' : 'Preencha o número da residência')));
        }
        break;
      case 3: // Complementary info
        canProceed = s.userIncome != null && s.userProfession.isNotEmpty;
        if (!canProceed) {
          emit(s.copyWith(event: () => ShowMessageEvent('Preencha o campo profissão e renda')));
        }
        break;
      case 4: // Password
        canProceed = s.userPwd.isNotEmpty && s.userPwd == s.userPwdConfirmation;
        if (!canProceed) {
          emit(s.copyWith(event: () => ShowMessageEvent(s.userPwd.isEmpty ? 'A senha não pode ser vazia' : 'As senhas não coincidem!')));
        }
        break;
      default:
        canProceed = false;
    }
    return canProceed;
  }
  //endregion

  //region ## SUBMISSION
  Future<void> registerUser() async {
    if (state is! RegisterFlow) return;
    final s = state as RegisterFlow;

    if (!_validateInfo(s)) return; // Revalidate - Current step

    if (!s.personalData.isValid) {
      emit(s.copyWith(event: () => ShowMessageEvent(s.personalData.getWarningMessage())));
      return;
    }

    emit(s.copyWith(isSubmitting: true));

    final content = {
      'email': s.personalData.email,
      'CPF': s.personalData.cpf,
      'nome_completo': s.personalData.name,
      'pais': 'Brasil',
      ...?s.userLocation?.toModel().toJson(),
      'profissao': s.userProfession.trim().isNotEmpty ? s.userProfession.trim() : null,
      'dt_nascimento': s.personalData.birthDate.toString(),
      'renda_classe': s.userIncome?.description,
      'password': s.userPwd,
      'password_confirmation': s.userPwdConfirmation,
    };

    try {
      //final resp = await ApiProvider().post('usuario/gravar', jsonEncode(content), useToken: false);
      final resp = await datasource.createUser(content);
      if (resp != null) {
        emit(s.copyWith(event: () => RegistrationSuccessEvent()));
        //emit(s.copyWith(event: () => ShowMessageEvent('Usuário cadastrado com sucesso!')));
        //emit(s.copyWith(event: () => PopFlowEvent()));
      } else {
        emit(s.copyWith(event: () => ShowMessageEvent('Erro!\n$resp')));
        }
    } on HttpRequestException catch (e) {
      emit(s.copyWith(event: () => ShowMessageEvent(e.message)));
    } on Exception catch(e) {
      emit(s.copyWith(event: () => ShowMessageEvent(e.toString())));
    } finally {
      emit(s.copyWith(isSubmitting: false));
    }
  }
  //endregion

  @override
  Future<void> close() {
    _pageController.dispose();
    return super.close();
  }
}
