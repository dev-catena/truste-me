import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/custom_colors.dart';

class Clause extends Equatable {
  final int id;
  final String name;
  final String code;
  final String description;
  final ClauseStatus status;

  const Clause({
    required this.id,
    required this.code,
    required this.description,
    required this.name,
    this.status = ClauseStatus.pending,
  });

  @override
  List<Object?> get props => [id, description, code, name];

  ClauseTile buildTile([String? titlePrefix]) {
    return ClauseTile(this, titlePrefix: titlePrefix);
  }

  Clause copyWith({
    int? id,
    String? name,
    String? code,
    String? description,
    ClauseStatus? status,
  }) {
    return Clause(
      id: id ?? this.id,
      code: code ?? this.code,
      description: description ?? this.description,
      name: name ?? this.name,
      status: status ?? this.status,
    );
  }
}

class ClauseModel extends Clause {
  Clause toEntity() {
    return Clause(id: id, description: description, name: name, status: status, code: code);
  }

  ClauseModel.fromJson(Map<String, dynamic> json)
      : super(
          id: json['id'] ?? json['clausula_id'],
          name: json['nome'],
          code: json['codigo'],
          description: json['descricao'],
          status: ClauseStatus.byStatusCode(json['status'] ?? 3),
        );

  const ClauseModel({required super.id, required super.code, required super.description, required super.name, required super.status});
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
  const ClauseTile(this.clause, {this.titlePrefix, super.key});

  final Clause clause;
  final String? titlePrefix;

  @override
  Widget build(BuildContext context) {
    final titleMedium = Theme.of(context).textTheme.titleMedium!;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          clause.status.buildIcon(),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${titlePrefix ?? ''}${clause.name}', style: titleMedium),
                Text(clause.description, maxLines: 2, overflow: TextOverflow.ellipsis)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
