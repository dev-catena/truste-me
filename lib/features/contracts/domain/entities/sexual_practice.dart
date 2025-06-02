import 'package:flutter/material.dart';

import '../../../../core/utils/custom_colors.dart';
import '../../../common/domain/entities/person.dart';

class SexualPractice {
  final int id;
  final String description;
  final PracticeStatus status;
  final List<int>? pendingFor;
  final List<int>? acceptedBy;
  final List<int>? deniedBy;

  SexualPractice({
    required this.id,
    required this.description,
    required this.status,
    required this.pendingFor,
    required this.acceptedBy,
    required this.deniedBy,
  });

  SexualPractice copyWith({
    int? id,
    String? description,
    PracticeStatus? status,
    List<int>? pendingFor,
    List<int>? acceptedBy,
    List<int>? deniedBy,
  }) {
    return SexualPractice(
      id: id ?? this.id,
      description: description ?? this.description,
      status: status ?? this.status,
      pendingFor: pendingFor ?? this.pendingFor,
      acceptedBy: acceptedBy ?? this.acceptedBy,
      deniedBy: deniedBy ?? this.deniedBy,
    );
  }

  SexualPractice.fromJson(Map<String, dynamic> json)
      : this(
          id: json['id'],
          description: json['descricao'],
          status: PracticeStatus.byCode(json['status'] ?? 1),
          pendingFor: json['pendente'],
          acceptedBy: json['aceito'],
          deniedBy: json['recusado'],
        );

  Widget buildTile(List<Person> connections) {
    final List<Person> pending = [];
    final List<Person> denied = [];
    final List<Person> accepted = [];

    if(pendingFor != null) {
      for (final ele in pendingFor!) {
        pending.addAll(connections.where((element) => element.id == ele));
      }
    }
    if(acceptedBy != null) {
      for (final ele in acceptedBy!) {
        accepted.addAll(connections.where((element) => element.id == ele));
      }
    }
    if(deniedBy != null) {
      for (final ele in deniedBy!) {
        denied.addAll(connections.where((element) => element.id == ele));
      }
    }

    return Column(
      children: [
        ListTile(
          title: Text(description),
        ),
        ...List.generate(
          pending.length,
          (index) {
            final person = pending[index];
            const status = PracticeStatus.pending;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(person.fullName, textAlign: TextAlign.center),
                status.buildIcon(),
              ],
            );
          },
        ),
      ],
    );
  }
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

  factory PracticeStatus.byCode(int code){
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
