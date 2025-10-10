

import 'package:flutter/material.dart';
import 'package:trustme/features/register/presentation/widgets/complementary_info_form.dart';

class ComplementaryInfoData {
  final bool isEdition;
  String? userProfession;
  IncomeRange? userIncome;

  ComplementaryInfoData({required this.isEdition, this.userProfession, this.userIncome});

  ComplementaryInfoData copyWith({
    String? userProfession,
    ValueGetter<IncomeRange?>? userIncome,
    bool? isEdition,
  }) {
    return ComplementaryInfoData(
      userProfession: userProfession ?? this.userProfession,
      userIncome: userIncome != null ? userIncome() : this.userIncome,
      isEdition: isEdition ?? this.isEdition,
    );
  }

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