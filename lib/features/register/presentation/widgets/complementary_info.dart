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
  final String? userProfession;
  final IncomeRange? userIncome;
  final ValueChanged<String> onProfessionSet;
  final ValueChanged<IncomeRange> onIncomeSet;

  const _ComplementaryInfo({
    this.userProfession, this.userIncome,
    required this.onProfessionSet,
    required this.onIncomeSet,
  });

  @override
  State<_ComplementaryInfo> createState() => _ComplementaryInfoState();
}

class _ComplementaryInfoState extends State<_ComplementaryInfo> {
  final professionController = TextEditingController();
  IncomeRange? incomeSelected;

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  void _loadData() {
    professionController.text = widget.userProfession ?? '';
    incomeSelected = widget.userIncome;
  }

  @override
  void dispose() {
    professionController.dispose();
    super.dispose();
  }

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
            controller: professionController,
            onChanged: widget.onProfessionSet,
            textCapitalization: TextCapitalization.sentences,
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
                    showSearchBar: false,
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
