import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:trustme/core/providers/user_data_cubit.dart';
import 'package:trustme/features/common/domain/entities/seal.dart';

class SealInspectionDialog extends StatefulWidget {
  const SealInspectionDialog(this.seal, {required this.canGetSeal, super.key});

  final Seal seal;
  final bool canGetSeal;

  @override
  State<SealInspectionDialog> createState() => _SealInspectionDialogState();
}

class _SealInspectionDialogState extends State<SealInspectionDialog> {
  bool isProcessing = false;

  String? parseDate(DateTime? date) {
    if (date == null) return null;

    final strDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return strDate;
  }

  void _handleRequestSeal(BuildContext context) {
    setState(() {
      isProcessing = true;
    });
    context.read<UserDataCubit>().requestSeal(widget.seal);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Selo de ${widget.seal.description}', textAlign: TextAlign.center),
      children: [
        Text('Status: ${widget.seal.status.description}', textAlign: TextAlign.center),
        widget.seal.status.buildIcon(),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Obtido em:\n${parseDate(widget.seal.obtainedAt) ?? '-'}', textAlign: TextAlign.center),
            Text('Expira em:\n${parseDate(widget.seal.expiresAt) ?? '-'}', textAlign: TextAlign.center),
          ],
        ),
        const SizedBox(height: 8),
        widget.seal.status != SealStatus.active && widget.canGetSeal
            ? Center(
                child: isProcessing
                    ? const CircularProgressIndicator()
                    : FilledButton(
                        onPressed: () => _handleRequestSeal(context),
                        child: const Text('Obter selo'),
                      ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
