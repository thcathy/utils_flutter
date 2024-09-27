import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:utils_flutter/services/bloc/auth_bloc.dart';
import 'package:utils_flutter/services/bloc/manage_fund_bloc.dart';
import 'package:utils_flutter/services/fund_service.dart';
import 'package:utils_flutter/views/authenticated_page.dart';

class ManageFundPage extends AuthenticatedPage {
  ManageFundPage({super.key});

  @override
  String title() => 'Manage Fund Rest API';

  @override
  Widget buildPage(context, state) {
    if (state is AuthStateLoggedOut) {
      return const CircularProgressIndicator();
    }

    return BlocProvider(
      create: (context) {
        final authState = context.read<AuthBloc>().state as AuthStateLoggedIn;
        return ManageFundBloc(FundService(idToken: authState.authUser.idToken));
      },
      child: BlocBuilder<ManageFundBloc, ManageFundState>(builder: (context, state) {
        if (state.funds.isEmpty) {
          return const CircularProgressIndicator();
        }

        return Wrap(
          alignment: WrapAlignment.start,
          spacing: 16,
          runSpacing: 16,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Existing funds:'),
                  Wrap(
                    spacing: 8, // Horizontal space between buttons
                    runSpacing: 8, // Vertical space between rows
                    children: state.funds.map((f) => ActionButton(f.name)).toList(),
                  ),
                  const Divider(),
                  const Text('URL:'),
                  const ActionList(),
                  const Divider()
                ],
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const RequestController(),
                  const Divider(),
                  const Text('Response:'),
                  Text(const JsonEncoder.withIndent(' ').convert(state.response)),
                  const Divider(),
                  const Text('History:'),
                  ...state.histories.map((h) => Text(h)),
                ],
              ),
            ),
          ]
        );
      }),
    );
  }
}

class RequestController extends StatelessWidget {
  const RequestController({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageFundBloc, ManageFundState>(
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Request:'),
            TextField(
              controller: state.urlEditController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.link),
                labelText: 'URL',
              ),
            ),
            Row(
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.send),
                  onPressed: () => context.read<ManageFundBloc>().add(ManageFundSubmitEvent()),
                  label: const Text('Submit'),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.close),
                  onPressed: () => context.read<ManageFundBloc>().add(ManageFundUrlClearEvent()),
                  label: const Text('Clear'),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}

class ActionList extends StatelessWidget {
  const ActionList({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ActionRow([ ActionButton('create'), Text('/[fundName]/'), ActionButton('STOCK'), Text(','), ActionButton('CRYPTO') ]),
        ActionRow([ ActionButton('delete'), Text('/[fundName]') ]),
        ActionRow([ Text('[fundName]/'), ActionButton('type'), Text('/'), ActionButton('STOCK'), Text(','), ActionButton('CRYPTO') ]),
        ActionRow([ Text('[fundName]/'), ActionButton('buy'), Text(','), ActionButton('sell'), Text('/[code]/[qty]/[price]') ]),
        ActionRow([ Text('[fundName]/'), ActionButton('remove'), Text('/[code]') ]),
        ActionRow([ Text('[fundName]/'), ActionButton('payinterest'), Text('/[code]/[amount]') ]),
        ActionRow([ ActionButton('splitinterest'), Text('[code]/[amount]/[funds(/separated)]') ]),
        ActionRow([ Text('[fundName]/'), ActionButton('set/profit'), Text('/[amount]')]),
        ActionRow([ Text('[fundName]/'), ActionButton('cashout'), Text('/[amount]')]),
        ActionRow([ Text('[fundName]/'), ActionButton('cashin'), Text('/[amount]')]),
        ActionRow([ Text('[fundName]/['), ActionButton('add'), Text(','), ActionButton('subtract'), Text(']/'), ActionButton('profit'), Text('/[amounts(,separated)]')]),
        ActionRow([ Text('[fundName]/'), ActionButton('get-trades/from/binance') ]),
      ],
    );
  }
}

class ActionRow extends StatelessWidget {
  final List<Widget> children;
  const ActionRow(this.children, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String action;

  const ActionButton(this.action, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: FilledButton.tonal(
        onPressed: () => context.read<ManageFundBloc>().add(ManageFundActionSelectedEvent('$action/')),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Rounded corners
          ),
        ),
        child: Text(action),
      ),
    );
  }
}


