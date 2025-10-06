import 'package:flutter/material.dart';

class AgeConfirmation extends StatelessWidget {
  const AgeConfirmation({super.key});

  @override
  Widget build(BuildContext context) {
    final title = Theme.of(context).textTheme.bodyLarge!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Este aplicativo é destinado a pessoas maiores de 18 anos. '
          'Ao continuar você confirma que possui idade igual ou superior a 18 anos.',
          textAlign: TextAlign.center,
          style: title,
        ),
      ],
    );
  }
}
