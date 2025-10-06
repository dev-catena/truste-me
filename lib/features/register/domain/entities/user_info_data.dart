import 'dart:async';
import 'dart:convert';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trustme/features/register/presentation/widgets/personal_info_form.dart';

import 'package:trustme/core/extensions/datetime_extensions.dart';

class UserInfoData {
  final int id;
  final String name;
  final String cpf;
  final String email;
  final DateTime? birthDate;

  const UserInfoData({
    required this.id,
    required this.name,
    required this.cpf,
    required this.email,
    required this.birthDate,
  });

  const UserInfoData.empty() : this(id: -1, name: '', email: '', cpf: '', birthDate: null);

  static const _emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';

  UserInfoData copyWith({int? id, String? name, String? cpf, String? email, DateTime? birthDate}) {
    return UserInfoData(
      id: id ?? this.id,
      name: name ?? this.name,
      cpf: cpf ?? this.cpf,
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
    );
  }

  bool get isNameValid => name.isNotEmpty && name.contains(' ');

  bool get isCpfValid => CPFValidator.isValid(cpf);

  bool get isEmailValid => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  bool get isBirthValid => birthDate?.isLegalAge() ?? false;

  bool get isValid => isNameValid && isCpfValid && isEmailValid && isBirthValid;

  String getWarningMessage() {
    final List<String> errors = [];

    if (name.isEmpty || !name.contains(' ')) {
      errors.add('Nome');
    }
    if (!CPFValidator.isValid(cpf)) {
      errors.add('CPF');
    }
    if (!RegExp(_emailRegex).hasMatch(email)) {
      errors.add('e-mail');
    }
    if (!(birthDate?.isLegalAge() ?? false)) {
      errors.add('Idade mínima de 18 anos');
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
    return PersonalInfoForm(currentData: this, onPersonalDataSet: onPersonalDataSet);
  }
}