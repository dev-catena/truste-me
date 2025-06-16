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
      updated = location!.copyWith(complement: numberController.text);
    } else {
      updated = location!.copyWith(complement: complementController.text);
    }
    widget.onLocationChanged(updated);
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
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
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Número',
                ),
                controller: numberController,
                onSubmitted: (_) => locationUpdate(_InputType.number),
                onTapOutside: (_) => locationUpdate(_InputType.number),
                onEditingComplete: () => locationUpdate(_InputType.number),
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
                controller: complementController,
                onSubmitted: (_) => locationUpdate(_InputType.complement),
                onTapOutside: (_) => locationUpdate(_InputType.complement),
                onEditingComplete: () => locationUpdate(_InputType.complement),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
