import 'package:flutter/material.dart';

import '../../../../../core/utils/custom_colors.dart';
import '../../../domain/entities/seal.dart';
import '../dialogs/seal_inspection_dialog.dart';

class SealCard extends StatelessWidget {
  const SealCard(this.seal, {required this.canGetSeal, super.key});

  final Seal seal;
  final bool canGetSeal;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if(seal.id != 1) return;
          showDialog(context: context, builder: (_) => SealInspectionDialog(seal, canGetSeal: canGetSeal));
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 90,
          width: size.width * 0.28,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const SizedBox(height: 6),
              Text(seal.description),
              const SizedBox(height: 10),
              if (!seal.available)
                Container(
                  color: CustomColor.activeColor,
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Em breve',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              else
                seal.status.buildIcon(),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}
