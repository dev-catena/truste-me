class ContractSignature {
  final int userId;
  final DateTime? dateTime;
  final bool hasAccepted;

  ContractSignature({
    required this.userId,
    required this.dateTime,
    required this.hasAccepted,
  });

  ContractSignature.fromJson(Map<String, dynamic> json)
      : this(
          userId: json['usuario_id'],
          dateTime: DateTime.tryParse(json['dt_aceito'] ?? ''),
          hasAccepted: json['aceito'] == 1 ? true : false,
        );

  ContractSignature copyWith(
    int? userId,
    DateTime? dateTime,
    bool? hasAccepted,
  ) {
    return ContractSignature(
      userId: userId ?? this.userId,
      dateTime: dateTime ?? this.dateTime,
      hasAccepted: hasAccepted ?? this.hasAccepted,
    );
  }
}
