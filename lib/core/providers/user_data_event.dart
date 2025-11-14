
abstract class UserDataEvent {}

class ConnectionRequestResult extends UserDataEvent {
  final bool isSuccess;
  final String message;

  ConnectionRequestResult({required this.isSuccess, required this.message});
}