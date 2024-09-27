part of 'auth_bloc.dart';

@immutable
sealed class AuthState {
}

class AuthStateLoggedOut extends AuthState {}

class AuthStateLoggedIn extends AuthState {
  final AuthUser authUser;
  AuthStateLoggedIn({required this.authUser});
}


