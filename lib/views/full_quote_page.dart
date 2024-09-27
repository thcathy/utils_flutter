import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:utils_flutter/models/fund.dart';
import 'package:utils_flutter/models/fund_holding.dart';
import 'package:utils_flutter/models/holding_stock.dart';
import 'package:utils_flutter/models/side.dart';
import 'package:utils_flutter/services/bloc/auth_bloc.dart';
import 'package:utils_flutter/services/bloc/create_holding_cubit.dart';
import 'package:utils_flutter/services/bloc/full_quote_cubit.dart';
import 'package:utils_flutter/services/bloc/full_quote_settings_cubit.dart';
import 'package:utils_flutter/services/bloc/manage_fund_bloc.dart';
import 'package:utils_flutter/services/bloc/market_daily_report_cubit.dart';
import 'package:utils_flutter/services/fund_service.dart';
import 'package:utils_flutter/services/stock_service.dart';
import 'package:utils_flutter/views/authenticated_page.dart';

import '../models/market_data.dart';
import '../services/create_holding_service.dart';

class FullQuotePage extends AuthenticatedPage {
  FullQuotePage({super.key});
  late FullQuoteCubit cubit;

  @override
  String title() => 'Full Quote';

  @override
  Widget buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => cubit.getFullQuote(),
      child: const Icon(Icons.refresh), // Using a refresh icon
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.settings_outlined,),
        onPressed: () => showPriceChangesDialog(context),
      ),
    ];
  }

  Future<void> showPriceChangesDialog(BuildContext context) async {
    final stockCodes = cubit.state.stockQuotes?.map((q) => q.stockCode).toList() ?? [];
    final indexCodes = Map.fromIterable(cubit.state.indexQuotes!.map((q) => q.stockCode),
      key: (code) => code as String,
      value: (code) => cubit.state.selectedIndexCodes?.contains(code) ?? false
    );

    final result = await showDialog<FullQuotePageSettingsDialogResult>(
      context: context,
      builder: (BuildContext context) => FullQuotePageSettingsDialog(
        idToken: idToken,
        stockCodes: stockCodes,
        indexCodes: indexCodes,
      ),
    ) as FullQuotePageSettingsDialogResult;
    cubit.stockQuoteSelect(result.stockCodes, result.selectedIndexCodes);
  }

  @override
  Widget buildPage(context, state) {
    if (state is AuthStateLoggedOut) {
      return const LinearProgressIndicator();
    }

    final stockService = StockService(idToken: idToken);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => FullQuoteCubit(stockService)),
        BlocProvider(create: (context) => MarketDailyReportCubit(stockService))
      ],
      child: BlocBuilder<FullQuoteCubit, FullQuoteState>(builder: (context, state) {
        cubit = context.read<FullQuoteCubit>();
        final mediaWidth = MediaQuery.of(context).size.width;
        final boxWidth = mediaWidth < 800 ? 800.0 : MediaQuery.of(context).size.width / 2 - 32;

        return Wrap(
            alignment: WrapAlignment.start,
            spacing: 16,
            runSpacing: 16,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: boxWidth),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.loading) const LinearProgressIndicator(),
                    StockQuotesWidget(stockQuotes: state.stockQuotes),
                    const Divider(),
                    IndexesWidget(
                      indexQuotes: state.indexQuotes,
                      selectedIndexCode: state.selectedIndexCodes,
                    ),
                    const Divider(),
                    HoldingsWidget(holdings: state.holdings, stockQuotes: state.allQuotes ?? {}),
                    const Divider(),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: boxWidth),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FundsWidget(funds: state.funds ?? []),
                    const MarketDailyReportsWidget(),
                    const Divider(),
                  ],
                ),
              ),
            ]
        );
      }),
    );
  }
}

class FullQuotePageSettingsDialogResult {
  final bool showMore;
  List<String> stockCodes;
  List<String> selectedIndexCodes;

