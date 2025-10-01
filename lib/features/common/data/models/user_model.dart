import '../../domain/entities/user.dart';
import 'seal_model.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.connectionCode,
    required super.email,
    required super.fullName,
    required super.cpf,

    super.country,
    super.cep,
    super.state,
    super.city,
    super.address,
    super.neighborhood,
    super.addressNumber,
    super.addressComplement,

    super.profession,
    super.income,
    required super.birthDate,
    super.photoPath,
    super.emailVerifiedAt,
    required super.memberSince,
    required super.sealsObtained,
  });

  UserModel.fromJson(Map<String, dynamic> json) : super(
    id: json['id'] ?? json['user']?['id'],
    connectionCode: json['codigo']?.toString() ?? json['user']?['codigo']?.toString() ?? 'Sem código',
    email: json['email'] ?? json['user']?['email'] ?? 'Sem email',
    fullName: json['nome_completo'] ?? json['user']?['nome_completo'],
    cpf: json['CPF'] ?? json['user']?['CPF'] ?? 'Sem CPF',

    country: json['pais'] ?? json['user']?['pais'],
    cep: json['cep'] ?? json['user']?['cep'],
    state: json['estado'] ?? json['user']?['estado'],
    city: json['cidade'] ?? json['user']?['cidade'],
    address: json['endereco'] ?? json['user']?['endereco'],
    neighborhood: json['bairro'] ?? json['user']?['bairro'],
    addressNumber: json['endereco_numero'] ?? json['user']?['endereco_numero'],
    addressComplement: json['complemento'] ?? json['user']?['complemento'],

    profession: json['profissao'] ?? json['user']?['profissao'] ?? 'Sem profissão',
    income: json['renda_classe'] ?? json['user']?['renda_classe'] ?? 'Sem renda',
    birthDate: DateTime.tryParse(json['dt_nascimento'] ?? '') ?? DateTime.tryParse(json['user']?['dt_nascimento'] ?? '') ?? DateTime.now(),

    photoPath: json['caminho_foto'] ?? json['user']?['caminho_foto'],
    emailVerifiedAt: DateTime.tryParse(json['email_verified_at'] ?? '') ?? DateTime.tryParse(json['user']?['email_verified_at'] ?? ''),
    memberSince: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),

    sealsObtained: (json['selos'] as List<dynamic>? ?? []).map((e) => SealModel.fromJson(e).toEntity()).toList(),
  );

  User toEntity() {
    return User(
      id: id,
      connectionCode: connectionCode,
      email: email,
      fullName: fullName,
      cpf: cpf,

      country: country,
      cep: cep,
      state: state,
      city: city,
      address: address,
      neighborhood: neighborhood,
      addressNumber: addressNumber,
      addressComplement: addressComplement,

      profession: profession,
      income: income,
      birthDate: birthDate,

      photoPath: photoPath,
      emailVerifiedAt: emailVerifiedAt,
      memberSince: memberSince,

      sealsObtained: sealsObtained,
    );
  }
}
