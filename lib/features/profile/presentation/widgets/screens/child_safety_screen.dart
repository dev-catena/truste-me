import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trustme/features/common/presentation/widgets/components/custom_scaffold.dart';

class ChildSafetyScreen extends StatelessWidget {
  const ChildSafetyScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _sendEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'suporte@catenasystema.com.br',
      query: 'subject=Denúncia de conteúdo impróprio',
    );
    if (!await launchUrl(emailLaunchUri)) {
      throw Exception('Could not launch email client');
    }
  }

  @override
  Widget build(BuildContext context) {
    final headlineSmall = Theme.of(context).textTheme.headlineSmall!;
    final titleMedium = Theme.of(context).textTheme.titleMedium!;

    return CustomScaffold(
      showAvatar: false,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Segurança Infantil',
              style: headlineSmall,
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _launchUrl('https://rdd2.github.io/true-connect/seguranca-infantil.html'),
              child: Card(
                child: ListTile(
                  title: const Text(
                    'Ver padrões de segurança infantil',
                    style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('(Toque aqui para ver)', style: TextStyle(fontSize: 14),),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Denunciar conteúdo impróprio ou abuso infantil',
              style: titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Se você encontrar qualquer comportamento suspeito, conteúdo inadequado ou possível abuso/exploração infantil (CSAM), denuncie imediatamente.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),
            Text(
              'Enviar denúncia por e-mail:',
              style: titleMedium,
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _sendEmail,
              child: Card(
                child: ListTile(
                  title: Text(
                    'suporte@catenasystema.com.br',
                    style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('(Toque aqui para abrir o e-mail)', style: TextStyle(fontSize: 14),),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Como tratamos denúncias', style: titleMedium,
            ),
            const SizedBox(height: 8),
            Text('As denúncias são analisadas imediatamente. Caso seja encontrado material ilegal ou suspeito, notificamos as autoridades competentes conforme exigido pelas leis locais e políticas da ${Platform.isAndroid ? 'Google Play' : 'Apple AppStore'}.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
