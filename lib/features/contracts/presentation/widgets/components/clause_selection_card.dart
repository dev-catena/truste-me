import 'package:flutter/material.dart';

import '../../../../common/domain/entities/person.dart';
import '../../../../common/presentation/widgets/dialogs/single_select_dialog.dart';
import '../../../domain/entities/clause.dart';

class ClauseSelectionCard extends StatelessWidget {
  const ClauseSelectionCard({
    super.key,
    required this.contractor,
    required this.stakeHolder,
    required this.possibleClauses,
    required this.clausesChosen,
    required this.onClausePicked,
  });

  final Person contractor;
  final Person? stakeHolder;
  final List<Clause> possibleClauses;
  final List<Clause> clausesChosen;
  final void Function(Clause clause) onClausePicked;

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
            'Entre ${contractor.fullName}, doravante denominada "PARTE A", e ${stakeHolder?.fullName ?? 'NÃO DEFINIDO'}, '
            'doravante denominada "PARTE B", foi acordado o seguinte:',
            textAlign: TextAlign.justify,
          ),
          ...List.generate(
            clausesChosen.length,
            (index) {
              final clause = clausesChosen[index];

              return clause.buildTile('${clause.code} - ');
            },
          ),
          Center(
            child: TextButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (_) {
                      return SingleSelectDialog<Clause>(
                        title: 'Selecione uma clásula',
                        getName: (option) => option.name,
                        onChoose: onClausePicked,
                        options: possibleClauses,
                        optionSelected: null,
                      );
                    });
              },
              child: const IntrinsicWidth(
                child: Row(
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 12),
                    Text('Adicionar cláusula'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
