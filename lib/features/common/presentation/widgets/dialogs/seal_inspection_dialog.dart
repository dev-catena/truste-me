import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trustme/core/extensions/context_extensions.dart';
import 'package:trustme/core/utils/http/custom_http_error.dart';
import 'package:trustme/features/common/data/data_source/seal_data_source.dart';
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

  // FIXME: catch errors properly
  Future<void> requestSeal() async {
    isProcessing = true;
    setState(() {});

    try {
      final resp = await SealDataSource().requestSeal(widget.seal);

      final String message;
      if(resp.containsKey('error')){
        message = 'Erro ao solicitar selo! ${resp['error']}';
      } else {
        message = '${resp['message']} Verifique sua caixa de entrada.';
      }

      context.pop();
      context.showSnack(message);
    } on HttpRequestException catch (e, s) {
      context.pop();
      context.showSnack(e.message);
    } on Exception catch(e, s) {
      context.pop();
      context.showSnack('Erro ao solicitar selo! ${e.toString()}');
    } finally {
      isProcessing = false;
      setState(() {});
    }
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
                        onPressed: () {
                          if (widget.seal.id == 1) {
                            requestSeal();
                          }
                        },
                        child: const Text('Obter selo'),
                      ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
