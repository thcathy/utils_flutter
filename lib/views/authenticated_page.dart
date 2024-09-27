import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:utils_flutter/views/base_page.dart';

import '../services/bloc/auth_bloc.dart';

abstract class AuthenticatedPage extends BasePage {
  AuthenticatedPage({super.key});
  late String idToken;

  @override
  Widget buildBody(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateLoggedOut) {
          context.read<AuthBloc>().add(AuthEventLogin());
        }
      },
      builder: (context, state) {
        final authState = context.read<AuthBloc>().state as AuthStateLoggedIn;
        idToken = authState.authUser.idToken;
        return buildPage(context, state);
      },
    );
  }

  buildPage(BuildContext context, AuthState state);
}
