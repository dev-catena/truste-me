import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/custom_colors.dart';
import '../../../common/domain/entities/person.dart';
import '../../presentation/widgets/components/clause_tile.dart';

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
