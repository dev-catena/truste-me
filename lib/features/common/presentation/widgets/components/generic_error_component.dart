import 'package:flutter/material.dart';

class GenericErrorComponent extends StatelessWidget {
  const GenericErrorComponent(this.message, {required this.onRefresh, super.key});

  final String message;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text('Ocorreu um erro!', textAlign: TextAlign.center),
          Text(message, textAlign: TextAlign.center),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
