import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/user_data_cubit.dart';
import '../../../../core/routes.dart';
import '../../../../core/utils/custom_colors.dart';
import '../../data/data_source/login_datasource.dart';
import '../blocs/login_bloc.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final displayMedium = Theme.of(context).textTheme.displayMedium!;
    final userData = context.read<UserDataCubit>();

    return BlocProvider(
      create: (_) => LoginBloc(LoginDataSource(false, userData), userData),
      child: Scaffold(
        backgroundColor: CustomColor.backgroundPrimaryColor,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocConsumer<LoginBloc, LoginState>(
            listener: (_, state) {
              if (state.isSuccess) {
                context.goNamed('home');
              } else if (state.isFailure){
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMsg!)));
              }
            },
            builder: (blocCtx, state) {
              final bloc = blocCtx.read<LoginBloc>();

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 80),
                    Text('TrustMe', style: displayMedium),
                    const SizedBox(height: 10),
                    Image.asset('assets/imgs/trustme-logo.png', height: 100),
                    const SizedBox(height: 20),
                    LoginCard(
                      bloc,
                      state,
                      emailController: emailController,
                      pwdController: passwordController,
                    ),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.registerScreen),
                      child: const Text('Criar conta'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class LoginCard extends StatelessWidget {
  const LoginCard(
    this.bloc,
    this.state, {
    super.key,
    required this.emailController,
    required this.pwdController,
  });

  final LoginBloc bloc;
  final LoginState state;
  final TextEditingController emailController;
  final TextEditingController pwdController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CustomColor.activeColor),
      ),
      padding: const EdgeInsets.only(left: 40, right: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          getTextField(
            obscure: false,
            labelText: 'CPF',
            hintText: '123.456.789-00',
            leadingIcon: Icons.person_outlined,
            controller: emailController,
            maxLength: 14,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CpfInputFormatter(),
            ],

            // onChanged: (value) => context.read<LoginBloc>().add(PasswordChanged(value)),
          ),
          const SizedBox(height: 20),
          getTextField(
            labelText: 'Senha',
            hintText: '*****',
            leadingIcon: Icons.lock_outline,
            controller: pwdController,
            trailingWidget: IconButton(
              onPressed: () => bloc.add(LoginPwdObscured()),
              icon: Icon(state.isPwdObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined),
            ),
            obscure: state.isPwdObscured,
            // onChanged: (value) => context.read<LoginBloc>().add(PasswordChanged(value)),
          ),
          const SizedBox(height: 20),
          state.isSubmitting
              ? const CircularProgressIndicator()
              : FilledButton(
                  onPressed: () {
                    debugPrint('$runtimeType - emailController.text ${emailController.text}');
                    context.read<LoginBloc>().add(LoginSubmitted(emailController.text, pwdController.text));
                  },
                  child: const Text('Login'),
                ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  TextField getTextField({
    required bool obscure,
    required String labelText,
    required String hintText,
    required IconData leadingIcon,
    required TextEditingController controller,
    List<TextInputFormatter>? inputFormatters,
    Widget? trailingWidget,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: Icon(
          leadingIcon,
        ),
        labelText: labelText,
        hintText: hintText,
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: CustomColor.activeColor,
          ),
        ),
        suffixIcon: trailingWidget,
      ),
      obscureText: obscure,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      controller: controller,
      keyboardType: keyboardType,
    );
  }
}
