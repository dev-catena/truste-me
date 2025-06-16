import 'package:flutter/material.dart';

import '../../../domain/entities/clause.dart';

class InspectClauseDialog extends StatelessWidget {
  const InspectClauseDialog(this.clause, {super.key});
  final Clause clause;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Cláusula de ${clause.name}', textAlign: TextAlign.center),
      contentPadding: const EdgeInsets.all(20),
      children: [
        Text(clause.description),
      ],
    );
  }
}
