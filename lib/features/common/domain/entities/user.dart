import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'seal.dart';
import '../../../../core/utils/custom_colors.dart';
import '../../presentation/widgets/components/user_summary_card.dart';

void setLoggedInUser (User user){
  _userLoggedIn = user;
}

User get userLoggedIn {
  return _userLoggedIn;
}

late User _userLoggedIn;


class User extends Equatable {
  final int id;
  final String fullName;
  final String cpf;
  final String? profession;
  final DateTime birthDate;
  final String? country;
  final String? state;
  final List<Seal>? sealsObtained;
  final String? photoPath;
  final DateTime memberSince;
  final String connectionCode;
  final String authToken;

  int get age{
    final today = DateTime.now();

    final time = today.difference(birthDate).inDays;
    return (time/365).floor();
  }

  @override
  List<Object?> get props => [id, fullName];

  const User({
    required this.id,
    required this.fullName,
    required this.cpf,
    this.profession,
    required this.birthDate,
    this.country,
    this.state,
    this.sealsObtained,
    this.photoPath,
    required this.memberSince,
    required this.connectionCode,
    this.authToken = '',
  });

  @override
  String toString() {
    return 'User{id: $id, fullName: $fullName, cpf: $cpf, '
        'profession: $profession, birthDate: $birthDate, '
        'country: $country, state: $state, sealsObtained: $sealsObtained, '
        'photoPath: $photoPath, memberSince: $memberSince, '
        'connectionCode: $connectionCode, authToken: $authToken}';
  }

  UserSummaryCard buildSummaryCard() {
    return UserSummaryCard(this);
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
