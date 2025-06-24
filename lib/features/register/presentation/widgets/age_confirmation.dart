part of '../register_screen.dart';

class _AgeConfirmation extends StatelessWidget {
  const _AgeConfirmation();

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
