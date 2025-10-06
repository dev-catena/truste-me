import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:trustme/core/cep_api.dart';
import 'package:trustme/core/extensions/context_extensions.dart';
import 'package:trustme/core/utils/custom_colors.dart';
import 'package:trustme/features/common/domain/entities/location.dart';

enum _InputType {
  number,
  complement;
}

class AddressInfoForm extends StatefulWidget {
  final Location? userLocation;
  final ValueChanged<Location> onLocationChanged;

  const AddressInfoForm({super.key, required this.onLocationChanged, this.userLocation,});

  @override
  State<AddressInfoForm> createState() => _AddressInfoFormState();
}

class _AddressInfoFormState extends State<AddressInfoForm> {
  final cepController = TextEditingController();
  final numberController = TextEditingController();
  final complementController = TextEditingController();
  Map<String, dynamic>? stateSelected;
  String? citySelected;
  Location? location;

  final FocusNode _cepFocus = FocusNode();
  final FocusNode _numberFocus = FocusNode();
  final FocusNode _complementFocus = FocusNode();

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  void dispose() {
    _cepFocus.dispose();
    _numberFocus.dispose();
    _complementFocus.dispose();

    cepController.dispose();
    numberController.dispose();
    complementController.dispose();

    super.dispose();
  }

  void _loadData() {

    final loc = widget.userLocation;

    if(loc != null) {
      cepController.text = loc.cep;
      numberController.text = loc.number;
      complementController.text = loc.complement;
      location = loc;
    }
  }

  Future<void> searchCep(String cep) async {
    if (cep.length <= 9) return;
    try {
      final cleanedCep = cep.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '');
      location = await CepAPI().getCep(cleanedCep);
      FocusScope.of(context).unfocus();

      if(location != null && widget.userLocation != null) {
        location = location!.copyWith(id: widget.userLocation!.id);
      }

      widget.onLocationChanged(location!);
      setState(() {});
    } catch (e) {
      context.showSnack('CEP inválido!');
    }
  }

  void locationUpdate(_InputType type) {
    final Location updated;
    if (type == _InputType.number) {
      updated = location!.copyWith(number: numberController.text);
    } else {
      updated = location!.copyWith(number: numberController.text, complement: complementController.text);
    }
    widget.onLocationChanged(updated);
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

  @override
  Widget build(BuildContext context) {
    final titleLarge = Theme.of(context).textTheme.titleLarge!;
    final bodySmall = Theme.of(context).textTheme.bodySmall!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text('Endereço', style: titleLarge, textAlign: (location?.id ?? -1) > 0 ? TextAlign.left : TextAlign.center,),
        ),
        if((location?.id ?? -1) <= 0)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Endereço completo obrigatório. Fique tranquilo: ele não será exibido para ninguém, '
              'apenas usado para validar as informações e gerar selos de verificação.',
              textAlign: TextAlign.center,
              style: bodySmall,
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: cepController,
                focusNode: _cepFocus,
                onTapOutside: (_) => _cepFocus.unfocus(),
                onSubmitted: (value) async { await searchCep(value); FocusScope.of(context).requestFocus(_numberFocus); },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'CEP',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CepInputFormatter(),
                ],
                onEditingComplete: () => searchCep(cepController.text),
              ),
            ),
            const SizedBox(width: 20),
            FilledButton(
              onPressed: () => searchCep(cepController.text),
              child: const Text('Buscar'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: location?.state ?? 'Estado',
                ),
                enabled: false,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: location?.city ?? 'Cidade',
                ),
                enabled: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: location?.neighborhood ?? 'Bairro',
          ),
          enabled: false,
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: location?.street ?? 'Rua',
          ),
          enabled: false,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: numberController,
                focusNode: _numberFocus,
                decoration: getDecoration(
                  label: 'Número',
                  isValid: numberController.text.isNotEmpty || cepController.text.isEmpty,
                ),
                enabled: location != null,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onSubmitted: (_) { locationUpdate(_InputType.number); _numberFocus.unfocus(); },
                onTapOutside: (_) {
                  locationUpdate(_InputType.number);
                  _numberFocus.unfocus(); //FocusScope.of(context).unfocus();
                },
                onEditingComplete: () => locationUpdate(_InputType.number),
                onChanged: (value) {
                  locationUpdate(_InputType.number);
                  setState(() {});
                },
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 3,
              child: TextField(
                controller: complementController,
                focusNode: _complementFocus,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Complemento',
                ),
                enabled: location != null,
                onSubmitted: (_) { locationUpdate(_InputType.complement); _complementFocus.unfocus(); },
                onTapOutside: (_) {
                  locationUpdate(_InputType.complement);
                  _complementFocus.unfocus();
                  //FocusScope.of(context).unfocus();
                },
                onEditingComplete: () => locationUpdate(_InputType.complement),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
