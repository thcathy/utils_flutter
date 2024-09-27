import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/bloc/auth_bloc.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return Text('Logged in: ${state.authUser.email}');
        } else {
          return TextButton(
              onPressed: () async {
                context.read<AuthBloc>().add(AuthEventLogin());
              },
              child: const Text('Login')
          );
        }
      },
    );
  }
}
