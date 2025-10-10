import 'package:flutter/material.dart';

import 'package:trustme/features/common/domain/entities/location.dart';
import 'package:trustme/features/register/presentation/widgets/address_info_form.dart';

class AddressInfoData {
  final bool isEdition;
  Location? loc;

  AddressInfoData({this.loc, this.isEdition = false});

  AddressInfoData copyWith({
    ValueGetter<Location?>? loc,
    bool? isEdition,
  }) {
    return AddressInfoData(
      loc: loc != null ? loc() : this.loc,
      isEdition: isEdition ?? this.isEdition
    );
  }

  bool get isCEPValid => loc?.cep.isNotEmpty ?? false;
  bool get isStateValid => loc?.state.isNotEmpty ?? false;
  bool get isCityValid => loc?.city.isNotEmpty ?? false;
  bool get isNeighborhood => loc?.neighborhood.isNotEmpty ?? false;
  bool get isStreetValid => loc?.street.isNotEmpty ?? false;
  bool get isAddressNumberValid => loc?.number.isNotEmpty ?? false;

  bool get isValid => isCEPValid && isStateValid && isCityValid && isNeighborhood && isStreetValid && isAddressNumberValid;

  String getWarningMessage() {
    final List<String> errors = [];

    if (!isCEPValid || !isStateValid || !isCityValid || !isNeighborhood || !isStreetValid) {
      errors.add('Cep');
    }

    if(!isAddressNumberValid) {
      errors.add('Número');
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
    required ValueChanged<Location> onLocationChanged,
  }) {
    return AddressInfoForm(userLocation: loc, onLocationChanged: onLocationChanged);
  }
}
