import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/utils/custom_colors.dart';
import 'new_password_data_source.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _firstPwdController = TextEditingController();
  final _secondPwdController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _pwdFocusNode = FocusNode();
  int currentStep = 1;
  final newPwdDt = NewPasswordDataSource();
  bool isLoading = false;

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }

  InputDecoration getDecoration({String? label, bool isValid = false}) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderSide: BorderSide(
          color: isValid ? Colors.black87 : Colors.red,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: isValid ? Colors.black87 : Colors.red,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: isValid ? CustomColor.activeColor : Colors.red,
          width: 2,
        ),
      ),
    );
  }

  String getText() {
    if (currentStep == 1) {
      return 'Digite o email cadastrado.';
    } else if (currentStep == 2) {
      return 'Digite o código recebido no email.\nO código tem validade de 10 minutos.';
    } else if (currentStep == 3) {
      return 'Digite a nova senha.\nA senha deve contar pelo menos 8 caracteres.';
    } else {
      return 'Fora dos steps';
    }
  }

  Widget getFormField() {
    final Widget child;

    if (currentStep == 1) {
      child = TextField(
        controller: _emailController,
        onChanged: (_) => setState(() {}),
        decoration: getDecoration(
          label: 'Email',
          isValid: _isValidEmail(_emailController.text),
        ),
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.emailAddress,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        onSubmitted: sendEmail,
      );
    } else if (currentStep == 2) {
      child = TextField(
        controller: _codeController,
        onChanged: (_) => setState(() {}),
        decoration: getDecoration(
          label: 'Código',
          isValid: _codeController.text.length == 6,
        ),
        maxLength: 6,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        textInputAction: TextInputAction.done,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        onSubmitted: sendCode,
      );
    } else if (currentStep == 3) {
      child = Column(
        children: [
          TextField(
            controller: _firstPwdController,
            decoration: getDecoration(
              label: 'Senha',
              isValid: _firstPwdController.text.length >= 8,
            ),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            textInputAction: TextInputAction.next,
            focusNode: _emailFocusNode,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _secondPwdController,
            decoration: getDecoration(
              label: 'Repita a senha',
              isValid: _firstPwdController.text == _secondPwdController.text,
            ),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            textInputAction: TextInputAction.done,
            focusNode: _pwdFocusNode,
            onSubmitted: (value) => changePwd(_secondPwdController.text),
          ),
          const SizedBox(height: 15),
        ],
      );
    } else {
      child = const Text('Fora dos steps');
    }

    return child;
  }

  Future<void> sendEmail(String email) async {
    if(!_isValidEmail(email)) return;

    isLoading = true;
    setState(() {});

    final isValid = await newPwdDt.verifyEmail(email);
    if (isValid) {
      currentStep++;
      context.showSnack('Email validado! Verifique o código recebido!');
    } else {
      context.showSnack('Email inválido');
    }

    isLoading = false;
    setState(() {});
  }

  Future<void> sendCode(String code) async {
    if (code.length != 6) return;
    final intCode = int.parse(code);

    isLoading = true;
    setState(() {});

    final isValid = await newPwdDt.validateCode(intCode);
    if (isValid) {
      currentStep++;
      context.showSnack('Código válido!');
    } else {
      context.showSnack('Código inválido');
    }

    isLoading = false;
    setState(() {});
  }

  Future<void> changePwd(String pwd) async {
    if(pwd.length < 8 || _firstPwdController.text != _secondPwdController.text) return;

    isLoading = true;
    setState(() {});

    final intCode = int.parse(_codeController.text);

    final hasChanged = await newPwdDt.resetPwd(intCode, pwd);

    if(hasChanged){
      context.showSnack('Senha alterada com sucesso');
      await Future.delayed(const Duration(seconds: 2));
      if(context.mounted){
        context.pop();
      }

    } else {
      context.showSnack('Não foi possível alterar a senha');
    }

    isLoading = false;
    setState(() {});
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleLarge = Theme.of(context).textTheme.titleLarge;
    final displayMedium = Theme.of(context).textTheme.displayMedium!;

    return Scaffold(
      backgroundColor: CustomColor.backgroundPrimaryColor,
      appBar: AppBar(
        title: const Text('TrustMe', style: TextStyle(color: Colors.white)),
        backgroundColor: CustomColor.activeColor,
      ),
      body: Center(
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
                      Text(getText(), textAlign: TextAlign.center),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: getFormField(),
                      ),
                      const SizedBox(height: 20),
                      if(isLoading)
                        const CircularProgressIndicator()
                        else
                      FilledButton(
                        onPressed: () {
                          if (currentStep == 1) {
                            sendEmail(_emailController.text);
                          } else if (currentStep == 2) {
                            sendCode(_codeController.text);
                          } else if(currentStep == 3){
                            changePwd(_secondPwdController.text);
                          }
                        },
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
}
