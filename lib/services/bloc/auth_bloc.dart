import 'dart:convert';

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:auth0_flutter/auth0_flutter_web.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/auth_user.dart';
import '../window.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthUserKey = 'AuthUser';

  AuthBloc(Auth0Web auth0Web, Auth0 auth0) : super(AuthStateLoggedOut()) {
    on<AuthEventInit>((event, emit) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        if (prefs.containsKey(AuthUserKey)) {
          final userString = prefs.getString(AuthUserKey);
          final user = AuthUser.fromJson(jsonDecode(userString!));
          int exp = JwtDecoder.decode(user.idToken)['exp'];
          DateTime expirationTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);

          final tomorrow = DateTime.now().add(const Duration(days: 1));
          if (expirationTime.isAfter(tomorrow)) {
            emit(AuthStateLoggedIn(authUser: user));
            return;
          }
        }

        if (kIsWeb) {
          Credentials? credentials = await auth0Web.onLoad();
          if (credentials == null) return;
          final user = AuthUser.fromAuth0(credentials);
          await storeAuthUser(user);
          emit(AuthStateLoggedIn(authUser: user));
        }
      } catch (e, stackTrace) {
        print('Error loading credentials: $e \n $stackTrace');
      }
    });

    on<AuthEventLogin>((event, emit) async {
      if (kIsWeb) {
        auth0Web.loginWithRedirect(redirectUrl: locationHref());
        return;
      }

      Credentials? credentials = await auth0.webAuthentication().login(useHTTPS: true);
      if (credentials == null) return;

      final user = AuthUser.fromAuth0(credentials);
      await storeAuthUser(user);
      emit(AuthStateLoggedIn(authUser: AuthUser.fromAuth0(credentials)));
    });
  }

  storeAuthUser(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AuthUserKey, user.toString());
  }
}
