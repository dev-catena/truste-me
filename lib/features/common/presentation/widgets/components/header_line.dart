
import 'package:flutter/material.dart';

class HeaderLine extends StatelessWidget {
  const HeaderLine(this.title, this.icon, {super.key});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final headlineSmall = Theme.of(context).textTheme.headlineSmall!;

    return Row(
      children: [
        Icon(icon, size: 35),
        const SizedBox(width: 12),
        Text(title, style: headlineSmall),
      ],
    );
  }
}