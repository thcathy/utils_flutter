import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:utils_flutter/models/fund.dart';
import 'package:utils_flutter/services/bloc/auth_bloc.dart';
import 'package:utils_flutter/services/bloc/create_holding_cubit.dart';
import 'package:utils_flutter/services/bloc/manage_fund_bloc.dart';
import 'package:utils_flutter/services/fund_service.dart';
import 'package:utils_flutter/views/authenticated_page.dart';

import '../services/create_holding_service.dart';

class CreateHoldingPage extends AuthenticatedPage {
  CreateHoldingPage({super.key});

  @override
  String title() => 'Create holding';

  @override
  Widget buildPage(context, state) {
    if (state is AuthStateLoggedOut) {
      return const CircularProgressIndicator();
    }

    return BlocProvider(
      create: (context) {
        final authState = context
            .read<AuthBloc>()
            .state as AuthStateLoggedIn;
        final idToken = authState.authUser.idToken;
        return CreateHoldingCubit(
          CreateHoldingService(idToken: idToken),
          FundService(idToken: idToken),
        );
      },
      child: BlocBuilder<CreateHoldingCubit, CreateHoldingState>(builder: (context, state) {
        final execMsgController = TextEditingController();
        final CreateHoldingCubit cubit = context.read<CreateHoldingCubit>();
        execMsgController.text = state.execMessage;

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
                    const Text('Execution message', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextField(
                      maxLines: 4,
                      controller: execMsgController,
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: () => execMsgController.text += 'usmart',
                        child: const Text('usmart'),
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () => cubit.submit(execMsgController.text),
                          icon: const Icon(Icons.send),
                          label: const Text('Submit'),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            execMsgController.clear();
                            cubit.clear();
                          },
                          icon: const Icon(Icons.close),
                          label: const Text('Clear'),
                        ),
                      ],
                    ),
                    const Divider(),
                    Text('Error message: ${state.errorMessage}'),
                    const Divider(),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AddHoldingToFundWidget()
                  ],
                ),
              ),
            ]
        );
      }),
    );
  }
}

class AddHoldingToFundWidget extends StatelessWidget {
  const AddHoldingToFundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateHoldingCubit, CreateHoldingState>(
      builder: (context, state) {
        if (state is !CreateHoldingSuccess) return Container();
        final holding = state.holding;
        final funds = state.funds;
        final CreateHoldingCubit cubit = context.read<CreateHoldingCubit>();
        final feeTextController = TextEditingController();
        feeTextController.text = state.selectedFee?.toString() ?? '';
        final selectedFund = state.selectedFund;
        final updatedFund = state.updatedFund;

        return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Created: ${holding.toString()}'),
                const Divider(),
                const Text('Select Fund:'),
                ...funds.map((fund) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                    title: Text(
                      '${fund.name}: ${fund.holdings[holding.code]?.toString()}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () => cubit.selectFund(fund),
                  );
                }),
                const Divider(),
                const Text('Select Fee:'),
                ListTile(
                  title: const Text('Include Stamp:', style: TextStyle(fontSize: 12),),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                  onTap: () => cubit.selectFee(holding.fees!['INCLUDE_STAMP']),
                  trailing: Text('${holding.fees!['INCLUDE_STAMP']}'),
                ),
                ListTile(
                  title: const Text('Exclude Stamp:', style: TextStyle(fontSize: 12),),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                  onTap: () => cubit.selectFee(holding.fees!['EXCLUDE_STAMP']),
                  trailing: Text('${holding.fees!['EXCLUDE_STAMP']}'),
                ),
                const Divider(),
                SizedBox(
                  height: 28.0,
                  child: ListTile(
                    title: const Text('Holding',),
                    trailing: Text(holding.code,),
                  ),
                ),
                SizedBox(
                  height: 28.0,
                  child: ListTile(
                    title: const Text('Fund',),
                    trailing: Text(state.selectedFund?.name ?? 'None'),
                  ),
                ),
                SizedBox(
                  child: ListTile(
                    title: const Text('Fee'),
                    trailing: Container(
                      constraints: const BoxConstraints(maxWidth: 150.0),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: feeTextController,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () => cubit.updateFundByHolding(double.parse(feeTextController.text)),
                    child: const Text('Submit'),
                  ),
                ),
                const Divider(),
                 updatedFund != null
                    ? Text('Updated Fund [${updatedFund.name}], Profit=${updatedFund.profit}\n${updatedFund.holdings[holding.code].toString()}')
                    : Container(),
              ],
            ),
          ),
        );
      },
    );
  }
}

