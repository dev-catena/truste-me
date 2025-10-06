
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trustme/core/utils/custom_colors.dart';
import 'package:trustme/features/new_password/presentation/blocs/new_password_cubit.dart';

class NewPasswordScreen extends StatelessWidget {
  const NewPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NewPasswordCubit(context)..init(),
      child: BlocBuilder<NewPasswordCubit, NewPasswordState>(
        builder: (context, state) {
          if (state is! NewPasswordFlow) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return _buildUI(context, state);
        },
      ),
    );
  }

  Widget _buildUI(BuildContext context, NewPasswordFlow state) {
    final titleLarge = Theme.of(context).textTheme.titleLarge;
    final displayMedium = Theme.of(context).textTheme.displayMedium!;
    final cubit = context.read<NewPasswordCubit>();

    return Scaffold(
      backgroundColor: CustomColor.backgroundPrimaryColor,
      appBar: AppBar(
        title: const Text('TrustMe', style: TextStyle(color: Colors.white)),
        backgroundColor: CustomColor.activeColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Text('TrustMe', style: displayMedium),
            const SizedBox(height: 10),
            Image.asset('assets/imgs/trustme-logo.png', height: 100),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: CustomColor.activeColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20, top: 20, left: 10, right: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Redefinição de senha', style: titleLarge),
                      const SizedBox(height: 20),
                      Text(_getTextForStep(state.currentStep), textAlign: TextAlign.center),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: _getFormFieldForStep(context, state),
                      ),
                      const SizedBox(height: 20),
                      if (state.isLoading)
                        const CircularProgressIndicator()
                      else
                        FilledButton(
                          onPressed: cubit.onNextButtonPressed,
                          child: const Text('Enviar'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTextForStep(int step) {
    if (step == 1) {
      return 'Digite o email cadastrado.';
    } else if (step == 2) {
      return 'Digite o código recebido no email.\nO código tem validade de 10 minutos.';
    } else if (step == 3) {
      return 'Digite a nova senha.\nA senha deve contar pelo menos 8 caracteres.';
    }
    return '';
  }

  InputDecoration _getDecoration({String? label, required bool isValid}) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderSide: BorderSide(color: isValid ? Colors.black26 : Colors.red)),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: isValid ? Colors.black26 : Colors.red)),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: isValid ? CustomColor.activeColor : Colors.red, width: 2)),
    );
  }

  Widget _getFormFieldForStep(BuildContext context, NewPasswordFlow state) {
    final cubit = context.read<NewPasswordCubit>();
    if (state.currentStep == 1) {
      return TextField(
        controller: state.emailController,
        focusNode: state.emailFocus,
        onChanged: (_) => cubit.onTextFieldChanged(),
        decoration: _getDecoration(
          label: 'Email',
          isValid: !state.wasEmailTouched || state.isEmailValid,
        ),
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.emailAddress,
        onTapOutside: (_) => state.emailFocus.unfocus(),
        onSubmitted: (_) => cubit.sendEmail(),
      );
    } else if (state.currentStep == 2) {
      return TextField(
        controller: state.codeController,
        focusNode: state.codeFocus,
        onChanged: (_) => cubit.onTextFieldChanged(),
        decoration: _getDecoration(
          label: 'Código',
          isValid: !state.wasCodeTouched || state.isCodeValid,
        ),
        maxLength: 6,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textInputAction: TextInputAction.done,
        onTapOutside: (_) => state.codeFocus.unfocus(),
        onSubmitted: (_) => cubit.sendCode(),
      );
    } else if (state.currentStep == 3) {
      return Column(
        children: [
          TextField(
            controller: state.firstPwdController,
            focusNode: state.firstPwdFocus,
            onChanged: (_) => cubit.onTextFieldChanged(),
            decoration: _getDecoration(
              label: 'Senha',
              isValid: !state.wasFirstPwdTouched || state.isFirstPwdValid,
            ),
            obscureText: true,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: state.secondPwdController,
            focusNode: state.secondPwdFocus,
            onChanged: (_) => cubit.onTextFieldChanged(),
            decoration: _getDecoration(
              label: 'Repita a senha',
              isValid: !state.wasSecondPwdTouched || state.arePasswordsMatching,
            ),
            obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => cubit.changePwd(),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
