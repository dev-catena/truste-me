import '../../domain/entities/seal.dart';

class SealModel extends Seal {
  Seal toEntity() {
    return Seal(
      id: id,
      description: description,
      available: available,
      status: status,
      expiresAt: expiresAt,
      obtainedAt: obtainedAt,
    );
  }

  factory SealModel.fromJson(Map<String, dynamic> json) {
    bool isAvailable() {
      if (json['selo'] != null) {
        if (json['selo']['disponivel'] == 1) {
          return true;
        } else if (json['selo']['disponivel'] == 0) {
          return false;
        } else {
          throw Exception('Null value!');
        }
      } else if (json['disponivel'] != null) {
        if (json['disponivel'] == 1) {
          return true;
        } else if (json['disponivel'] == 0) {
          return false;
        } else {
          throw Exception('Null value!');
        }
      } else {
        throw Exception('Null value!');
      }
    }

    return SealModel(
      id: json['selo']?['id'] ?? json['id'],
      description: json['selo']?['descricao'] ?? json['descricao'],
      available: isAvailable(),
      // type: SealType.fromString(json['descricao']),
      // status: json['verificado'] == true ? SealStatus.active : SealStatus.upComing,
      status: SealStatus.fromString(json['status']),
      expiresAt: DateTime.tryParse(json['expira_em'] ?? ''),
      obtainedAt: DateTime.tryParse(json['obtido_em'] ?? ''),
    );
  }

  const SealModel({
    required super.id,
    required super.description,
    required super.available,
    required super.status,
    super.obtainedAt,
    super.expiresAt,
  });
}
