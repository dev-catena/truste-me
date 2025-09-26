import 'package:flutter/material.dart';

import '../../../common/domain/entities/location.dart';
import '../../presentation/widgets/address_info_form.dart';

class AddressInfoData {
  final bool isEdition;
  Location loc;

  AddressInfoData({required this.loc, this.isEdition = false});

  bool get isCEPValid => loc.cep.isNotEmpty;
  bool get isStateValid => loc.state.isNotEmpty;
  bool get isCityValid => loc.city.isNotEmpty;
  bool get isNeighborhood => loc.neighborhood.isNotEmpty;
  bool get isStreetValid => loc.street.isNotEmpty;
  bool get isAddressNumberValid => loc.number.isNotEmpty;

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