  FullQuotePageSettingsDialogResult({required this.showMore, required this.stockCodes, required this.selectedIndexCodes});
}

class FullQuotePageSettingsDialog extends StatelessWidget {
  final String idToken;
  final List<String> stockCodes;
  final Map<String, bool> indexCodes;

  const FullQuotePageSettingsDialog({
    super.key,
    required this.idToken,
    required this.stockCodes,
    required this.indexCodes,
  });

  onClose(BuildContext context, FullQuoteSettingsState state) {
    final stockCodes = state.stockCodesControllers.map((c) => c.text).where((t) => t.isNotEmpty).toSet().toList();
    final selectedIndexCodes = state.indexCodes.entries.where((e) => e.value).map((e) => e.key).toList();
    Navigator.of(context).pop(
      FullQuotePageSettingsDialogResult(
        showMore: state.showMore,
        stockCodes: stockCodes,
        selectedIndexCodes: selectedIndexCodes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FullQuoteSettingsCubit(StockService(idToken: idToken), stockCodes, indexCodes),
      child: BlocBuilder<FullQuoteSettingsCubit, FullQuoteSettingsState>(builder: (context, state) {
        final settingsCubit = context.read<FullQuoteSettingsCubit>();
        final stockCodesController = state.stockCodesControllers.asMap();

        if (state.snackMessage?.isNotEmpty ?? false) {
          final snackBar = SnackBar(
            content: Text(state.snackMessage!),
          );
          SchedulerBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          });
        }

        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Show Detail:'),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => onClose(context, state),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('More'),
                    Switch(
                      value: state.showMore,
                      onChanged: (value) => settingsCubit.showMoreChanged(value),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Stock codes:'),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => onClose(context, state),
                    ),
                  ],
                ),
                ...stockCodesController.entries.map((entry) {
                  int index = entry.key;
                  final controller = entry.value;
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(hintText: 'code...'),
                          controller: controller,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => settingsCubit.removeCodeControllerAt(index),
                      ),
                    ],
                  );
                }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(icon: const Icon(Icons.add), onPressed: () => settingsCubit.addStockCode()),
                    IconButton(icon: const Icon(Icons.cloud_download_outlined), onPressed: () => settingsCubit.loadStockCodesFromServer()),
                    IconButton(icon: const Icon(Icons.cloud_upload_outlined), onPressed: () => settingsCubit.saveStockCodesToServer()),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between title and button
                  children: [
                    const Text('Select indexes:'),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => onClose(context, state),
                    ),
                  ],
                ),
                // Example index list, replace with your actual data
                ...state.indexCodes.entries.map((entry) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between title and switch
                    children: [
                      Text(entry.key), // Display the key as title
                      Switch(
                        value: entry.value,
                        onChanged: (value) => settingsCubit.indexCodeChanged(entry.key, value),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      }),
    );
  }
}


class FundsWidget extends StatelessWidget {
  final List<Fund> funds;

  const FundsWidget({super.key, required this.funds});

  @override
  Widget build(BuildContext context) {
    if (funds.isEmpty) return Container();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...funds.map((fund) {
          final gross = fund.holdings.values.fold(0.0, (sum, holding) => sum + holding.gross);;

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(fund.name),
                  ),
                  Expanded(
                    child: Text(
                      NumberFormat('#,###').format(fund.profit),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  if (false)
                    Expanded(
                      child: Text(
                        NumberFormat('###0.0').format(fund.cashoutAmount),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      NumberFormat('#,###.##').format(fund.cashinAmount),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      NumberFormat('#,###').format((fund.netProfit ?? 0) + (fund.profit ?? 0)),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Container()),
                  if (false) SizedBox(width: 60), // Placeholder for spacing
                  if (false) SizedBox(width: 60), // Placeholder for spacing
                  Expanded(
                    child: Text(
                      NumberFormat('#,###').format(gross),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      NumberFormat('#,###').format(fund.netProfit),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${NumberFormat('###0.00').format((fund.netProfit ?? 0) / (gross + 1) * 100)}%',
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text('Code')),
                  if (false) Expanded(child: Text('Qty', textAlign: TextAlign.end)),
                  if (false) Expanded(child: Text('Price', textAlign: TextAlign.end)),
                  Expanded(child: Text('Gross', textAlign: TextAlign.end)),
                  Expanded(child: Text('+/-', textAlign: TextAlign.end)),
                  Expanded(child: Text('%', textAlign: TextAlign.end)),
                ],
              ),
              ...fund.holdings.entries.map((entry) {
                return FundHoldingRow(
                  stockCode: entry.key,
                  holding: entry.value,
                  showMore: false,
                );
              }),
              const Divider(),
            ],
          );
        })
      ],
    );
  }
}

