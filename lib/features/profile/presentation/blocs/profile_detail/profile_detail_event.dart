part of 'profile_detail_bloc.dart';

@immutable
sealed class ProfileDetailEvent extends Equatable {
  const ProfileDetailEvent();
  @override
  List<Object?> get props => [];
}

class ProfileDetailStarted extends ProfileDetailEvent {}

final class PersonalDataChanged extends ProfileDetailEvent {
  final UserInfoData newData;
  const PersonalDataChanged(this.newData);
  @override
  List<Object?> get props => [newData];
}

final class AddressDataChanged extends ProfileDetailEvent {
  final AddressInfoData newAddress;
  const AddressDataChanged(this.newAddress);
  @override
  List<Object?> get props => [newAddress];
}

final class ComplementaryDataChanged extends ProfileDetailEvent {
  final ComplementaryInfoData newInfo;
  const ComplementaryDataChanged(this.newInfo);
  @override
  List<Object?> get props => [newInfo];
}

// Event to clear any message shown to the user (e.g., in a SnackBar).
final class ClearMessage extends ProfileDetailEvent {}

final class ProfileDetailSave extends ProfileDetailEvent {}
