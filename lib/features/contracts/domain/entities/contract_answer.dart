import 'package:equatable/equatable.dart';

class ContractAnswer extends Equatable {
  final int questionId;
  final int userId;
  final String answer;

  const ContractAnswer({required this.questionId, required this.userId, required this.answer});

  @override
  List<Object?> get props => [userId, questionId, answer];

  ContractAnswer.fromJson(Map<String, dynamic> json)
      : this(
          questionId: json['pergunta_id'],
          userId: json['usuario_id'],
          answer: json['resposta'] ?? '',
        );

  Map<String, dynamic> toJson() {
    final content = {
      'pergunta_id': questionId,
      'resposta': answer,
    };

    return content;
  }
}
