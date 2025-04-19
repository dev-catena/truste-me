part of '../register_screen.dart';

class _PasswordCreation extends StatelessWidget {
  const _PasswordCreation({
    required this.onPasswordSet,
    required this.onPasswordConfirmSet,
  });

  final ValueChanged<String> onPasswordSet;
  final ValueChanged<String> onPasswordConfirmSet;

  @override
  Widget build(BuildContext context) {
    final titleLarge = Theme.of(context).textTheme.titleLarge!;

    return Column(
      children: [
        Text('Senha', style: titleLarge),
        const SizedBox(height: 16),
        TextField(
          onChanged: onPasswordSet,
          decoration: const InputDecoration(
            labelText: 'Senha',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          onChanged: onPasswordConfirmSet,
          decoration: const InputDecoration(
            labelText: 'Confirme a senha',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
