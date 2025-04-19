import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api_provider.dart';
import '../../../core/utils/consts.dart';
import '../../../core/utils/custom_colors.dart';
import '../../common/presentation/widgets/components/custom_selectable_tile.dart';
import '../../common/presentation/widgets/dialogs/single_select_dialog.dart';

part 'widgets/personal_info.dart';

part 'widgets/address_info.dart';

part 'widgets/complementary_info.dart';

part 'widgets/password_creation.dart';

part 'widgets/age_confirmation.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  int _currentStep = 1;
  late AnimationController _controller;
  late Animation<Offset> _animation;

  bool _isGoingForward = true;

  String userName = '';
  String userCpf = '';
  String userEmail = '';
  DateTime? birthDate;

  String userState = '';
  String userCity = '';
  String userStreet = '';
  String userNumber = '';
  String userComplement = '';
  String userProfession = '';
  late IncomeRange userIncome;

  String userPwd = '';
  String userPwdConfirmation = '';

  bool isRegistering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _updateAnimation();
  }

  void _updateAnimation() {
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: _isGoingForward ? const Offset(-1.0, 0.0) : const Offset(1.0, 0.0),
    ).animate(_controller);
  }

  bool validateInfo() {
    bool canProceed = false;
    if (_currentStep == 1) {
      canProceed = true;
    }
    if (_currentStep == 2) {
      canProceed = userName != '' && userCpf != '' && birthDate != null;
    } else if (_currentStep == 3) {
      canProceed = userState != '' && userCity != '';
    } else if (_currentStep == 4) {
      canProceed = true;
    } else if (_currentStep == 5) {
      canProceed = userPwd == userPwdConfirmation;
    }

    return canProceed;
  }

  void _nextStep() {
    if (_currentStep < 5) {
      final bool canProceed = validateInfo();

      if (canProceed) {
        setState(() => _isGoingForward = true);
        _updateAnimation();
        _controller.forward(from: 0.0).then((_) {
          setState(() => _currentStep++);
          _controller.reset(); // Reset for next animation
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha todos os campos')));
      }
    }
  }

  void _previousStep() {
    if (_currentStep <= 1) {
      context.pop();
    } else {
      setState(() => _isGoingForward = false);
      _updateAnimation();
      _controller.forward(from: 0.0).then((_) {
        setState(() => _currentStep--);
        _controller.reset(); // Reset for next animation
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            // const Icon(Icons.shield_outlined, size: 80, color: CustomColor.activeColor),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  children: [
                    Transform.translate(
                      offset: _animation.value * 350, // Move horizontally
                      child: Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: CustomColor.activeColor),
                          ),
                          child: getForm(_currentStep)),
                    ),
                    Transform.translate(
                      offset: Offset((_animation.value.dx + (_isGoingForward ? 1 : -1)) * 350, 0),
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: CustomColor.activeColor),
                        ),
                        child: getForm(_isGoingForward ? _currentStep + 1 : _currentStep - 1),
                      ),
                    ),
                  ],
                );
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$_currentStep/5',
                style: const TextStyle(color: Colors.black54),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(onPressed: _previousStep, child: const Text('Voltar')),
                isRegistering
                    ? const CircularProgressIndicator()
                    : FilledButton(
                  onPressed: _currentStep == 5
                      ? () async {
                    if (userPwd == userPwdConfirmation) {
                      isRegistering = true;
                      setState(() {});
                      final content = {
                        'email': userEmail,
                        'password': userPwd,
                        'nome_completo': userName,
                        'CPF': userCpf,
                        'pais': 'Brasil',
                        'estado': userState,
                        'cidade': userCity,
                        'endereco':
                        '$userStreet$userNumber${userNumber != '' ? ', $userNumber' : ''}${userComplement != ''
                            ? ' - $userComplement'
                            : ''}',
                        'profissao': userProfession,
                        'dt_nascimento': birthDate.toString(),
                      };
                      try {
                        await ApiProvider(false).post('usuario/gravar', jsonEncode(content));
                      } catch (e, s) {
                        isRegistering = false;
                        debugPrint('Error: $e');
                        setState(() {});
                      }
                      isRegistering = false;
                      setState(() {});
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('As senhas precisam ser idênticas'),
                      ));
                    }
                  }
                      : _nextStep,
                  child: Text(_currentStep == 5 ? 'Cadastrar' : 'Próximo'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getForm(int step) {
    if (step == 1) {
      return const _AgeConfirmation();
    } else if (step == 2) {
      return _PersonalInfo(
        onNameSet: (value) => userName = value,
        onCpfSet: (value) => userCpf = value,
        onEmailSet: (value) => userEmail = value,
        onBirthDateChanged: (value) => birthDate = value,
      );
    } else if (step == 3) {
      return _AddressInfo(
        onCitySet: (value) => userCity = value,
        onStateSet: (value) => userState = value,
        onStreetSet: (value) => userStreet = value,
        onNumberSet: (value) => userNumber = value,
        onComplementSet: (value) => userComplement = value,
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
