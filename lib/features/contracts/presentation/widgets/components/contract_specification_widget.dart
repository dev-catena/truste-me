import 'package:flutter/material.dart';

import '../../../../common/domain/entities/person.dart';
import '../../../../common/presentation/widgets/components/stateful_segmented_button.dart';
import '../../../../common/presentation/widgets/dialogs/single_select_dialog.dart';
import '../../../domain/entities/contract_type.dart';
import '../../../domain/entities/sexual_practice.dart';

class ContractSpecificationWidget extends StatelessWidget {
  const ContractSpecificationWidget({
    required this.type,
    required this.practicesAvailable,
    required this.initialPractices,
    required this.participants,
    required this.showStatusPerPerson,
    required this.onPick,
    required this.onRemove,
    required this.onAcceptOrDeny,
    super.key,
  });

  final ContractType type;
  final List<SexualPractice> practicesAvailable;
  final List<SexualPractice> initialPractices;
  final List<Person> participants;
  final bool showStatusPerPerson;
  final ValueChanged<SexualPractice> onPick;
  final ValueChanged<SexualPractice>? onRemove;
  final void Function(SexualPractice practice, bool hasAccepted)? onAcceptOrDeny;

  final bool sharesNeedle = false;

  final String periodicitySelected = 'Nunca';

  // final List<SexualPractice> internTaken = [];

  @override
  Widget build(BuildContext context) {
    final titleMedium = Theme.of(context).textTheme.titleMedium!;

    // switch (widget.type) {
    //   case ContractType.sexual:
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
            initialPractices.length,
            (index) {
              final practice = initialPractices[index];

              return practice.buildTile(
                participants,
                onRemove: onRemove,
                showStatusPerPerson: showStatusPerPerson,
                onAcceptOrDeny: onAcceptOrDeny,
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

                      for (final ele in initialPractices) {
                        currentAvailable.remove(ele);
                      }

                      return SingleSelectDialog<SexualPractice>(
                        title: 'Selecione uma prática',
                        getName: (option) => option.name,
                        onChoose: onPick,
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
              // periodicitySelected = value.first;
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
              // periodicitySelected = value.first;
            },
          ),
          const SizedBox(height: 10),
          const Text('Já compartilhou seringas, agulhas ou outros objetos perfurantes?'),
          const _RadioStateful(),
          // Row(
          //   children: [
          //     Expanded(
          //       child: ListTile(
          //         title: const Text('Não'),
          //         leading: _RadioStateful(sharesNeedle: sharesNeedle),
          //       ),
          //     ),
          //     // const Spacer(),
          //     Expanded(
          //       child: ListTile(
          //         title: const Text('Sim'),
          //         leading: Radio(
          //           value: true,
          //           groupValue: sharesNeedle,
          //           onChanged: (value) {
          //             // sharesNeedle = true;
          //           },
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
    //   case ContractType.buyAndSale:
    //     return const SizedBox.shrink();
    // }
  }
}

class _RadioStateful extends StatefulWidget {
  const _RadioStateful({super.key});

  @override
  State<_RadioStateful> createState() => _RadioStatefulState();
}

class _RadioStatefulState extends State<_RadioStateful> {
  bool sharesNeedle = false;

  @override
  Widget build(BuildContext context) {

    return Row(
      children: [
        Expanded(
          child: ListTile(
            title: const Text('Não'),
            leading: Radio(
              value: false,
              groupValue: sharesNeedle,
              onChanged: (value) {
                sharesNeedle = false;
              },
            ),
          ),
        ),
        // const Spacer(),
        Expanded(
          child: ListTile(
            title: const Text('Sim'),
            leading: Radio(
              value: true,
              groupValue: sharesNeedle,
              onChanged: (value) {
                sharesNeedle = true;
                setState(() {

                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
