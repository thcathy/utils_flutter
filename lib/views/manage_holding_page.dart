import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:utils_flutter/models/side.dart';
import 'package:utils_flutter/services/bloc/auth_bloc.dart';
import 'package:utils_flutter/services/bloc/manage_fund_bloc.dart';
import 'package:utils_flutter/services/bloc/manage_holding_cubit.dart';
import 'package:utils_flutter/services/fund_service.dart';
import 'package:utils_flutter/services/stock_service.dart';
import 'package:utils_flutter/views/authenticated_page.dart';
import 'package:utils_flutter/views/base_page.dart';

import '../utils/dialogs/delete_dialog.dart';

class ManageHoldingPage extends AuthenticatedPage {
  ManageHoldingPage({super.key});

  @override
  String title() => 'Manage Holding';

  @override
  Widget buildPage(context, state) {
    if (state is AuthStateLoggedOut) {
      return const CircularProgressIndicator();
    }

    return BlocProvider(create: (context) {
      final authState = context.read<AuthBloc>().state as AuthStateLoggedIn;
      return ManageHoldingCubit(StockService(idToken: authState.authUser.idToken));
    }, child: BlocBuilder<ManageHoldingCubit, ManageHoldingState>(builder: (context, state) {
      final holdings = state.holdings;
      return SizedBox(
        height: MediaQuery.of(context).size.height,
        child: GridView.builder(
          padding: const EdgeInsets.only(bottom: 200.0),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250.0, // Maximum width for each item
              childAspectRatio: 1.8, // Height to width ratio of each item
              crossAxisSpacing: 10.0, // Space between columns
              mainAxisSpacing: 10.0, // Space between rows
            ),
            itemCount: holdings.length,
            itemBuilder: (context, index) {
              final holding = holdings[index];
              final cubit = context.read<ManageHoldingCubit>();
              
              return Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            holding.code,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: Text(
                              '${holding.side == Side.BUY ? '+' : '-'}${holding.quantity}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.end, // Align fund name to the right
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(DateFormat('yyyy-MM-dd').format(holding.date)),
                                Text(
                                  holding.gross.toStringAsFixed(2),
                                  style: TextStyle(color: holding.side == Side.BUY ? Colors.green : Colors.deepOrange),
                                ),
                                Text('HSCEI: ${holding.hsce?.toStringAsFixed(2)}'),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final isDelete = await showDeleteDialog(
                                context,
                                '''${holding.code} ${holding.side == Side.BUY ? '+' : '-'}${holding.quantity}
${DateFormat('yyyy-MM-dd').format(holding.date)}''',
                              );
                              if (isDelete) cubit.deleteHolding(holding.id);
                            },
                            alignment: Alignment.bottomRight,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
      );
    }));
  }
}
