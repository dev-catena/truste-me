import 'package:flutter/material.dart';

import '../../../domain/entities/seal.dart';
import '../dialogs/seal_inspection_dialog.dart';

class SealCard extends StatelessWidget {
  const SealCard(this.seal, {super.key, this.showButton = false});

  final bool showButton;
  final Seal seal;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showDialog(context: context, builder: (_) => SealInspectionDialog(seal, canBuy: showButton));
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 70,
          width: size.width *0.28,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const SizedBox(height: 6),
              Text(seal.type.description),
              const SizedBox(height: 10),
              seal.status.buildIcon(),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}
