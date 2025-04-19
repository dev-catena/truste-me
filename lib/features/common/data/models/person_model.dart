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
          id: json['id'] ?? json['user']['id'],
          fullName: json['nome_completo'] ?? json['user']['nome_completo'],
          cpf: json['cpf'] ?? 'Sem CPF',
          birthDate: json['dt_nasc'] ?? DateTime.now(),
          connectionCode: json['codigo'] ?? 'Sem código',
          memberSince: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
          country: json['pais'] ?? 'Sem país',
          state: json['estado'] ?? 'Sem estado',
          profession: json['profissao'] ?? 'Sem profissão',
          photoPath: json['caminho_foto'],
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
