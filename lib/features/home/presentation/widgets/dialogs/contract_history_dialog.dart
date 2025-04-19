import 'package:flutter/material.dart';
// olha o tanto de arquivo kk
class ContractHistoryDialog extends StatelessWidget {
  const ContractHistoryDialog({super.key});

  @override
  Widget build(BuildContext context) {

    // se vc for ver man, n muda muita coisa
    // esse dialog retorna um Dialog, e recebe como parametro esse monte de coisa
    // tudo aquilo são tipos, do flutter
    // QUE FODA................ ISSO É FRONT END? ISSO, deixa eu construir uma coisa aqui rapidao, vc vai ver
    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Histórico de eventos'),
          ),
          SizedBox(
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _MockData().historic.length,
              itemBuilder: (context, index) {
                final action = _MockData().historic[index];

                return ListTile(
                  leading: const Icon(Icons.account_balance),
                  title: Text(action['acao']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MockData {
  final List<Map<String, dynamic>> historic = [
    {
      'acao': 'Aprovação',
    },
    {
      'acao': 'Assinatura',
    },
  ];
}
