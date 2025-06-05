import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/providers/app_data_cubit.dart';
import '../../../../common/domain/entities/person.dart';
import '../../../../common/presentation/widgets/components/stateful_segmented_button.dart';
import '../../../../common/presentation/widgets/dialogs/single_select_dialog.dart';
import '../../../domain/entities/contract.dart';
import '../../../domain/entities/sexual_practice.dart';

class ContractSpecificationWidget extends StatefulWidget {
  const ContractSpecificationWidget({
    required this.type,
    required this.initialPractices,
    required this.users,
    required this.showStatusPerPerson,
    required this.onPick,
    required this.onRemove,
    super.key,
  });

  final ContractType type;
  final List<SexualPractice> initialPractices;
  final List<Person> users;
  final bool showStatusPerPerson;
  final ValueChanged<SexualPractice> onPick;
  final ValueChanged<SexualPractice> onRemove;

  @override
  State<ContractSpecificationWidget> createState() => _ContractSpecificationWidgetState();
}

class _ContractSpecificationWidgetState extends State<ContractSpecificationWidget> {
  late final AppDataCubit appData;

  late final List<SexualPractice> practicesAvailable;
  bool sharesNeedle = false;
  String periodicitySelected = 'Nunca';
  final List<SexualPractice> internTaken = [];

  void _addPractice(SexualPractice value) {
    final updatedValue = value.copyWith(acceptedBy: [userLoggedIn.id]);
    internTaken.add(updatedValue);
    widget.onPick(updatedValue);
    setState(() {});
  }

  void _removePractice(SexualPractice value) {
    internTaken.remove(value);
    widget.onRemove(value);
    setState(() {});
  }

  @override
  void initState() {
    appData = context.read<AppDataCubit>();
    practicesAvailable = appData.getPractices;
    internTaken.addAll(widget.initialPractices);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final titleMedium = Theme.of(context).textTheme.titleMedium!;

    switch (widget.type) {
      case ContractType.sexual:
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Especificações', style: titleMedium),
              const SizedBox(height: 6),
              const Text('Práticas permitidas'),
              ...List.generate(
                internTaken.length,
                (index) {
                  final practice = internTaken[index];

                  return practice.buildTile(
                    widget.users,
                    onRemove: _removePractice,
                    showStatusPerPerson: widget.showStatusPerPerson,
                  );
                },
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (_) {
                          final currentAvailable = List.of(practicesAvailable);

                          for (final ele in internTaken) {
                            currentAvailable.remove(ele);
                          }

                          return SingleSelectDialog<SexualPractice>(
                            title: 'Selecione uma prática',
                            getName: (option) => option.description,
                            onChoose: _addPractice,
                            options: currentAvailable,
                            optionSelected: null,
                          );
                        });
                  },
                  child: const IntrinsicWidth(
                    child: Row(
                      children: [
                        Icon(Icons.add),
                        SizedBox(width: 12),
                        Text('Adicionar prática'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text('Com que frequência você realiza as práticas marcadas acima?'),
              StatefulSegmentedButton<String>(
                options: const ['Nunca', 'Ocasionalmente', 'Frequentemente', 'Sempre'],
                getLabel: (value) => value,
                getValue: (value) => value,
                initialSelection: {periodicitySelected},
                onChanged: (value) {
                  periodicitySelected = value.first;
                  setState(() {});
                },
              ),
              const SizedBox(height: 10),
              const Text('Você costuma usar preservativo nas práticas sexuais?'),
              StatefulSegmentedButton<String>(
                options: const ['Nunca', 'As vezes', 'Na maioria das vezes', 'Sempre'],
                getLabel: (value) => value,
                getValue: (value) => value,
                initialSelection: {periodicitySelected},
                onChanged: (value) {
                  periodicitySelected = value.first;
                  setState(() {});
                },
              ),
              const SizedBox(height: 10),
              const Text('Já compartilhou seringas, agulhas ou outros objetos perfurantes?'),
              ListTile(
                title: const Text('Sim'),
                leading: Radio(
                  value: true,
                  groupValue: sharesNeedle,
                  onChanged: (value) {
                    sharesNeedle = true;
                    setState(() {});
                  },
                ),
              ),
              ListTile(
                title: const Text('Não'),
                leading: Radio(
                  value: false,
                  groupValue: sharesNeedle,
                  onChanged: (value) {
                    sharesNeedle = false;
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        );
      case ContractType.buyAndSale:
        return const SizedBox.shrink();
    }
  }
}