class FundHoldingRow extends StatelessWidget {
  final String stockCode;
  final FundHolding holding;
  final bool showMore;

  FundHoldingRow({required this.stockCode, required this.holding, this.showMore = false});

  @override
  Widget build(BuildContext context) {
    final changePercentage = NumberFormat('0.00').format((holding.netProfit ?? 0) / holding.gross * 100);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(stockCode)),
        if (showMore) Expanded(child: Text('${holding.quantity}', textAlign: TextAlign.end)),
        if (showMore) Expanded(child: Text('${holding.price}', textAlign: TextAlign.end)),
        Expanded(child: Text(NumberFormat('##0').format(holding.gross), textAlign: TextAlign.end)),
        Expanded(child: Text(NumberFormat('##0').format(holding.netProfit), textAlign: TextAlign.end)),
        Expanded(child: Text('$changePercentage%', textAlign: TextAlign.end)),
      ],
    );
  }
}

class HoldingsWidget extends StatelessWidget {
  final List<HoldingStock>? holdings;
  final Map<String, StockQuote> stockQuotes;

  HoldingsWidget({super.key, this.holdings, required this.stockQuotes});

  @override
  Widget build(BuildContext context) {
    if (holdings == null || holdings!.isEmpty) return Container();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...holdings!.map((holding) {
          final spotPrice = double.parse(stockQuotes[holding.code]!.price ?? '0');
          final changePercentage = (spotPrice - holding.price) / holding.price * 100;
          final formattedChangePercentage = NumberFormat('#.##').format(changePercentage);
          final holdingPrice = NumberFormat('#.###').format(holding.price);
          final holdingGross = NumberFormat('#,###').format(holding.gross);
          final date = DateFormat('yy/MM/dd').format(holding.date);

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(holding.code),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(holding.side == Side.BUY ? '$formattedChangePercentage%' : '' ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(holdingPrice),
                  ),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      icon: const Icon(Icons.price_change_outlined),
                      onPressed: () => _showPriceChangesDialog(context, holding),
                  ),)
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text('$holdingGross (${holding.side == Side.BUY ? '+' : '-'}${holding.quantity})', textAlign: TextAlign.right),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(date, textAlign: TextAlign.right),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(holding.fundName ?? ''),
                      ],
                    ),
                  ),
                ],
              )
            ],
          );
        })
      ],
    );
  }

  void _showPriceChangesDialog(BuildContext context, HoldingStock holding) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: _buildHeader(context, holding),
          content: _buildContent(holding),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, HoldingStock holding) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${NumberFormat('###0.00').format(holding.price)} ${holding.side == Side.BUY ? '+' : '-'}${holding.quantity}',
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildContent(HoldingStock holding) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildListItem(holding.price * 1.06, '+6%'),
        _buildListItem(holding.price * 1.0262, '+2.62%'),
        _buildListItem(holding.price * 1.01618, '+1.618%'),
        _buildListItem(holding.price / 1.01618, '-1.618%'),
        _buildListItem(holding.price / 1.0262, '-2.62%'),
        _buildListItem(holding.price / 1.06, '-6%'),
      ],
    );
  }

  Widget _buildListItem(double value, String percentage) {
    return ListTile(
      title: Text(NumberFormat('###0.00').format(value)),
      trailing: Text(percentage),
    );
  }
}

