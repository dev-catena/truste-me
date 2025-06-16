import 'package:flutter/material.dart';

import '../../../../../core/utils/custom_colors.dart';
import '../../../../common/domain/entities/user.dart';
import '../../../domain/entities/clause.dart';
import 'inspect_clause_dialog.dart';

class ClauseTile extends StatelessWidget {
  const ClauseTile(
    this.clause, {
    required this.participants,
    required this.titlePrefix,
    required this.onRemove,
    required this.onAcceptOrDeny,
    super.key,
  });

  final Clause clause;
  final String titlePrefix;
  final List<User> participants;
  final void Function(Clause clause)? onRemove;
  final void Function(Clause clause, bool value)? onAcceptOrDeny;

  @override
  Widget build(BuildContext context) {
    final titleMedium = Theme.of(context).textTheme.titleMedium!;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!clause.isClauseOk(participants.map((e) => e.id).toList()))
                const Icon(Icons.warning_amber_outlined, color: CustomColor.vividRed),
              // clause.status.buildIcon(),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => showDialog(context: context, builder: (_) => InspectClauseDialog(clause)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$titlePrefix${clause.name}', style: titleMedium),
                      Text(clause.description, maxLines: 2, overflow: TextOverflow.ellipsis)
                    ],
                  ),
                ),
              ),
              if (onRemove != null)
                IconButton(
                  onPressed: () => onRemove!(clause),
                  icon: const Icon(Icons.remove_circle_outline, color: CustomColor.vividRed),
                ),
            ],
          ),
          ...List.generate(
            clause.pendingFor.length,
            (index) {
              final userId = clause.pendingFor[index];
              final user = participants.firstWhere((element) => element.id == userId);

              return ListTile(
                title: Text(user.fullName),
                leading: const Icon(Icons.pending_outlined, color: CustomColor.pendingYellow),
                contentPadding: const EdgeInsets.only(left: 15),
                trailing: onAcceptOrDeny == null
                    ? null
                    : user.id == userLoggedIn.id
                        ? Wrap(
                            spacing: 0,
                            children: [
                              InkWell(
                                onTap: () {
                                  onAcceptOrDeny!(clause, false);
                                },
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.cancel_outlined, color: CustomColor.vividRed),
                                    SizedBox(height: 4),
                                    Text('Recusar', style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  onAcceptOrDeny!(clause, true);
                                },
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_outline, color: CustomColor.successGreen),
                                    SizedBox(height: 4),
                                    Text('Aceitar', style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : null,
              );
            },
          ),
          ...List.generate(
            clause.acceptedBy.length,
            (index) {
              final userId = clause.acceptedBy[index];
              final user = participants.firstWhere((element) => element.id == userId);

              return ListTile(
                title: Text(user.fullName),
                leading: const Icon(Icons.check_circle_outline, color: CustomColor.successGreen),
                contentPadding: const EdgeInsets.only(left: 15),
                trailing: onAcceptOrDeny == null
                    ? null
                    : user.id == userLoggedIn.id
                        ? GestureDetector(
                            onTap: () {
                              onAcceptOrDeny!(clause, false);
                            },
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.cancel_outlined, color: CustomColor.vividRed),
                                SizedBox(height: 4),
                                Text('Recusar', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          )
                        : null,
              );
            },
          ),
          ...List.generate(
            clause.deniedBy.length,
            (index) {
              final userId = clause.deniedBy[index];
              final user = participants.firstWhere((element) => element.id == userId);

              return ListTile(
                title: Text(user.fullName),
                leading: const Icon(Icons.cancel_outlined, color: CustomColor.vividRed),
                contentPadding: const EdgeInsets.only(left: 15),
                trailing: onAcceptOrDeny == null
                    ? null
                    : user.id == userLoggedIn.id
                        ? GestureDetector(
                            onTap: () {
                              onAcceptOrDeny!(clause, true);
                            },
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_outline, color: CustomColor.successGreen),
                                SizedBox(height: 4),
                                Text('Aceitar', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          )
                        : null,
              );
            },
          ),
        ],
      ),
    );
  }
}
