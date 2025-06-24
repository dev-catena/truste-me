import 'package:flutter/material.dart';

import '../../../../common/domain/entities/user.dart';
import '../../../domain/entities/clause.dart';

class ClauseSelectionCard extends StatelessWidget {
  const ClauseSelectionCard({
    super.key,
    required this.canEdit,
    required this.contractor,
    required this.stakeHolders,
    required this.possibleClauses,
    required this.clausesChosen,
    required this.onClausePicked,
    required this.onAcceptOrDeny,
    required this.onRemove,
  });

  final bool canEdit;
  final User contractor;
  final List<User> stakeHolders;
  final List<Clause> possibleClauses;
  final List<Clause> clausesChosen;
  final void Function(Clause clause) onClausePicked;
  final void Function(Clause clause, bool value)? onAcceptOrDeny;
  final void Function(Clause clause)? onRemove;

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Cláusulas',
            style: titleMedium.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Entre ${contractor.fullName}, doravante denominada "PARTE A", e ${stakeHolders.isNotEmpty ? stakeHolders[0].fullName : 'NÃO DEFINIDO'}, '
            'doravante denominada "PARTE B", foi acordado o seguinte:',
            textAlign: TextAlign.justify,
          ),
          ...List.generate(
            clausesChosen.length,
            (index) {
              final clause = clausesChosen[index];

              return Column(
                children: [
                  clause.buildTile(
                    titlePrefix: '${clause.code} - ',
                    participants: [contractor, ...stakeHolders],
                    onAcceptOrDeny: canEdit ? onAcceptOrDeny : null,
                    onRemove: canEdit ? onRemove : null,
                  ),
                  if(index < clausesChosen.length -1)
                    const Divider(endIndent: 20, indent: 20),
                ],
              );
            },
          ),
          // if (canEdit)
          //   Center(
          //     child: TextButton(
          //       onPressed: () {
          //         final filteredClauses = List.of(possibleClauses);
          //
          //         for (final ele in clausesChosen) {
          //           filteredClauses.remove(ele);
          //         }
          //
          //         showDialog(
          //             context: context,
          //             builder: (_) {
          //               return SingleSelectDialog<Clause>(
          //                 title: 'Selecione uma clásula',
          //                 getName: (option) => option.name,
          //                 onChoose: onClausePicked,
          //                 options: filteredClauses,
          //                 optionSelected: null,
          //               );
          //             });
          //       },
          //       child: const IntrinsicWidth(
          //         child: Row(
          //           children: [
          //             Icon(Icons.add),
          //             SizedBox(width: 12),
          //             Text('Adicionar cláusula'),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}
