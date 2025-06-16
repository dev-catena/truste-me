import 'dart:convert';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api_provider.dart';
import '../../../core/cep_api.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/custom_colors.dart';
import '../../common/domain/entities/location.dart';
import '../../common/presentation/widgets/components/custom_selectable_tile.dart';
import '../../common/presentation/widgets/dialogs/single_select_dialog.dart';

part 'widgets/user_info.dart';

part 'widgets/address_info.dart';

part 'widgets/complementary_info.dart';

part 'widgets/password_creation.dart';

part 'widgets/age_confirmation.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String userName = '';
  String userCpf = '';
  String userEmail = '';
  DateTime? birthDate;

  Location? userLocation;
  String userNumber = '';
  String userComplement = '';
  String userProfession = '';
  late IncomeRange userIncome;

  String userPwd = '';
  String userPwdConfirmation = '';

  bool isRegistering = false;
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // your form variables here...

  final int totalSteps = 5;

  void _nextStep() {
    if (_currentStep < totalSteps - 1 && validateInfo()) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
    }
  }

  void _previousStep() {
    if (_currentStep == 0) {
      context.pop();
    } else {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.backgroundPrimaryColor,
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/imgs/trustme-logo.png', height: 100),
            const SizedBox(height: 20),
            Flexible(
              fit: FlexFit.loose,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 360,
                ),
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), // lock swipe
                  itemCount: totalSteps,
                  itemBuilder: (context, index) => Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: CustomColor.activeColor),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SingleChildScrollView(child: getForm(index + 1)),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text('${_currentStep + 1}/$totalSteps', style: const TextStyle(color: Colors.black54)),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(onPressed: _previousStep, child: const Text('Voltar')),
                isRegistering
                    ? const CircularProgressIndicator()
                    : FilledButton(
                        onPressed: _currentStep == totalSteps - 1 ? _registerUser : _nextStep,
                        // style: ButtonStyle(
                        //   backgroundColor:
                        //       WidgetStatePropertyAll(!validateInfo() ? CustomColor.activeColor.withAlpha(100) : null),
                        // ),
                        child: Text(_currentStep == totalSteps - 1 ? 'Cadastrar' : 'Próximo'),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }

  bool validateInfo() {
    bool canProceed = false;
    if (_currentStep == 0) {
      canProceed = true;
    }
    if (_currentStep == 1) {
      canProceed = userName != '' && CPFValidator.isValid(userCpf) && birthDate != null && isValidEmail(userEmail);
    } else if (_currentStep == 2) {
      canProceed = userLocation != null;
    } else if (_currentStep == 3) {
      canProceed = true;
    } else if (_currentStep == 4) {
      canProceed = userPwd == userPwdConfirmation;
    }

    return canProceed;
  }

  void _registerUser() async {
    isRegistering = true;
    setState(() {});
    final content = {
      'email': userEmail,
      'password': userPwd,
      'nome_completo': userName,
      'CPF': userCpf,
      'pais': 'Brasil',
      ...userLocation!.toModel().toJson(),
      'profissao': userProfession,
      'dt_nascimento': birthDate.toString(),
    };
    try {
      final resp = await ApiProvider(false).post('usuario/gravar', jsonEncode(content));
      isRegistering = false;
      setState(() {});

      if (resp['user'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Usuário cadastrado com sucesso!'),
        ));
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro!\n$resp')));
      }

      setState(() {});
    } catch (e) {
      isRegistering = false;
      debugPrint('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      setState(() {});
    }
  }

  Widget getForm(int step) {
    if (step == 1) {
      return const _AgeConfirmation();
    } else if (step == 2) {
      return _UserInfo(
        onNameSet: (value) => userName = value,
        onCpfSet: (value) => userCpf = value,
        onEmailSet: (value) => userEmail = value,
        onBirthDateChanged: (value) => birthDate = value,
        currentName: userName,
        currentBirthDate: birthDate,
        currentCpf: userCpf,
        currentEmail: userEmail,
      );
    } else if (step == 3) {
      return _AddressInfo(
        onLocationChanged: (value) => userLocation = value,
      );
    } else if (step == 4) {
      return _ComplementaryInfo(
        onProfessionSet: (value) => userProfession = value,
        onIncomeSet: (value) => userIncome = value,
      );
    } else if (step == 5) {
      return _PasswordCreation(
        onPasswordSet: (value) => userPwd = value,
        onPasswordConfirmSet: (value) => userPwdConfirmation = value,
      );
    } else {
      return const SizedBox();
    }
  }
}
