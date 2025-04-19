import 'package:flutter/material.dart';

import '../../../../common/domain/entities/seal.dart';

class SealsBoard extends StatelessWidget {
  const SealsBoard(this.sealsObtained, {super.key, this.canBuySeal = false});

  final List<Seal> sealsObtained;
  final bool canBuySeal;

  @override
  Widget build(BuildContext context) {
    final titleLarge = Theme.of(context).textTheme.titleLarge!;

    return Column(
      children: [
        Text('Selos', style: titleLarge),
        const SizedBox(height: 4),
        Wrap(
          spacing: 5,
          runSpacing: 5,
          children: List.generate(
            SealType.values.length,
            (index) {
              final type = SealType.values[index];
              final seal = sealsObtained.firstWhere(
                (element) => element.type == type,
                orElse: () {
                  return Seal(type: type, status: SealStatus.absent);
                },
              );

              return seal.buildCard(canBuySeal);
            },
          ),
        )
      ],
    );
  }
}
