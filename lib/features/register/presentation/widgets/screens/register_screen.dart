import 'dart:async';
import 'dart:convert';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/api_provider.dart';
import '../../../../../core/cep_api.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/utils/custom_colors.dart';
import '../../../../../core/utils/log/log.dart';
import '../../../../common/domain/entities/location.dart';
import '../../../../common/presentation/widgets/components/custom_selectable_tile.dart';
import '../../../../common/presentation/widgets/dialogs/single_select_dialog.dart';
import '../../../domain/entities/user_info_data.dart';
import '../address_info_form.dart';

//part 'widgets/address_info_form.dart';

part '../complementary_info_form.dart';

part '../password_creation.dart';

part '../age_confirmation.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  UserInfoData personalData = UserInfoData.empty();

  bool emailExists = false;
  bool cpfExists = false;

  Location? userLocation;
  String userNumber = '';
  String userComplement = '';
  String userProfession = '';
  IncomeRange? userIncome;

  String userPwd = '';
  String userPwdConfirmation = '';

  bool isRegistering = false;
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final int totalSteps = 5;

  // void _nextStep() {
  //   if (_currentStep < totalSteps - 1 && validateInfo()) {
  //     setState(() {
  //       _currentStep++;
  //     });
  //     _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  //   }
  // }

  void _nextStep() {
    if (_currentStep < totalSteps - 1) {
      // Pass step-specific validations + additional validations for email/CPF
      if (validateInfo()) {
        setState(() => _currentStep++);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  bool validateInfo() {
    bool canProceed;

    switch (_currentStep) {
      case 0:
      // Age confirmation step
        canProceed = true;
        break;
      case 1:
      // Personal data step
        canProceed = personalData.isValid && !emailExists && !cpfExists;
        if (!canProceed) {
          context.showSnack(
            emailExists
                ? 'Já existe um login com este email!'
                : cpfExists
                ? 'Já existe um cadastro com este CPF!'
                : personalData.getWarningMessage(),
          );
        }
        break;
      case 2:
      // Address step
        canProceed = userLocation != null && (userLocation?.number.isNotEmpty ?? false);
        if (!canProceed) {
          context.showSnack(
            userLocation == null ? 'Preencha o CEP corretamente' : 'Preencha o número da residência',
          );
        }
        break;
      case 3:
      // Complementary info step
        canProceed = userIncome != null && userProfession.isNotEmpty;
        if (!canProceed) {
          context.showSnack(
              'Preencha o campo profissão e renda'
          );
        }
        break;
      case 4:
      // Password step
        canProceed = userPwd == userPwdConfirmation;
        if (!canProceed) context.showSnack('Senhas não são iguais!');
        break;
      default:
        canProceed = false;
    }

    return canProceed;
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
    final displayMedium = Theme.of(context).textTheme.displayMedium!;

    return Scaffold(
      backgroundColor: CustomColor.backgroundPrimaryColor,
      body: Container(
        //color: Colors.red,
        width: double.infinity,
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('TrustMe', style: displayMedium),
            Image.asset('assets/imgs/trustme-logo.png', height: 100),
            const SizedBox(height: 20),
            Flexible(
              fit: FlexFit.loose,
              child: Container(
                constraints: const BoxConstraints(
                  maxHeight: 475,
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

  // bool validateInfo([List<bool> additionalValidations = const []]) {
  //   bool canProceed = false;
  //
  //   if (_currentStep == 0) {
  //     canProceed = true;
  //   }
  //   if (_currentStep == 1) {
  //     canProceed = personalData.isValid;
  //     if(!canProceed){
  //       context.showSnack(personalData.getWarningMessage());
  //     }
  //
  //   } else if (_currentStep == 2) {
  //     canProceed = userLocation != null && userLocation?.number.isNotEmpty == true;
  //
  //     if(!canProceed){
  //       if(userLocation == null) {
  //         context.showSnack('Preencha o CEP corretamente');
  //       } else if (userLocation?.number.isEmpty ?? true) {
  //         context.showSnack('Preencha o número da residência');
  //       }
  //     }
  //   } else if (_currentStep == 3) {
  //     canProceed = true;
  //   } else if (_currentStep == 4) {
  //     canProceed = userPwd == userPwdConfirmation;
  //     if(!canProceed){
  //       context.showSnack('Senhas não são iguais!');
  //     }
  //   }
  //
  //   if (additionalValidations.isNotEmpty) {
  //     canProceed = canProceed && !additionalValidations.any((element) => !element);
  //   }
  //
  //   return canProceed;
  // }

  void _registerUser() async {
    if (!personalData.isValid) {
      context.showSnack(personalData.getWarningMessage());
      return;
    }

    isRegistering = true;
    setState(() {});

    String? professionValue;

    if(userProfession.trim().isNotEmpty) {
      professionValue = userProfession.trim();
    }

    final content = {
      'email': personalData.email,
      'CPF': personalData.cpf,
      'nome_completo': personalData.name,
      'pais': 'Brasil',
      ...userLocation!.toModel().toJson(),
      'profissao': professionValue,
      'dt_nascimento': personalData.birthDate.toString(),
      'renda_classe': userIncome?.description,

      'password': userPwd,
      'password_confirmation': userPwdConfirmation,
    };
    try {
      final resp = await ApiProvider().post('usuario/gravar', jsonEncode(content), useToken: false);
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
    } catch (e, s) {
      isRegistering = false;
      Log.e('$runtimeType', 'Error registring an user.', e, s);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      setState(() {});
    }
  }

  Widget getForm(int step) {
    if (step == 1) {
      return const _AgeConfirmation();
    } else if (step == 2) {
      return personalData.buildForm(
        onPersonalDataSet: (value, email, cpf) {
          personalData = value;
          emailExists = email;
          cpfExists = cpf;
          setState(() {});
        },
      );
    } else if (step == 3) {
      return AddressInfoForm(
        userLocation: userLocation,
        onLocationChanged: (value) => userLocation = value,
      );
    } else if (step == 4) {
      return ComplementaryInfoForm(
        userProfession: userProfession,
        userIncome: userIncome,
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
