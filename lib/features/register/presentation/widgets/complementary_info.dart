part of '../register_screen.dart';

enum IncomeRange {
  classA('Classe A', 'Maior que R\$30 mil'),
  classB('Classe B', 'Entre R\$12.1 mil e R\$30 mil'),
  classC('Classe C', 'Entre R\$3.6 mil e R\$12.1 mil'),
  classDE('Classe D/E', 'Até R\$3.600');

  final String description;
  final String range;

  const IncomeRange(this.description, this.range);
}

class _ComplementaryInfo extends StatefulWidget {
  const _ComplementaryInfo({
    required this.onProfessionSet,
    required this.onIncomeSet,
  });

  final ValueChanged<String> onProfessionSet;
  final ValueChanged<IncomeRange> onIncomeSet;

  @override
  State<_ComplementaryInfo> createState() => _ComplementaryInfoState();
}

class _ComplementaryInfoState extends State<_ComplementaryInfo> {
  IncomeRange? incomeSelected;

  @override
  Widget build(BuildContext context) {
    final titleLarge = Theme.of(context).textTheme.titleLarge!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Dados complementares', style: titleLarge),
          const SizedBox(height: 16),
          TextField(
            onChanged: widget.onProfessionSet,
            decoration: const InputDecoration(
              labelText: 'Profissão',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          CustomSelectableTile(
            title: incomeSelected?.description ?? 'Renda',
            isActive: incomeSelected != null,
            width: double.infinity,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return SingleSelectDialog<IncomeRange>(
                    title: 'Faixa de renda',
                    options: IncomeRange.values,
                    getName: (option) => '${option.description} - ${option.range}',
                    onChoose: (value) {
                      incomeSelected = value;
                      widget.onIncomeSet(value);
                      setState(() {});
                    },
                    optionSelected: incomeSelected,
                  );
                },
              );
            },
          )
        ],
      ),
    );
  }
}
