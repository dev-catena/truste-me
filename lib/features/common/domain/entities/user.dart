import 'dart:convert';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'seal.dart';
import '../../../../core/utils/custom_colors.dart';
import '../../presentation/widgets/components/user_summary_card.dart';

void setLoggedInUser(User user) {
  _userLoggedIn = user;
}

User get userLoggedIn {
  return _userLoggedIn;
}

late User _userLoggedIn;

class User extends Equatable {
  final int id;
  final String connectionCode;
  final String email;
  final String fullName;
  final String cpf;

  final String? country;
  final String? cep;
  final String? state;
  final String? city;
  final String? address;
  final String? neighborhood;
  final String? addressNumber;
  final String? addressComplement;

  final String? profession;
  final String? income;
  final DateTime birthDate;

  final String? photoPath;
  final DateTime? emailVerifiedAt;
  final DateTime memberSince;

  final List<Seal> sealsObtained;

  int get age {
    final today = DateTime.now();

    final time = today.difference(birthDate).inDays;
    return (time / 365).floor();
  }

  @override
  List<Object?> get props => [id, fullName];

  User({
    required this.id,
    required this.connectionCode,
    required this.email,
    required this.fullName,
    required this.cpf,

    this.country,
    this.cep,
    this.state,
    this.city,
    this.address,
    this.neighborhood,
    this.addressNumber,
    this.addressComplement,

    this.profession,
    this.income,
    required this.birthDate,

    this.photoPath,
    this.emailVerifiedAt,
    required this.memberSince,

    required this.sealsObtained,
  });

  User copyWith({
    int? id,
    String? connectionCode,
    String? email,
    String? fullName,
    String? cpf,
    String? country,
    String? cep,
    String? state,
    String? city,
    String? address,
    String? neighborhood,
    String? addressNumber,
    String? addressComplement,
    String? profession,
    String? income,
    DateTime? birthDate,
    String? photoPath,
    DateTime? emailVerifiedAt,
    DateTime? memberSince,
    List<Seal>? sealsObtained,
  }) {
    return User(
      id: id ?? this.id,
      connectionCode: connectionCode ?? this.connectionCode,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      cpf: cpf ?? this.cpf,
      country: country ?? this.country,
      cep: cep ?? this.cep,
      state: state ?? this.state,
      city: city ?? this.city,
      address: address ?? this.address,
      neighborhood: neighborhood ?? this.neighborhood,
      addressNumber: addressNumber ?? this.addressNumber,
      addressComplement: addressComplement ?? this.addressComplement,
      profession: profession ?? this.profession,
      income: income ?? this.income,
      birthDate: birthDate ?? this.birthDate,
      photoPath: photoPath ?? this.photoPath,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      memberSince: memberSince ?? this.memberSince,
      sealsObtained: sealsObtained ?? this.sealsObtained,

    );
  }

  String obfuscateName() {
    final asteriskQt = Random().nextInt(8) + 3;
    final space = Random().nextInt(asteriskQt) + 1;
    final asterisks = '*' * asteriskQt;
    final obfuscated = asterisks.replaceRange(space, space, ' ');

    // return '${fullName.substring(0, 3)}$obfuscated';
    return '${fullName.substring(0, 3)}** *****';
  }

  String obfuscateCpf() {
    return '${cpf.substring(0, 3)}.***.***-**';
  }

  @override
  String toString() {
    return 'User{id: $id, connectionCode: $connectionCode, email: $email, fullName: $fullName, cpf: $cpf, '
        'country: $country, cep: $cep, state: $state, city: $city, address: $address, neighborhood: $neighborhood, addressNumber: $addressNumber, addressComplement: $addressComplement, '
        'profession: $profession, income: $income, birthDate: $birthDate, '
        'photoPath: $photoPath, emailVerifiedAt: $emailVerifiedAt, memberSince: $memberSince, '
        //'sealsObtained: $sealsObtained, authToken: $authToken}';
        'sealsObtained: $sealsObtained}';
  }

  UserSummaryCard buildSummaryCard({required bool isLoggedUser, required bool showEditButton}) {
    return UserSummaryCard(this, isLoggedUser: isLoggedUser, showEditButton: showEditButton);
  }

  Widget buildAvatar([double? radius, bool? showBorder = false]) {
    return Container(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        border: showBorder! ? Border.all(color: CustomColor.activeColor, width: 2) : null,
        borderRadius: BorderRadius.circular(radius != null ? radius * 2 : 70),
      ),
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: radius ?? 35,
        backgroundImage: NetworkImage(
          photoPath != null
              ? 'https://thispersondoesnotexist.com/'
              : 'https://st3.depositphotos.com/6672868/13701/v/450/depositphotos_137014128-stock-illustration-user-profile-icon.jpg',
        ),
      ),
    );
  }
}
