part of 'profile_detail_bloc.dart';

@immutable
sealed class ProfileDetailState extends Equatable {}

final class ProfileDetailInitial extends ProfileDetailState {
  @override
  List<Object?> get props => [];
}
//
final class ProfileDetailLoadInProgress extends ProfileDetailState {
  @override
  List<Object?> get props => [];
}

final class ProfileDetailReady extends ProfileDetailState {
  final User user;

  final UserInfoData personalData;
  final AddressInfoData addressData;
  final ComplementaryInfoData complementaryInfoData;

  final bool isSaving;
  final String? message;

  ProfileDetailReady({
    required this.user,
    required this.personalData,
    required this.addressData,
    required this.complementaryInfoData,
    this.isSaving = false,
    this.message,
  });

  // A robust copyWith is crucial for immutable state management.
  ProfileDetailReady copyWith({
    UserInfoData? personalData,
    AddressInfoData? addressData,
    ComplementaryInfoData? complementaryInfoData,
    bool? isSaving,
    ValueGetter<String?>? message, // Use ValueGetter to allow setting message to null
  }) {
    return ProfileDetailReady(
      user: user, // user does not change
      personalData: personalData ?? this.personalData,
      addressData: addressData ?? this.addressData,
      complementaryInfoData: complementaryInfoData ?? this.complementaryInfoData,
      isSaving: isSaving ?? this.isSaving,
      message: message != null ? message() : this.message,
    );
  }

  @override
  List<Object?> get props => [
    user,
    personalData,
    addressData,
    complementaryInfoData,
    isSaving,
    message,
  ];
}

final class ProfileDetailError extends ProfileDetailState {
  final String msg;

  ProfileDetailError(this.msg);

  @override
  List<Object?> get props => [msg];
}
