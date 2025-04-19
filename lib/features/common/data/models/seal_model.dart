
import '../../domain/entities/seal.dart';

class SealModel extends Seal {
  Seal toEntity() {
    return Seal(
      type: type,
      status: status,
      expiresAt: expiresAt,
      obtainedAt: obtainedAt,
    );
  }

  SealModel.fromJson(Map<String, dynamic> json)
      : super(
    type: SealType.fromString(json['descricao']),
    status: SealStatus.fromString(json['status']),
    expiresAt: DateTime.tryParse(json['expira_em'] ?? ''),
    obtainedAt: DateTime.tryParse(json['obtido_em'] ?? ''),
  );

  const SealModel({
    required super.type,
    required super.status,
    super.obtainedAt,
    super.expiresAt,
  });
}