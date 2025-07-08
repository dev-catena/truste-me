import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/providers/app_data_cubit.dart';
import '../../../../common/domain/entities/seal.dart';

class SealsBoard extends StatelessWidget {
  const SealsBoard(this._sealsObtained, {super.key, required this.canGetSeal});

  final List<Seal> _sealsObtained;
  final bool canGetSeal;

  @override
  Widget build(BuildContext context) {
    final titleLarge = Theme.of(context).textTheme.titleLarge!;
    final appData = context.read<AppDataCubit>();
    final systemSeals = appData.getSeals;
    final userSealsById = {for (var s in _sealsObtained) s.id: s};

    // Replace system seal with user seal if user has it
    final mergedSeals = systemSeals.map((seal) {
      return userSealsById[seal.id] ?? seal;
    }).toList();

    return Column(
      children: [
        Text('Selos', style: titleLarge),
        const SizedBox(height: 4),
        Wrap(
          spacing: 5,
          runSpacing: 5,
          children: List.generate(
            mergedSeals.length,
            (index) {
              final seal = mergedSeals[index];

              return seal.buildCard(canGetSeal);
            },
          ),
        ),
      ],
    );
  }
}
