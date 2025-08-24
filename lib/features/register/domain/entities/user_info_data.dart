import 'dart:async';
import 'dart:convert';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/api_provider.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../core/utils/custom_colors.dart';
import '../../../common/presentation/widgets/components/custom_selectable_tile.dart';

part '../../presentation/widgets/personal_info_form.dart';

class UserInfoData {
  final String name;
  final String cpf;
  final String email;
  final DateTime birthDate;

  UserInfoData({
    required this.name,
    required this.cpf,
    required this.email,
    required this.birthDate,
  });

  final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  UserInfoData copyWith({String? name, String? cpf, String? email, DateTime? birthDate}) {
    return UserInfoData(
      name: name ?? this.name,
      cpf: cpf ?? this.cpf,
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
    );
  }

  bool get isNameValid => name.isNotEmpty && name.contains(' ');

  bool get isCpfValid => CPFValidator.isValid(cpf);

  bool get isEmailValid => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  bool get isBirthValid => birthDate.isLegalAge();

  bool get isValid => isNameValid && isCpfValid && isEmailValid && isBirthValid;

  String getWarningMessage() {
    final List<String> errors = [];

    if (name.isEmpty || !name.contains(' ')) {
      errors.add('nome');
    }
    if (!CPFValidator.isValid(cpf)) {
      errors.add('CPF');
    }
    if (!_emailRegex.hasMatch(email)) {
      errors.add('e-mail');
    }
    if (!birthDate.isLegalAge()) {
      errors.add('idade mínima de 18 anos');
    }

    if (errors.isNotEmpty) {
      String message;
      if (errors.length == 1) {
        message = errors.first;
        message[0].toUpperCase();
        message += ' '
            'inválido!';
      } else {
        message = 'Os seguintes dados estão incorretos: ';
        message += '${errors.sublist(0, errors.length - 1).join(', ')} e ${errors.last}';
      }

      return message;
    } else {
      return 'Dados corretos!';
    }
  }

  Widget buildForm({
    required void Function(UserInfoData userData, bool emailAlreadyExists, bool cpfAlreadyExists) onPersonalDataSet,
  }) {
    return _PersonalInfoForm(currentData: this, onPersonalDataSet: onPersonalDataSet);
  }

  UserInfoData.empty() : this(name: '', email: '', cpf: '', birthDate: DateTime.now());
}