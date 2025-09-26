part of '../register_screen.dart';

class _PasswordCreation extends StatelessWidget {
  const _PasswordCreation({
    required this.onPasswordSet,
    required this.onPasswordConfirmSet,
  });

  final ValueChanged<String> onPasswordSet;
  final ValueChanged<String> onPasswordConfirmSet;

  static const DEF_PASSWORD_LENGTH = 6;

  @override
  Widget build(BuildContext context) {
    final titleLarge = Theme.of(context).textTheme.titleLarge!;

    return Column(
      children: [
        Text('Senha', style: titleLarge),
        const SizedBox(height: 16),
        const Text('A senha deve conter pelo menos $DEF_PASSWORD_LENGTH caracteres'),
        const SizedBox(height: 8),
        TextField(
          onChanged: onPasswordSet,
          decoration: const InputDecoration(
            labelText: 'Senha',
            border: OutlineInputBorder(),
          ),
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          onSubmitted: (_) => FocusScope.of(context).unfocus(),
          onEditingComplete: () => FocusScope.of(context).unfocus(),
        ),
        const SizedBox(height: 16),
        TextField(
          onChanged: onPasswordConfirmSet,
          decoration: const InputDecoration(
            labelText: 'Confirme a senha',
            border: OutlineInputBorder(),
          ),
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          onSubmitted: (_) => FocusScope.of(context).unfocus(),
          onEditingComplete: () => FocusScope.of(context).unfocus(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
