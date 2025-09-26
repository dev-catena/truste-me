
part of 'profile_detail_bloc.dart';

@immutable
sealed class ProfileDetailState {}

final class ProfileDetailInitial extends ProfileDetailState {}

final class ProfileDetailLoadInProgress extends ProfileDetailState {}

final class ProfileDetailReady extends ProfileDetailState {
  final User user;
  final String? message;

  static const _sentinel = Object();

  ProfileDetailReady copyWith({
    Object? user = _sentinel,
    Object? message = _sentinel,
  }) {
    return ProfileDetailReady(
      user: user == _sentinel ? this.user : user as User,
      message: message == _sentinel ? this.message : message as String,
    );
  }

  ProfileDetailReady({
    required this.user,
    this.message,
  });
}

final class ProfileDetailError extends ProfileDetailState {
  final String msg;

  ProfileDetailError(this.msg);
}
