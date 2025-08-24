part of '../register_screen.dart';

enum _InputType {
  number,
  complement;
}

class _AddressInfo extends StatefulWidget {
  const _AddressInfo({
    required this.onLocationChanged,
  });

  final ValueChanged<Location> onLocationChanged;

  @override
  State<_AddressInfo> createState() => _AddressInfoState();
}

class _AddressInfoState extends State<_AddressInfo> {
  final cepController = TextEditingController();
  final numberController = TextEditingController();
  final complementController = TextEditingController();
  Map<String, dynamic>? stateSelected;
  String? citySelected;
  Location? location;

  Future<void> searchCep(String cep) async {
    if (cep.length <= 9) return;
    try {
      final cleanedCep = cep.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '');
      location = await CepAPI().getCep(cleanedCep);
      FocusScope.of(context).unfocus();

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
      updated = location!.copyWith(complement: complementController.text);
    }
    widget.onLocationChanged(updated);
  }

  InputDecoration getDecoration({String? label, bool isValid = false}) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderSide: BorderSide(
          color: isValid ? Colors.black87 : Colors.red,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: isValid ? Colors.black87 : Colors.red,
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
        Text('Endereço', style: titleLarge),
        const SizedBox(height: 6),
        Text(
          'Endereço completo obrigatório. Fique tranquilo: ele não será exibido para ninguém, '
          'apenas usado para validar as informações e gerar selos de verificação.',
          textAlign: TextAlign.center,
          style: bodySmall,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'CEP',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CepInputFormatter(),
                ],
                onEditingComplete: () => searchCep(cepController.text),
                onSubmitted: (value) => searchCep(value),
                controller: cepController,
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
                decoration: getDecoration(
                  label: 'Número',
                  isValid: numberController.text.isNotEmpty,
                ),
                enabled: location != null,
                controller: numberController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onSubmitted: (_) => locationUpdate(_InputType.number),
                onTapOutside: (_) {
                  locationUpdate(_InputType.number);
                  FocusScope.of(context).unfocus();
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
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Complemento',
                ),
                enabled: location != null,
                controller: complementController,
                onSubmitted: (_) => locationUpdate(_InputType.complement),
                onTapOutside: (_) {
                  locationUpdate(_InputType.complement);
                  FocusScope.of(context).unfocus();
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
