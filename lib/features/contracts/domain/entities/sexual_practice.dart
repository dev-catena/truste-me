import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/custom_colors.dart';
import '../../../common/domain/entities/user.dart';
import 'clause.dart';

class SexualPractice extends Equatable {
  final int id;
  final String code;
  final String name;
  final PracticeStatus status;
  final List<int>? pendingFor;
  final List<int>? acceptedBy;
  final List<int>? deniedBy;

  Clause toClause() {
    return Clause(
      id: id,
      code: code,
      description: '',
      name: name,
      pendingFor: pendingFor ?? [],
      acceptedBy: acceptedBy ?? [],
      deniedBy: deniedBy ?? [],
    );
  }

  const SexualPractice({
    required this.id,
    required this.code,
    required this.name,
    required this.status,
    required this.pendingFor,
    required this.acceptedBy,
    required this.deniedBy,
  });

  SexualPractice copyWith({
    int? id,
    String? name,
    String? code,
    PracticeStatus? status,
    List<ContractQuestion>? questions,
    List<int>? pendingFor,
    List<int>? acceptedBy,
    List<int>? deniedBy,
  }) {
    return SexualPractice(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      status: status ?? this.status,
      pendingFor: pendingFor ?? this.pendingFor,
      acceptedBy: acceptedBy ?? this.acceptedBy,
      deniedBy: deniedBy ?? this.deniedBy,
    );
  }

  bool isPracticeOk(List<int> participantsId) {
    final accepted = acceptedBy?.toSet() ?? {};
    final denied = deniedBy?.toSet() ?? {};

    final isClauseOk = (accepted.containsAll(participantsId) && denied.isEmpty) ||
        (denied.containsAll(participantsId) && accepted.isEmpty);

    return isClauseOk;
  }

  SexualPractice.fromJson(Map<String, dynamic> json)
      : this(
          id: json['id'],
          name: json['nome'],
          code: json['codigo'],
          status: PracticeStatus.byCode(json['status'] ?? 1),
          pendingFor: (json['pendente_para'] as List?)?.cast<int>(),
          acceptedBy: (json['aceito_por'] as List?)?.cast<int>(),
          deniedBy: (json['recusado_por'] as List?)?.cast<int>(),
        );

  Widget buildTile(
    List<User> connections, {
    required bool showStatusPerUser,
    required ValueChanged<SexualPractice>? onRemove,
    required void Function(SexualPractice clause, bool value)? onAcceptOrDeny,
  }) {
    final List<User> pending = [];
    final List<User> denied = [];
    final List<User> accepted = [];

    if (pendingFor != null) {
      for (final ele in pendingFor!) {
        pending.addAll(connections.where((element) => element.id == ele));
      }
    }
    if (acceptedBy != null) {
      for (final ele in acceptedBy!) {
        accepted.addAll(connections.where((element) => element.id == ele));
      }
    }
    if (deniedBy != null) {
      for (final ele in deniedBy!) {
        denied.addAll(connections.where((element) => element.id == ele));
      }
    }

    return Column(
      children: [
        ListTile(
          title: Text('$code - $name'),
          leading: !isPracticeOk(connections.map((e) => e.id).toList())
              ? const Icon(Icons.warning_amber_outlined, color: CustomColor.vividRed)
              : null,
          trailing: onRemove != null
              ? IconButton(
                  onPressed: () {
                    onRemove(this);
                  },
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: CustomColor.vividRed,
                  ),
                )
              : null,
        ),
        if (showStatusPerUser) ...[
          ...List.generate(
            pending.length,
            (index) {
              final user = pending[index];

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
                                  onAcceptOrDeny(this, false);
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
                                  onAcceptOrDeny(this, true);
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
            accepted.length,
            (index) {
              final user = accepted[index];

              return ListTile(
                title: Text(user.fullName),
                leading: const Icon(Icons.check_circle_outline, color: CustomColor.successGreen),
                contentPadding: const EdgeInsets.only(left: 15),
                trailing: onAcceptOrDeny == null
                    ? null
                    : user.id == userLoggedIn.id
                        ? GestureDetector(
                            onTap: () {
                              onAcceptOrDeny(this, false);
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
            denied.length,
            (index) {
              final user = denied[index];

              return ListTile(
                title: Text(user.fullName),
                leading: const Icon(Icons.cancel_outlined, color: CustomColor.vividRed),
                contentPadding: const EdgeInsets.only(left: 15),
                trailing: onAcceptOrDeny == null
                    ? null
                    : user.id == userLoggedIn.id
                        ? GestureDetector(
                            onTap: () {
                              onAcceptOrDeny(this, true);
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
      ],
    );
  }

  @override
  List<Object?> get props => [id, name, ];
}

enum PracticeStatus {
  pending(
    1,
    'Pendente',
    Icon(Icons.pending_outlined, color: CustomColor.pendingYellow),
  ),
  accepted(2, 'Aceito', Icon(Icons.check_circle_outline, color: CustomColor.successGreen)),
  denied(3, 'Recusado', Icon(Icons.cancel_outlined, color: CustomColor.vividRed));

  final int code;
  final String description;
  final Icon icon;

  const PracticeStatus(this.code, this.description, this.icon);

  factory PracticeStatus.byCode(int code) {
    return PracticeStatus.values.firstWhere((element) => element.code == code);
  }

  Widget buildIcon() {
    return Column(
      children: [
        Text(description),
        icon,
      ],
    );
  }
}

class ClauseAndPractice {
  final List<Clause> clauses;
  final List<SexualPractice> practices;

  ClauseAndPractice(this.clauses, this.practices);
}
