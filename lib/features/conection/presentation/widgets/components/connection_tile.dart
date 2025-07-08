import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/routes.dart';
import '../../../../../core/utils/date_parser.dart';
import '../../../../common/domain/entities/user.dart';
import '../../../domain/entities/connection.dart';

class ConnectionTile extends StatelessWidget {
  ConnectionTile(this.connection, {super.key});

  final Connection connection;
  late final User user = connection.user;

  @override
  Widget build(BuildContext context) {
    final titleMedium = Theme.of(context).textTheme.titleMedium!;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // if(connection.status.description == 'Aguardando aceitação') return;
          context.pushNamed(AppRoutes.connectionDetailScreen, extra: connection);
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: connection.status.color),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              user.buildAvatar(),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.fullName, style: titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      '${connection.status.description} desde ${DateParser.formatDate(connection.since, true)}',
                      // connection.since.toLocal().toString(),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
