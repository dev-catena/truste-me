part of 'profile_detail_bloc.dart';

@immutable
sealed class ProfileDetailEvent {}

class ProfileDetailStarted extends ProfileDetailEvent {}

class ProfileDetailSave extends ProfileDetailEvent {
  final Map<String, dynamic> user;

  ProfileDetailSave(this.user);
}
