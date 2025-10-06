import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trustme/core/extensions/context_extensions.dart';
import 'package:trustme/features/new_password/new_password_data_source.dart';

part 'new_password_state.dart';

class NewPasswordCubit extends Cubit<NewPasswordState> {
  final BuildContext context;
  final NewPasswordDataSource _dataSource = NewPasswordDataSource();

  // Controllers and FocusNodes managed by Cubit
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _firstPwdController = TextEditingController();
  final _secondPwdController = TextEditingController();

  final _emailFocus = FocusNode();
  final _codeFocus = FocusNode();
  final _firstPwdFocus = FocusNode();
  final _secondPwdFocus = FocusNode();

  NewPasswordCubit(this.context) : super(NewPasswordInitial());

  void init() {
    final initialState = NewPasswordFlow(
      emailController: _emailController,
      codeController: _codeController,
      firstPwdController: _firstPwdController,
      secondPwdController: _secondPwdController,
      emailFocus: _emailFocus,
      codeFocus: _codeFocus,
      firstPwdFocus: _firstPwdFocus,
      secondPwdFocus: _secondPwdFocus,
    );
    emit(initialState);
    _addFocusListeners();
  }

  void _addFocusListeners() {
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus && state is NewPasswordFlow) {
        emit((state as NewPasswordFlow).copyWith(wasEmailTouched: true));
      }
    });
    _codeFocus.addListener(() {
      if (!_codeFocus.hasFocus && state is NewPasswordFlow) {
        emit((state as NewPasswordFlow).copyWith(wasCodeTouched: true));
      }
    });
    _firstPwdFocus.addListener(() {
      if (!_firstPwdFocus.hasFocus && state is NewPasswordFlow) {
        emit((state as NewPasswordFlow).copyWith(wasFirstPwdTouched: true));
      }
    });
    _secondPwdFocus.addListener(() {
      if (!_secondPwdFocus.hasFocus && state is NewPasswordFlow) {
        emit((state as NewPasswordFlow).copyWith(wasSecondPwdTouched: true));
      }
    });
  }

  void onTextFieldChanged() {
    // Just to force a rebuild and revalidate the form
    if (state is NewPasswordFlow) {
      emit((state as NewPasswordFlow).copyWith());
    }
  }

  void onNextButtonPressed() {
    if (state is! NewPasswordFlow) return;
    final s = state as NewPasswordFlow;

    if (s.currentStep == 1) {
      sendEmail();
    } else if (s.currentStep == 2) {
      sendCode();
    } else if (s.currentStep == 3) {
      changePwd();
    }
  }

  Future<void> sendEmail() async {
    if (state is! NewPasswordFlow) return;
    final s = state as NewPasswordFlow;

    if (!s.isEmailValid) return;
    emit(s.copyWith(isLoading: true));

    final isValid = await _dataSource.verifyEmail(s.emailController.text.trim());
    if (context.mounted) {
      if (isValid) {
        context.showSnack('Email validado! Verifique o código recebido!');
        emit(s.copyWith(isLoading: false, currentStep: 2));
      } else {
        context.showSnack('Email inválido');
        emit(s.copyWith(isLoading: false));
      }
    }
  }

  Future<void> sendCode() async {
    if (state is! NewPasswordFlow) return;
    final s = state as NewPasswordFlow;

    if (!s.isCodeValid) return;
    emit(s.copyWith(isLoading: true));

    final intCode = int.parse(s.codeController.text);
    final isValid = await _dataSource.validateCode(intCode);

    if (context.mounted) {
      if (isValid) {
        context.showSnack('Código válido!');
        emit(s.copyWith(isLoading: false, currentStep: 3));
      } else {
        context.showSnack('Código inválido');
        emit(s.copyWith(isLoading: false));
      }
    }
  }

  Future<void> changePwd() async {
    if (state is! NewPasswordFlow) return;
    final s = state as NewPasswordFlow;

    if (!s.isFirstPwdValid || !s.arePasswordsMatching) return;
    emit(s.copyWith(isLoading: true));

    final intCode = int.parse(s.codeController.text);
    final hasChanged = await _dataSource.resetPwd(intCode, s.secondPwdController.text);

    if (context.mounted) {
      if (hasChanged) {
        context.showSnack('Senha alterada com sucesso');
        await Future.delayed(const Duration(seconds: 2));
        if (context.mounted) {
          context.pop();
        }
      } else {
        context.showSnack('Não foi possível alterar a senha');
        emit(s.copyWith(isLoading: false));
      }
    }
  }

  @override
  Future<void> close() {
    _emailController.dispose();
    _codeController.dispose();
    _firstPwdController.dispose();
    _secondPwdController.dispose();
    _emailFocus.dispose();
    _codeFocus.dispose();
    _firstPwdFocus.dispose();
    _secondPwdFocus.dispose();
    return super.close();
  }
}
