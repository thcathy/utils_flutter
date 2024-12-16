import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/daily_asset_summary.dart';
import '../../models/holding_stock.dart';
import '../../models/market_data.dart';
import '../../models/side.dart';

class HoldingsWidget extends StatelessWidget {
  final List<HoldingStock>? holdings;
  final Map<String, StockQuote> stockQuotes;
  final Map<String, DailyAssetSummary> summaries;

  const HoldingsWidget({super.key, this.holdings, required this.stockQuotes, required this.summaries});

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
                    child: Text(holding.side == Side.BUY ? '$formattedChangePercentage%' : ''),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(holdingPrice),
                  ),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      icon: const Icon(Icons.price_change_outlined),
                      onPressed: () => _showPriceChangesDialog(context, holding, summaries[holding.code]),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text('$holdingGross (${holding.side == Side.BUY ? '+' : '-'}${holding.quantity})',
                        textAlign: TextAlign.right),
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

  void _showPriceChangesDialog(BuildContext context, HoldingStock holding, DailyAssetSummary? summary) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: _buildHeader(context, holding),
          content: _buildContent(holding, summary),
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

  Widget _buildContent(HoldingStock holding, DailyAssetSummary? summary) {
    const stdDevRange = 20;
    List<Widget> children = [];
    if (summary != null) {
      final stdDev = summary.stdDevs[stdDevRange] ?? 0;
      children.add(ListTile(title: Text('${stdDevRange}d sd = ${NumberFormat('###0.00').format(stdDev)}')));
      children.add(_buildListItem(holding.price * (1 + stdDev / 100), '+sd'));
      children.add(_buildListItem(holding.price * (1 + stdDev * 0.95 / 100), '+sd 0.95'));
      children.add(_buildListItem(holding.price / (1 + stdDev * 0.95 / 100), '-sd 0.95'));
      children.add(_buildListItem(holding.price / (1 + stdDev / 100), '-sd'));
      children.add(const Divider());
    }
    children.addAll([
      _buildListItem(holding.price * 1.06, '+6%'),
      _buildListItem(holding.price * 1.0262, '+2.62%'),
      _buildListItem(holding.price * 1.01618, '+1.618%'),
      _buildListItem(holding.price / 1.01618, '-1.618%'),
      _buildListItem(holding.price / 1.0262, '-2.62%'),
      _buildListItem(holding.price / 1.06, '-6%'),
    ]);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Widget _buildListItem(double value, String percentage) {
    return ListTile(
      title: Text(NumberFormat('###0.00').format(value)),
      trailing: Text(percentage),
    );
  }
}
