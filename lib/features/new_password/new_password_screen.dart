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
  static const DEF_PASSWORD_LENGTH = 8;

  final _emailController = TextEditingController();
  final _codeController = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _codeFocus = FocusNode();
  final _firstPwdController = TextEditingController();
  final _secondPwdController = TextEditingController();

  final FocusNode _firstPwdFocus = FocusNode();
  final FocusNode _SecondPwdFocus = FocusNode();

  int currentStep = 1;
  final newPwdDt = NewPasswordDataSource();
  bool isLoading = false;

  bool wasEmailTouched = false;
  bool wasCodeTouched = false;
  bool wasFirstPwdTouched = false;
  bool wasSecondPwdTouched = false;

  @override
  void initState() {
    super.initState();

    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) {
        setState(() => wasEmailTouched = true);
      }
    });

    _codeFocus.addListener(() {
      if (!_codeFocus.hasFocus) {
        setState(() => wasCodeTouched = true);
      }
    });

    _firstPwdFocus.addListener(() {
      if (!_firstPwdFocus.hasFocus) {
        setState(() => wasFirstPwdTouched = true);
      }
    });

    _SecondPwdFocus.addListener(() {
      if (!_SecondPwdFocus.hasFocus) {
        setState(() => wasSecondPwdTouched = true);
      }
    });
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }

  InputDecoration getDecoration({String? label, bool isValid = false}) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderSide: BorderSide(
          color: isValid ? Colors.black26 : Colors.red,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: isValid ? Colors.black26 : Colors.red,
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
      return 'Digite a nova senha.\nA senha deve contar pelo menos $DEF_PASSWORD_LENGTH caracteres.';
    } else {
      return 'Fora dos steps';
    }
  }

  Widget getFormField() {
    final Widget child;

    if (currentStep == 1) {
      child = TextField(
        controller: _emailController,
        focusNode: _emailFocus,
        onChanged: (_) {
          if(!wasEmailTouched) {
            wasEmailTouched = true;
          }
          setState(() {});
        },
        decoration: getDecoration(
          label: 'Email',
          isValid: !wasEmailTouched || _isValidEmail(_emailController.text),
        ),
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.emailAddress,
        onTapOutside: (_) => _emailFocus.unfocus(),
        onSubmitted: sendEmail,
      );
    } else if (currentStep == 2) {
      child = TextField(
        controller: _codeController,
        focusNode: _codeFocus,
        onChanged: (_) {
          if(!wasCodeTouched) {
            wasCodeTouched = true;
          }
          setState(() {});
        },
        decoration: getDecoration(
          label: 'Código',
          isValid: !wasCodeTouched || _codeController.text.length == 6,
        ),
        maxLength: 6,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        textInputAction: TextInputAction.done,
        onTapOutside: (_) => _codeFocus.unfocus(),
        onSubmitted: sendCode,
      );
    } else if (currentStep == 3) {
      child = Column(
        children: [
          TextField(
            controller: _firstPwdController,
            focusNode: _firstPwdFocus,
            decoration: getDecoration(
              label: 'Senha',
              isValid: !wasFirstPwdTouched || _firstPwdController.text.length >= DEF_PASSWORD_LENGTH,
            ),
            onTapOutside: (_) {
              _firstPwdFocus.unfocus();
              //FocusScope.of(context).unfocus();
            },
            onChanged: (value){
              if(!wasFirstPwdTouched) {
                setState(() => wasFirstPwdTouched = true);
              }
            },
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _secondPwdController,
            focusNode: _SecondPwdFocus,
            decoration: getDecoration(
              label: 'Repita a senha',
              isValid: _firstPwdController.text == _secondPwdController.text,
            ),
            onTapOutside: (_) {
              _SecondPwdFocus.unfocus();
              //FocusScope.of(context).unfocus();
            },
            onChanged: (value){
              if(!wasSecondPwdTouched) {
                setState(() => wasSecondPwdTouched = true);
              }
            },
            textInputAction: TextInputAction.done,
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
    if(pwd.length < DEF_PASSWORD_LENGTH || _firstPwdController.text != _secondPwdController.text) return;

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
    _emailFocus.dispose();
    _codeFocus.dispose();
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
