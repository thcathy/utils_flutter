import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/bloc/auth_bloc.dart';

extension NavigatorExtension on Navigator {
  static void goToAuthenticatedPage(BuildContext context, Widget page) {
    final authBloc = context.read<AuthBloc>();
    Navigator.of(context).push(
      MaterialPageRoute<Widget>(
        builder: (context) {
          return BlocProvider.value(
            value: authBloc,
            child: page,
          );
        },
      ),
    );
  }
}