class IndexesWidget extends StatelessWidget {
  final List<StockQuote>? indexQuotes;
  final List<String>? selectedIndexCode;
  const IndexesWidget({super.key, this.indexQuotes, this.selectedIndexCode});

  List<StockQuote> filteredIndexQuotes() {
    if (indexQuotes == null) return [];
    if (selectedIndexCode == null || selectedIndexCode!.isEmpty) return indexQuotes!;
    return indexQuotes!.where((index) => selectedIndexCode!.contains(index.stockCode)).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (indexQuotes == null || indexQuotes!.isEmpty) return Container();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...filteredIndexQuotes().map((quote) {
          final indexName = quote.stockCode.length > 6 ? quote.stockCode.substring(0, 6) : quote.stockCode;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Text(indexName),
              ),
              Expanded(
                flex: 2,
                child: Text('${quote.price} (${quote.change})', textAlign: TextAlign.right, ),
              ),
              Expanded(
                flex: 2,
                child: Text('${quote.low}-${quote.high}', textAlign: TextAlign.right),
              ),
            ],
          );
        })
      ],
    );
  }
}

class StockQuotesWidget extends StatelessWidget {
  final List<StockQuote>? stockQuotes;
  const StockQuotesWidget({super.key, this.stockQuotes});

  @override
  Widget build(BuildContext context) {
    if (stockQuotes == null || stockQuotes!.isEmpty) return Container();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...stockQuotes!.map((quote) {
          final price = double.tryParse(quote.price ?? '') ?? 0.0;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Text(quote.stockCode),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  NumberFormat('###,###.##').format(price),
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                flex: MediaQuery.of(context).size.width > 600 ? 1 : 0,
                child: Visibility(
                  visible: MediaQuery.of(context).size.width > 600, // Adjust breakpoint as needed
                  child: Text(quote.changeAmount.toString(), textAlign: TextAlign.right),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(quote.change.toString(), textAlign: TextAlign.right),
              ),
              Expanded(
                flex: 3,
                child: Text('${quote.low}-${quote.high}', textAlign: TextAlign.right),
              ),
              Expanded(
                flex: MediaQuery.of(context).size.width > 600 ? 1 : 0,
                child: Visibility(
                  visible: MediaQuery.of(context).size.width > 600, // Adjust breakpoint as needed
                  child: Text(' ${quote.lastUpdate?.split(' ')[1] ?? ''}', textAlign: TextAlign.right),
                ),
              ),
            ],
          );
        })
      ],
    );

  }
}

class MarketDailyReportsWidget extends StatelessWidget {
  const MarketDailyReportsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketDailyReportCubit, MarketDailyReportState>(builder: (context, state) {
      if (state is MarketDailyReportInitial) {
        return const CircularProgressIndicator();
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(flex: 1, child: Text('day before')),
              Expanded(flex: 2, child: Text('date')),
              Expanded(flex: 3, child: Text('HSI / PE / yield')),
              Expanded(flex: 3, child: Text('HSI / PE / yield')),
            ],
          ),
          ...state.reports.keys.map((key) {
            final report = state.reports[key];
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(flex: 1, child: Text(key)),
                Expanded(flex: 2, child: Text(report!.date.toString())),
                Expanded(flex: 3, child: Text('${report.hsi?.price ?? ''} / ${report.hsi?.pe ?? ''} / ${report.hsi?.yieldRate ?? ''}')),
                Expanded(flex: 3, child: Text('${report.hscei?.price ?? ''} / ${report.hscei?.pe ?? ''} / ${report.hscei?.yieldRate ?? ''}')),
              ],
            );
          })
        ],
      );
    },);
  }
}

