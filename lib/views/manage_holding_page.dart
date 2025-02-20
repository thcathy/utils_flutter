import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:utils_flutter/models/side.dart';
import 'package:utils_flutter/services/bloc/auth_bloc.dart';
import 'package:utils_flutter/services/bloc/manage_holding_cubit.dart';
import 'package:utils_flutter/services/stock_service.dart';
import 'package:utils_flutter/views/base_scaffold.dart';

import '../utils/dialogs/delete_dialog.dart';

class ManageHoldingPage extends StatelessWidget {
  ManageHoldingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return authBlocConsumer((context, state) {
      if (state is AuthStateLoggedOut) {
        return const CircularProgressIndicator();
      }
      final authState = state as AuthStateLoggedIn;
      return BlocProvider(
            create: (_) => ManageHoldingCubit(StockService(idToken: authState.authUser.idToken)),
            child: buildScaffold(context: context,
                    title: 'Manage Holding',
                    buildBody: (_) => buildPage(context, state),
                    buildBottomNavigationBar: (_) => buildBottomNavigationBar(context)
      ),
      );
    });
  }

  Widget buildPage(context, state) {
    if (state is AuthStateLoggedOut) {
      return const CircularProgressIndicator();
    }

    return BlocBuilder<ManageHoldingCubit, ManageHoldingState>(builder: (context, state) {
      final holdings = state.holdings;
      final distinctFundNames = holdings
          .map((holding) => holding.fundName)
          .where((fundName) => fundName != null).cast<String>()
          .toSet().toList();
      final cubit = context.read<ManageHoldingCubit>();
      final selectedFundName = state.selectedFundName;
      final holdingsMatchFundName = holdings.where((h) => selectedFundName.isEmpty || h.fundName == selectedFundName).toList();

      return SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            if (holdings.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SegmentedButton<String?>(
                  segments: [
                    for (final fundName in distinctFundNames)
                      ButtonSegment<String?>(
                        value: fundName,
                        label: Text(fundName),
                      ),
                  ],
                  selected: <String>{state.selectedFundName},
                  onSelectionChanged: (Set<String?> newSelection) => cubit.selectFundName(newSelection.first),
                ),
              )
            ,
            Expanded(
              child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 250.0),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200.0, // Maximum width for each item
                    childAspectRatio: 1.5, // Height to width ratio of each item
                    crossAxisSpacing: 10.0, // Space between columns
                    mainAxisSpacing: 10.0, // Space between rows
                  ),
                  itemCount: holdingsMatchFundName.length,
                  itemBuilder: (context, index) {
                    final holding = holdingsMatchFundName[index];
                    final isSelected = state.selectedHoldings.any((h) => h.id == holding.id);
                    final isPossibleHolding = state.possibleHolding?.id == holding.id;
              
                    return GestureDetector(
                      onTap: () => cubit.selectHolding(holding),
                      child: Card(
                        elevation: 2,
                        color:  isSelected ? Colors.blue[50] : isPossibleHolding ? Colors.green[50] : Colors.white,
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
                                          '${holding.gross.toStringAsFixed(0)}@${holding.price.toStringAsFixed(2)}',
                                          style: TextStyle(color: holding.side == Side.BUY ? Colors.green : Colors.deepOrange),
                                        ),
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
                      ),
                    );
                  }),
            ),
          ],
        ),
      );
    });
  }

  Widget? buildBottomNavigationBar(BuildContext context) {
    return BlocBuilder<ManageHoldingCubit, ManageHoldingState>(builder: (context, state) {
      final cubit = context.read<ManageHoldingCubit>();
      if (cubit.state.selectedHoldings.length != 2) { return SizedBox.shrink(); }
      final selectedHoldings = cubit.state.selectedHoldings;

      final diffAmount = (selectedHoldings[0].gross - selectedHoldings[1].gross).abs();
      return BottomAppBar(child: Row(
        children: [
          Text('Different=\$$diffAmount'),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final isDelete = await showDeleteDialog(
                context,
                '''are you sure?''',
              );
              if (isDelete) {}
            },
            alignment: Alignment.bottomRight,
          ),
        ],
      ),);
    });
  }
}
