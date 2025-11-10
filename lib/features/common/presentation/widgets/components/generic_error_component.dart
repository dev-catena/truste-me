import 'package:flutter/material.dart';

class GenericErrorComponent extends StatelessWidget {
  const GenericErrorComponent(this.message, {required this.onRefresh, super.key});

  final String message;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 16,),
            const Text('Ocorreu um erro!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
            SizedBox(height: 16,),
            Text(message, textAlign: TextAlign.center),
            IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }
}
