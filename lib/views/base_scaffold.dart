
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/bloc/auth_bloc.dart';

Scaffold buildScaffold({
  required BuildContext context,
  String? title,
  required Widget Function(BuildContext) buildBody,
  Widget Function(BuildContext)? buildFloatingActionButton,
  List<Widget> Function(BuildContext)? buildActions,
  Widget? Function(BuildContext)? buildBottomNavigationBar,
}) {
  return Scaffold(
    appBar: AppBar(
      title: Text(title ?? 'Squote Utility'),
      actions: buildActions?.call(context) ?? [],
      elevation: 2.0,
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        child: SelectionArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(child: buildBody(context)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    floatingActionButton: buildFloatingActionButton?.call(context) ?? Container(),
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    bottomNavigationBar: buildBottomNavigationBar?.call(context) ?? null,
  );
}

Scaffold buildScaffoldWithAuth(
{
  required BuildContext context,
  required Widget Function(BuildContext, AuthState) buildBody,
  String? title,
  Widget? Function(BuildContext)? buildBottomNavigationBar,
}) {
  return buildScaffold(
      context: context,
      title:  title,
      buildBody: (context) => authBlocConsumer(buildBody),
      buildBottomNavigationBar: buildBottomNavigationBar,
  );
}

BlocConsumer<AuthBloc, AuthState> authBlocConsumer(
    Widget Function(BuildContext, AuthState) buildBody
) {
  return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateLoggedOut) {
          context.read<AuthBloc>().add(AuthEventLogin());
        }
      },
      builder: (context, state) {
        final authState = context.read<AuthBloc>().state as AuthStateLoggedIn;
        return buildBody.call(context, authState);
      },
  );
}

