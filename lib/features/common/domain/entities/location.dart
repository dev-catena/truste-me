import '../../data/models/location_model.dart';

class Location {
  final String cep;
  final String state;
  final String city;
  final String street;
  final String number;
  final String complement;
  final String district;

  Location copyWith({
    String? cep,
    String? street,
    String? number,
    String? complement,
    String? district,
    String? city,
    String? state,
  }) {
    return Location(
      cep: cep ?? this.cep,
      street: street ?? this.street,
      number: number ?? this.number,
      complement: complement ?? this.complement,
      district: district ?? this.district,
      city: city ?? this.city,
      state: state ?? this.state,
    );
  }

  const Location({
    required this.cep,
    required this.state,
    required this.city,
    required this.district,
    required this.street,
    required this.number,
    required this.complement,
  });
}

extension LocationEntityMapper on Location {
  LocationModel toModel() {
    return LocationModel(
      cep: cep,
      street: street,
      complement: complement,
      district: district,
      city: city,
      state: state,
      number: number,
    );
  }
}
