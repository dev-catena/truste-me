import 'package:trustme/features/common/data/models/location_model.dart';

class Location {
  final int id;
  final String cep;
  final String state;
  final String city;
  final String neighborhood;
  final String street;
  final String number;
  final String complement;

  Location copyWith({
    int? id,
    String? cep,
    String? street,
    String? neighborhood,
    String? number,
    String? complement,
    String? city,
    String? state,
  }) {
    return Location(
      id: id ?? this.id,
      cep: cep ?? this.cep,
      neighborhood: neighborhood ?? this.neighborhood,
      street: street ?? this.street,
      number: number ?? this.number,
      complement: complement ?? this.complement,
      city: city ?? this.city,
      state: state ?? this.state,
    );
  }

  const Location({
    required this.id,
    required this.cep,
    required this.state,
    required this.city,
    required this.neighborhood,
    required this.street,
    required this.number,
    required this.complement,
  });
}

extension LocationEntityMapper on Location {
  LocationModel toModel() {
    return LocationModel(
      id: id,
      cep: cep,
      street: street,
      complement: complement,
      neighborhood: neighborhood,
      city: city,
      state: state,
      number: number,
    );
  }
}
