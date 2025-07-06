import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:utils_flutter/services/bloc/auth_bloc.dart';
import 'package:utils_flutter/services/bloc/stock_trading_task_cubit.dart';
import 'package:utils_flutter/services/stock_service.dart';
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
              StockTradingTaskStatus(state),
              const Divider(),
              const UserProfile(),
            ],
          ),
        );
      },
    );
  }
}

class StockTradingTaskStatus extends StatelessWidget {
  final AuthState state;

  const StockTradingTaskStatus(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    if (state is AuthStateLoggedOut) {
      return Container();
    }

    return BlocProvider(
      create: (context) {
        final authState = context.read<AuthBloc>().state as AuthStateLoggedIn;
        final idToken = authState.authUser.idToken;
        return StockTradingTaskCubit(
            StockService(idToken: idToken)
        );
      },
      child: BlocBuilder<StockTradingTaskCubit, StockTradingTaskState>(
        builder: (context, state) {
          final cubit = context.read<StockTradingTaskCubit>();
          final markets = ['HK', 'US'];
          
          return Column(
            children: markets.map((market) => ListTile(
              title: Text('Trading task - $market'),
              trailing: Switch(
                value: state.enabledByMarket?[market] ?? false,
                onChanged: state.enabledByMarket?[market] == null ? null : (value) => cubit.updateFlag(market, value),
              ),
            )).toList(),
          );
        },
      ),
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
