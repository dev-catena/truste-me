import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trustme/core/global/global_variables.dart';
import 'package:trustme/core/providers/app_data_cubit.dart';
import 'package:trustme/core/providers/user_data_cubit.dart';
import 'package:trustme/core/routes.dart';
import 'package:trustme/core/utils/custom_colors.dart';
import 'package:trustme/features/login/data/data_source/login_datasource.dart';
import 'package:trustme/features/login/presentation/blocs/login_cubit.dart';
import 'package:trustme/main.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = context.read<UserDataCubit>();
    final appData = context.read<AppDataCubit>();
    final displayMedium = Theme.of(context).textTheme.displayMedium!;

    return Scaffold(
      backgroundColor: CustomColor.backgroundPrimaryColor,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocProvider<LoginCubit>(
          create: (_) => LoginCubit(userData, LoginDataSource(false, userData, appData)),
          child: BlocConsumer<LoginCubit, LoginState>(
            listener: (_, state) {
              if (state is LoginReady) {
                if (state.error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMsg!)));
                } else if (state.loginSuccess) {
                  context.goNamed('home');
                }
              }
            },
            builder: (cubitCtx, state) {
              final loginNew = cubitCtx.read<LoginCubit>();

              if (state is LoginInitial) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is LoginReady) {

                if(DEF_TEST && kDebugMode) {
                  state.emailController.text = '069.091.440-74';
                  //state.emailController.text = '370.175.700-30';
                  state.pwdController.text = '123123';
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      Text('${GlobalVariables.DEF_APP_NAME}${GlobalVariables.DEF_USE_DEV_ENVIRONMENT ? ' - HML' : ''}', style: displayMedium),
                      const SizedBox(height: 16),
                      Image.asset('assets/imgs/trustme-logo.png', height: 100),
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: CustomColor.primaryColor),
                        ),
                        padding: const EdgeInsets.only(left: 40, right: 40, bottom: 20, top: 20),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: state.emailController,
                                focusNode: state.emailFocusNode,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'CPF',
                                  hintText: '123.456.789-00',
                                  prefixIcon: Icon(Icons.person_outlined),
                                ),
                                maxLength: 14,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  CpfInputFormatter(),
                                ],
                                keyboardType: TextInputType.number,
                                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: state.pwdController,
                                focusNode: state.pwdFocusNode,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  labelText: 'Senha',
                                  suffixIcon: IconButton(
                                    onPressed: () => loginNew.obscurePassword(),
                                    icon: Icon(
                                        state.isPwdObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                                  ),
                                ),
                                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                                onEditingComplete: () => FocusScope.of(context).unfocus(),
                                onSubmitted: (_) {
                                  loginNew.loginSubmitted();
                                },
                                obscureText: state.isPwdObscure,
                              ),
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: TextButton(
                                  onPressed: () => context.pushNamed(AppRoutes.newPasswordScreen),
                                  child: const Text('Esqueci minha senha'),
                                ),
                              ),
                              const SizedBox(height: 16),
                              state.isSubmitting
                                  ? const CircularProgressIndicator()
                                  : FilledButton(
                                      onPressed: () {
                                        loginNew.loginSubmitted();
                                      },
                                      child: const Text('Login'),
                                    ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text('ver. ${state.version}'),
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton(
                          onPressed: () => context.push(AppRoutes.registerScreen),
                          child: const Text('Criar conta'),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(child: Text('No state'));
              }
            },
          ),
        ),
      ),
    );
  }
}
