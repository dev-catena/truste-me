import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trustme/core/utils/custom_colors.dart';
import 'package:trustme/features/register/presentation/blocs/register_cubit.dart';
import 'package:trustme/features/register/presentation/widgets/address_info_form.dart';
import 'package:trustme/features/register/presentation/widgets/age_confirmation.dart';
import 'package:trustme/features/register/presentation/widgets/complementary_info_form.dart';
import 'package:trustme/features/register/presentation/widgets/password_creation.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(context)..init(),
      child: BlocBuilder<RegisterCubit, RegisterState>(
        builder: (context, state) {
          if (state is! RegisterFlow) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          final cubit = context.read<RegisterCubit>();
          return Scaffold(
            backgroundColor: CustomColor.backgroundPrimaryColor,
            body: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('TrustMe', style: Theme.of(context).textTheme.displayMedium),
                  Image.asset('assets/imgs/trustme-logo.png', height: 100),
                  const SizedBox(height: 20),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 475),
                      child: PageView.builder(
                        controller: state.pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.totalSteps,
                        itemBuilder: (context, index) => Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: CustomColor.activeColor),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: SingleChildScrollView(child: _getForm(state, cubit)),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('${state.currentStep + 1}/${state.totalSteps}', style: const TextStyle(color: Colors.black54)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(onPressed: cubit.previousStep, child: const Text('Voltar')),
                      state.isSubmitting
                          ? const CircularProgressIndicator()
                          : FilledButton(
                        onPressed: state.currentStep == state.totalSteps - 1 ? cubit.registerUser : cubit.nextStep,
                        child: Text(state.currentStep == state.totalSteps - 1 ? 'Cadastrar' : 'Próximo'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _getForm(RegisterFlow state, RegisterCubit cubit) {
    final step = state.currentStep;
    if (step == 0) {
      return const AgeConfirmation();
    }
    if (step == 1) {
      return state.personalData.buildForm(
        onPersonalDataSet: cubit.onPersonalDataChanged,
      );
    }
    if (step == 2) {
      return AddressInfoForm(
        userLocation: state.userLocation,
        onLocationChanged: cubit.onLocationChanged,
      );
    }
    if (step == 3) {
      return ComplementaryInfoForm(
        userProfession: state.userProfession,
        userIncome: state.userIncome,
        onProfessionSet: (value) => cubit.onComplementaryInfoChanged(profession: value),
        onIncomeSet: (value) => cubit.onComplementaryInfoChanged(income: value),
      );
    }
    if (step == 4) {
      return PasswordCreation(
        onPasswordSet: (value) => cubit.onPasswordChanged(pwd: value),
        onPasswordConfirmSet: (value) => cubit.onPasswordChanged(confirmation: value),
      );
    }
    return const SizedBox.shrink();
  }
}
