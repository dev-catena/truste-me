import '../../domain/entities/person.dart';
import 'seal_model.dart';

class PersonModel extends Person {
  const PersonModel({
    required super.id,
    required super.fullName,
    required super.birthDate,
    required super.cpf,
    required super.memberSince,
    required super.connectionCode,
    required super.authToken,
    super.country,
    super.state,
    super.photoPath,
    super.profession,
    super.sealsObtained,
  });

  PersonModel.fromJson(Map<String, dynamic> json)
      : super(
          id: json['id'] ?? json['user']?['id'] ?? json['usuario']?['id'],
          fullName: json['nome_completo'] ?? json['user']?['nome_completo'] ?? json['usuario']?['nome_completo'],
          cpf: json['CPF'] ?? json['user']?['CPF'] ?? 'Sem CPF',
          birthDate: DateTime.tryParse(json['dt_nascimento'] ?? '') ??
              DateTime.tryParse(json['user']?['dt_nascimento'] ?? '') ??
              DateTime.now(),
          connectionCode: json['codigo']?.toString() ?? json['user']?['codigo']?.toString() ?? 'Sem código',
          memberSince: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
          country: json['pais'] ?? json['user']?['pais'] ?? 'Sem país',
          state: json['estado'] ?? json['user']?['estado'] ?? 'Sem estado',
          profession: json['profissao'] ?? json['user']?['profissao'] ?? 'Sem profissão',
          photoPath: json['caminho_foto'] ?? json['user']?['caminho_foto'],
          sealsObtained: (json['selos'] as List<dynamic>?) != null
              ? (json['selos'] as List<dynamic>).map((e) => SealModel.fromJson(e).toEntity()).toList()
              : null,
          authToken: json['token'] ?? '',
        );

  Person toEntity() {
    return Person(
      id: id,
      fullName: fullName,
      cpf: cpf,
      birthDate: birthDate,
      state: state,
      profession: profession,
      country: country,
      photoPath: photoPath,
      sealsObtained: sealsObtained,
      memberSince: memberSince,
      connectionCode: connectionCode,
      authToken: authToken,
    );
  }
}
