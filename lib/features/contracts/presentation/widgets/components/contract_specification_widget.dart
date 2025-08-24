import 'package:flutter/material.dart';

import '../../../../common/domain/entities/user.dart';
import '../../../domain/entities/clause.dart';
import '../../../domain/entities/contract_answer.dart';
import '../../../domain/entities/contract_type.dart';
import '../../../domain/entities/sexual_practice.dart';

class ContractSpecificationWidget extends StatelessWidget {
  const ContractSpecificationWidget({
    required this.canEdit,
    required this.type,
    required this.practicesAvailable,
    required this.initialPractices,
    required this.participants,
    required this.showStatusPerUser,
    required this.answers,
    required this.onPick,
    required this.onRemove,
    required this.onAcceptOrDeny,
    required this.onQuestionAnswered,
    super.key,
    required,
  });

  final bool canEdit;
  final ContractType type;
  final List<SexualPractice> practicesAvailable;
  final List<SexualPractice> initialPractices;
  final List<ContractAnswer> answers;
  final List<User> participants;
  final bool showStatusPerUser;
  final ValueChanged<SexualPractice> onPick;
  final ValueChanged<SexualPractice>? onRemove;
  final void Function(SexualPractice practice, bool hasAccepted)? onAcceptOrDeny;
  final void Function(ContractQuestion question, String answer) onQuestionAnswered;

  final bool sharesNeedle = false;

  final String periodicitySelected = 'Nunca';

// final List<SexualPractice> internTaken = [];

  @override
  Widget build(BuildContext context) {
    final titleMedium = Theme.of(context).textTheme.titleMedium!;

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
              final number = (index + 1).toString().padLeft(4, '0');
              final titlePrefix = 'PSX$number - ';

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  practice.buildTile(
                    participants,
                    titlePrefix: titlePrefix,
                    onRemove: canEdit ? onRemove : null,
                    showStatusPerUser: showStatusPerUser,
                    onAcceptOrDeny: canEdit ? onAcceptOrDeny : null,
                  ),
                  const Divider(endIndent: 20, indent: 20),
                ],
              );
            },
          ),
          // if (canEdit)
          //   Center(
          //     child: TextButton(
          //       onPressed: () {
          //         showDialog(
          //             context: context,
          //             builder: (_) {
          //               final currentAvailable = List.of(practicesAvailable);
          //
          //               for (final ele in initialPractices) {
          //                 currentAvailable.remove(ele);
          //               }
          //
          //               return SingleSelectDialog<SexualPractice>(
          //                 title: 'Selecione uma prática',
          //                 getName: (option) => option.name,
          //                 onChoose: onPick,
          //                 options: currentAvailable,
          //                 optionSelected: null,
          //               );
          //             });
          //       },
          //       child: const IntrinsicWidth(
          //         child: Row(
          //           children: [
          //             Icon(Icons.add),
          //             SizedBox(width: 12),
          //             Text('Adicionar prática'),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          const SizedBox(height: 10),
          ...List.generate(
            type.questions.length,
            (index) {
              final question = type.questions[index];

              return question.buildTileWithAnswer(
                index + 1,
                participants,
                answers,
                onAnswered: onQuestionAnswered,
              );
              // return Text(question.description);
            },
          ),
          // const Text('Com que frequência você realiza as práticas que foram aceitas?'),
          // StatefulSegmentedButton<String>(
          //   options: const ['Nunca', 'As vezes', 'Frequentemente', 'Sempre'],
          //   getLabel: (value) => value,
          //   getValue: (value) => value,
          //   initialSelection: {periodicitySelected},
          //   onChanged: (value) {
          //     // periodicitySelected = value.first;
          //   },
          // ),
          // const SizedBox(height: 10),
          // const Text('Você costuma usar preservativo nas práticas sexuais?'),
          // StatefulSegmentedButton<String>(
          //   options: const ['Nunca', 'As vezes', 'Frequentemente', 'Sempre'],
          //   getLabel: (value) => value,
          //   getValue: (value) => value,
          //   initialSelection: {periodicitySelected},
          //   onChanged: (value) {
          //     // periodicitySelected = value.first;
          //   },
          // ),
          // const SizedBox(height: 10),
          // const Text('Já compartilhou seringas, agulhas ou outros objetos perfurantes?'),
          // const _RadioStateful(),
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
  }
}