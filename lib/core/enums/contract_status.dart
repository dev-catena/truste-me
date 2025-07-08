import 'dart:ui';

import '../utils/custom_colors.dart';

enum ContractStatus {
  pending(0, 'Pendente', CustomColor.pendingYellow),
  active(1, 'Ativo', CustomColor.activeColor),
  completed(3, 'Concluído', CustomColor.successGreen),
  expired(4, 'Expirado', CustomColor.vividRed);

  final int code;
  final String description;

  final Color color;

  factory ContractStatus.fromString(String json) {
    return ContractStatus.values.firstWhere((element) => element.description == json);
  }

  const ContractStatus(this.code, this.description, this.color);
}
