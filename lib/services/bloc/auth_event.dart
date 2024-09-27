part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class AuthEventInit extends AuthEvent {}

class AuthEventLogin extends AuthEvent {}

class AuthEventAuthenticated extends AuthEvent {
  final Credentials? credentials;
  AuthEventAuthenticated({required this.credentials});
}
