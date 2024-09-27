import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:utils_flutter/services/bloc/auth_bloc.dart';
import 'package:utils_flutter/views/base_page.dart';
import 'package:utils_flutter/views/create_holding_page.dart';
import 'package:utils_flutter/views/full_quote_page.dart';
import 'package:utils_flutter/views/widgets/user_profile.dart';

import '../extensions/navigation.dart';
import 'manage_fund_page.dart';
import 'manage_holding_page.dart';

class HomePage extends BasePage {
  const HomePage({super.key});

  @override
  Widget buildBody(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Container(
          constraints: const BoxConstraints(minWidth: 100, maxWidth: 500),
          child: Column(
            children: [
              ListTile(
                title: const Text('Full Quote'),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () => NavigatorExtension.goToAuthenticatedPage(context, FullQuotePage()),
              ),
              const Divider(),
              Text('Management', style: Theme
                  .of(context)
                  .textTheme
                  .headlineSmall,),
              ListTile(
                title: const Text('Create Holding'),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () => NavigatorExtension.goToAuthenticatedPage(context, CreateHoldingPage()),
              ),
              ListTile(
                title: const Text('Manage Holding'),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () => NavigatorExtension.goToAuthenticatedPage(context, ManageHoldingPage()),
              ),
              ListTile(
                title: const Text('Manage Fund'),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () => NavigatorExtension.goToAuthenticatedPage(context, ManageFundPage()),
              ),
              const Divider(),
              const UserProfile(),
            ],
          ),
        );
      },
    );
  }
}

void navigateTo(BuildContext context, Widget page) {
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
