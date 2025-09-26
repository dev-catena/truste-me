

import 'package:flutter/material.dart';

import '../../presentation/register_screen.dart';

class ComplementaryInfoData {
  final bool isEdition;
  String? userProfession;
  IncomeRange? userIncome;

  ComplementaryInfoData({required this.isEdition, this.userProfession, this.userIncome});

  bool get isProfessionValid => userProfession != null && userProfession!.isNotEmpty;
  bool get isIncomeValid => userIncome != null;

  bool get isValid => isProfessionValid && isIncomeValid;

  String getWarningMessage() {
    final List<String> errors = [];

    if (!isProfessionValid) {
      errors.add('Profissão');
    }

    if(!isIncomeValid) {
      errors.add('Renda');
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
    required ValueChanged<String> onProfessionSet,
    required ValueChanged<IncomeRange> onIncomeSet,

  }) {
    return ComplementaryInfoForm(isEdition: true, userProfession: userProfession, userIncome: userIncome, onProfessionSet: onProfessionSet, onIncomeSet: onIncomeSet);
  }
}