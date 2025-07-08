import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../../core/utils/custom_colors.dart';
import '../../presentation/widgets/components/seal_card.dart';

class Seal extends Equatable {
  final int id;
  final String description;
  final bool available;
  // final SealType type;
  final SealStatus status;
  final DateTime? obtainedAt;
  final DateTime? expiresAt;

  @override
  List<Object?> get props => [id, description, status];

  SealCard buildCard(bool canGet) {
    return SealCard(this, canGetSeal: canGet);
  }

  const Seal({
    required this.id,
    required this.description,
    required this.available,
    required this.status,
    required this.obtainedAt,
    required this.expiresAt,
  });
}

enum SealStatus {
  absent('Ausente', CustomColor.activeGreyed, Icons.cancel_outlined),
  pending('Em validação', CustomColor.pendingYellow, Icons.pending_outlined),
  active('Ativo', CustomColor.activeColor, Icons.check_circle_outline),
  upComing('Indisponível', CustomColor.activeColor, Icons.upcoming_outlined),
  expired('Expirado', CustomColor.activeGreyed, Symbols.running_with_errors);

  final String description;
  final Color color;
  final IconData icon;

  factory SealStatus.fromString(final String value) {
    return SealStatus.values.firstWhere((element) => element.description == value);
  }

  Widget buildIcon() {
    return Icon(icon, color: color);
  }

  const SealStatus(this.description, this.color, this.icon);
}
