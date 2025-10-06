import 'package:trustme/features/common/domain/entities/auth.dart';

class AuthModel extends Auth {
  AuthModel({
    required super.authToken,
    super.refreshToken,
    super.expirationAt,
  });

  AuthModel.fromJson(Map<String, dynamic> json) : super(
    authToken: json['token'] ?? '',
    refreshToken: json['refresh_token'] ?? '',
    expirationAt: DateTime.tryParse(json['expiration_at'] ?? ''),
  );

  Auth toEntity() {
    return Auth(
      authToken: authToken,
      refreshToken: refreshToken,
      expirationAt: expirationAt,
    );
  }
}
