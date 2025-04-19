part of '../register_screen.dart';

class _AddressInfo extends StatefulWidget {
  const _AddressInfo({
    required this.onStateSet,
    required this.onCitySet,
    required this.onStreetSet,
    required this.onNumberSet,
    required this.onComplementSet,
  });

  final ValueChanged<String> onStateSet;
  final ValueChanged<String> onCitySet;
  final ValueChanged<String> onStreetSet;
  final ValueChanged<String> onNumberSet;
  final ValueChanged<String> onComplementSet;

  @override
  State<_AddressInfo> createState() => _AddressInfoState();
}

class _AddressInfoState extends State<_AddressInfo> {
  Map<String, dynamic>? stateSelected;
  String? citySelected;

  @override
  Widget build(BuildContext context) {
    final titleLarge = Theme.of(context).textTheme.titleLarge!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Endereço', style: titleLarge),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomSelectableTile(
                title: '${stateSelected?['nome'] ?? 'Estado'}',
                isActive: stateSelected != null,
                borderColor: stateSelected != null ? null : CustomColor.vividRed,
                width: double.infinity,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return SingleSelectDialog<Map<String, dynamic>>(
                        title: 'Estado',
                        options: AppConsts.states,
                        getName: (option) => option['nome']!,
                        onChoose: (value) {
                          widget.onStateSet(value['nome']);
                          stateSelected = value;
                          setState(() {});
                        },
                        optionSelected: stateSelected,
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomSelectableTile(
                title: citySelected ?? 'Cidade',
                isActive: citySelected != null,
                width: double.infinity,
                borderColor: citySelected != null ? null : CustomColor.vividRed,
                onTap: () {
                  if (stateSelected == null) return;
                  showDialog(
                    context: context,
                    builder: (context) {
                      return SingleSelectDialog<String>(
                        title: 'Cidade',
                        options: stateSelected!['cidades'],
                        getName: (option) => option,
                        onChoose: (value) {
                          widget.onCitySet(value);
                          citySelected = value;
                          setState(() {});
                        },
                        optionSelected: citySelected,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Rua',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Número',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Complemento',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
