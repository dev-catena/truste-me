import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/custom_colors.dart';
import '../../../common/domain/entities/person.dart';

class Clause extends Equatable {
  final int id;
  final String name;
  final String code;
  final String description;
  final List<int> pendingFor;
  final List<int> acceptedBy;
  final List<int> deniedBy;

  const Clause({
    required this.id,
    required this.code,
    required this.description,
    required this.name,
    required this.pendingFor,
    required this.acceptedBy,
    required this.deniedBy,
  });

  @override
  List<Object?> get props => [id, description, code, name];

  ClauseTile buildTile({
    String titlePrefix = '',
    required List<Person> participants,
    required void Function(Clause clause, bool value)? onAcceptOrDeny,
    required void Function(Clause clause)? onRemove,
  }) {
    return ClauseTile(
      this,
      titlePrefix: titlePrefix,
      participants: participants,
      onAcceptOrDeny: onAcceptOrDeny,
      onRemove: onRemove,
    );
  }

  Clause copyWith({
    int? id,
    String? name,
    String? code,
    String? description,
    List<int>? pendingFor,
    List<int>? acceptedBy,
    List<int>? deniedBy,
  }) {
    return Clause(
      id: id ?? this.id,
      code: code ?? this.code,
      description: description ?? this.description,
      name: name ?? this.name,
      pendingFor: pendingFor ?? this.pendingFor,
      acceptedBy: acceptedBy ?? this.acceptedBy,
      deniedBy: deniedBy ?? this.deniedBy,
    );
  }
}

class ClauseModel extends Clause {
  Clause toEntity() {
    return Clause(
      id: id,
      description: description,
      name: name,
      code: code,
      pendingFor: pendingFor,
      acceptedBy: acceptedBy,
      deniedBy: deniedBy,
    );
  }

  ClauseModel.fromJson(Map<String, dynamic> json)
      : super(
          id: json['id'] ?? json['clausula_id'],
          name: json['nome'],
          code: json['codigo'],
          description: json['descricao'],
          pendingFor: (json['pendente_para'] as List?)?.cast<int>() ?? [],
          acceptedBy: (json['aceito_por'] as List?)?.cast<int>() ?? [],
          deniedBy: (json['recusado_por'] as List?)?.cast<int>() ?? [],
        );

  const ClauseModel({
    required super.id,
    required super.code,
    required super.description,
    required super.name,
    required super.pendingFor,
    required super.acceptedBy,
    required super.deniedBy,
  });
}

enum ClauseStatus {
  approved(1, 'Aprovada', Icons.check_circle_outline, CustomColor.successGreen),
  denied(2, 'Recusada', Icons.cancel_outlined, CustomColor.vividRed),
  pending(3, 'Pendente', Icons.pending_outlined, CustomColor.pendingYellow),
  undefined(99, 'Indefinido', Icons.question_mark, CustomColor.pendingYellow);

  final int statusCode;
  final String description;
  final IconData icon;
  final Color color;

  const ClauseStatus(this.statusCode, this.description, this.icon, this.color);

  factory ClauseStatus.byStatusCode(int id) {
    return ClauseStatus.values.firstWhere(
      (element) => element.statusCode == id,
      orElse: () => ClauseStatus.undefined,
    );
  }

  Icon buildIcon() {
    return Icon(icon, color: color);
  }
}

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
  final List<Person> participants;
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
              // clause.status.buildIcon(),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$titlePrefix${clause.name}', style: titleMedium),
                    Text(clause.description, maxLines: 2, overflow: TextOverflow.ellipsis)
                  ],
                ),
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
                trailing: onRemove != null
                    ? IconButton(
                        onPressed: () => onRemove!(clause),
                        icon: const Icon(Icons.remove_circle_outline, color: CustomColor.vividRed),
                      )
                    : user.id == userLoggedIn.id
                        ? Wrap(
                            spacing: 0,
                            children: [
                              IconButton(
                                onPressed: () {
                                  onAcceptOrDeny!(clause, false);
                                },
                                icon: const Icon(Icons.cancel_outlined, color: CustomColor.vividRed),
                              ),
                              IconButton(
                                onPressed: () {
                                  onAcceptOrDeny!(clause, true);
                                },
                                icon: const Icon(Icons.check_circle_outline, color: CustomColor.successGreen),
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
                trailing: user.id == userLoggedIn.id
                    ? IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.cancel_outlined, color: CustomColor.vividRed),
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
