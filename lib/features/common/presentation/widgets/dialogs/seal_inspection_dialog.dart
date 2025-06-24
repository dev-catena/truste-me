import 'package:flutter/material.dart';

import '../../../domain/entities/seal.dart';

class SealInspectionDialog extends StatelessWidget {
  const SealInspectionDialog(this.seal, {super.key, this.canBuy = false});

  final Seal seal;
  final bool canBuy;

  String? parseDate(DateTime? date) {
    if (date == null) return null;

    final strDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return strDate;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Selo de ${seal.type.description}', textAlign: TextAlign.center),
      children: [
        Text('Status: ${seal.status.description}', textAlign: TextAlign.center),
        seal.status.buildIcon(),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Obtido em:\n${parseDate(seal.obtainedAt) ?? '-'}', textAlign: TextAlign.center),
            Text('Expira em:\n${parseDate(seal.expiresAt) ?? '-'}', textAlign: TextAlign.center),
          ],
        ),
        const SizedBox(height: 8),
        canBuy
            ? Center(
                child: FilledButton(
                  onPressed: () {},
                  child: const Text('Obter selo'),
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
