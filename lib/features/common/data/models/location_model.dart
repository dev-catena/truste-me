import '../../domain/entities/location.dart';

class LocationModel extends Location {
  LocationModel({
    required super.cep,
    required super.street,
    required super.number,
    required super.complement,
    required super.neighborhood,
    required super.city,
    required super.state,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      cep: json['cep'],
      street: json['logradouro'],
      number: json['numero'] ?? '',
      complement: json['complemento'],
      neighborhood: json['bairro'],
      city: json['localidade'],
      state: json['estado'],
    );
  }

  Location toEntity() {
    return Location(
      cep: cep,
      state: state,
      city: city,
      neighborhood: neighborhood,
      street: street,
      number: number,
      complement: complement,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cep': cep,
      'cidade': city,
      'estado': state,
      'bairro': neighborhood,
      'endereco': '$street$number${number != '' ? ', $number' : ''}${complement != '' ? ' - $complement' : ''}',
    };
  }
}
