import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RequestConnectionDialog extends StatelessWidget {
  RequestConnectionDialog({
    super.key,
    required this.onRequested,
  });

  final void Function(int code) onRequested;
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Insira o código de conexão'),
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            keyboardType: TextInputType.number,
            controller: controller,
            maxLength: 7,
            decoration: const InputDecoration(
              label: Text('Código'),
              hintText: '0000000',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        OutlinedButton(onPressed: () => context.pop(), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () {
            if (controller.text.length != 7) {
              return;
            } else {
              onRequested(int.parse(controller.text));
              context.pop();
            }
          },
          child: const Text('Solicitar'),
        ),
      ],
    );
  }
}
