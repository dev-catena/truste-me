import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/custom_colors.dart';
import '../../../common/domain/entities/user.dart';
import '../../../common/presentation/widgets/components/stateful_segmented_button.dart';
import '../../presentation/widgets/components/clause_tile.dart';
import 'contract_answer.dart';

class Clause extends Equatable {
  final int id;
  final String name;
  final String code;
  final String description;
  final List<int> pendingFor;
  final List<int> acceptedBy;
  final List<int> deniedBy;

  bool isClauseOk(List<int> participantsId) {
    final accepted = acceptedBy.toSet();
    final denied = deniedBy.toSet();

    final isClauseOk = (accepted.containsAll(participantsId) && denied.isEmpty) ||
        (denied.containsAll(participantsId) && accepted.isEmpty);

    return isClauseOk;
  }

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
    required List<User> participants,
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
    List<ContractQuestion>? questions,
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

class ContractQuestion extends Equatable {
  final int id;
  final String description;
  final List<String> alternatives;
  final QuestionType answerType;

  const ContractQuestion({
    required this.id,
    required this.description,
    required this.alternatives,
    required this.answerType,
  });

  ContractQuestion.fromJson(Map<String, dynamic> json)
      : this(
          id: json['id'],
          description: json['descricao'],
          alternatives: List<String>.from(jsonDecode(json['alternativas'])),
          answerType: QuestionType.fromString(json['tipo_alternativa']),
        );

  @override
  List<Object?> get props => [id, description];

  Widget buildTileWithAnswer(
    int index,
    List<User> participants,
    List<ContractAnswer> answers, {
    required final void Function(ContractQuestion question, String answer) onAnswered,
  }) {
    Widget buildAnswerField() {
      final List<Widget> fields = [];

      if (participants.isEmpty) {
        return const SizedBox();
      } else {
        for (final ele in participants) {
          final ContractAnswer currentAnswer =
              answers.firstWhere((element) => element.questionId == id && ele.id == element.userId);

          switch (answerType) {
            case QuestionType.select:
              fields.add(
                Column(
                  children: [
                    Text('${ele.fullName}:', style: const TextStyle(fontWeight: FontWeight.bold)),
                    StatefulSegmentedButton<String>(
                      getLabel: (value) => value,
                      getValue: (value) => value,
                      onChanged: (value) {
                        onAnswered(this, value.first);
                      },
                      enabled: ele.id == userLoggedIn.id,
                      initialSelection: {currentAnswer.answer},
                      options: alternatives,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
              break;
            case QuestionType.boolean:
              fields.add(
                Column(
                  children: [
                    Text('${ele.fullName}:', style: const TextStyle(fontWeight: FontWeight.bold)),
                    _RadioStateful<String>(
                      enabled: ele.id == userLoggedIn.id,
                      getValue: (value) => value,
                      getLabel: (value) => value,
                      options: alternatives,
                      onChanged: (value) {
                        onAnswered(this, value);
                      },
                      initialSelection: currentAnswer.answer,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
              break;
            case QuestionType.input:
              fields.add(const Text('Resposta tipo input'));
              break;
          }
        }
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: Column(
          children: fields,
        ),
      );
    }

    return Column(
      children: [
        Text('$index - $description'),
        buildAnswerField(),
      ],
    );
  }
}

enum QuestionType {
  select('select'),
  boolean('radio'),
  input('input');

  final String description;

  const QuestionType(this.description);

  factory QuestionType.fromString(String value) {
    return QuestionType.values.firstWhere((element) => element.description == value);
  }
}

class _RadioStateful<T> extends StatelessWidget {
  const _RadioStateful({
    super.key,
    required this.options,
    this.initialSelection,
    required this.enabled,
    required this.getLabel,
    required this.getValue,
    required this.onChanged,
  });

  final List<T> options;
  final T? initialSelection;
  final bool enabled;
  final String Function(T value) getLabel;
  final T Function(T value) getValue;
  final void Function(T value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(
        options.length,
        (index) {
          final option = options[index];
          return Row(
            children: [
              Radio<T>(
                value: option,
                groupValue: initialSelection,
                onChanged: enabled ? (value) => onChanged(value as T) : null,
              ),
              Text(getLabel(option)),
            ],
          );
        },
      ),
    );
  }
}
