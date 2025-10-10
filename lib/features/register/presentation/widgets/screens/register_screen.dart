import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trustme/core/extensions/context_extensions.dart';
import 'package:trustme/core/providers/user_data_cubit.dart';

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
    final userData = context.read<UserDataCubit>();

    return BlocProvider(
      create: (context) => RegisterCubit(userData.userDataSource)..init(),
      child: const RegisterView(), // Changed to a dedicated widget for clarity
    );
  }
}

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterCubit, RegisterState>(
      listener: (context, state) {
        // This part is correct. No changes needed.
        if (state is RegisterFlow && state.event != null) {
          final event = state.event;

          // 1. Handle the event
          if (event is ShowMessageEvent) {
            context.showSnack(event.message);
          } else if (event is RegistrationSuccessEvent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Usuário cadastrado com sucesso!'), backgroundColor: Colors.green),
            );
            Navigator.of(context).pop();
          } else if (event is PopFlowEvent) {
            Navigator.of(context).pop();
          }

          // 2. IMPORTANT: After handling the event, tell the Cubit to clear it.
          // This prevents the listener from firing again on the next rebuild.
          context.read<RegisterCubit>().clearEvent();
        }
      },
      child: BlocBuilder<RegisterCubit, RegisterState>(
        builder: (context, state) {
          if (state is! RegisterFlow) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          // watch() ensures the builder rebuilds when the state changes.
          // read() would only get the cubit once and might miss updates.
          final cubit = context.watch<RegisterCubit>();

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, Object? result) {
              cubit.previousStep();
            },
            child: Scaffold(
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
                            // Call the top-level function here
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
            ),
          );
        },
      ),
    );
  }
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
