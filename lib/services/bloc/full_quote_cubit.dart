import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utils_flutter/extensions/string.dart';
import 'package:utils_flutter/models/daily_asset_summary.dart';
import 'package:utils_flutter/models/holding_stock.dart';

import '../../models/fund.dart';
import '../../models/market_data.dart';
import '../stock_service.dart';

class FullQuoteCubit extends Cubit<FullQuoteState> {
  final stockCodesKey = 'CodesKey';
  final indexCodesKey = 'IndexCodesKey';
  final showMoreKey = 'ShowMoreKey';
  final StockService stockService;
  late final SharedPreferences prefs;

  FullQuoteCubit(this.stockService) : super(FullQuoteState(loading: true)) {
    init();
  }

  init() async {
    prefs = await SharedPreferences.getInstance();
    getFullQuote();
  }

  getFullQuote() {
    final stockCodes = (prefs.getString(stockCodesKey) ?? '').asList();
    final stockCodesString = stockCodes.join(',');
    stockService.getFullQuote(codes: stockCodesString).then((results) => receiveFullQuotes(results));
    stockService.getDailyAssetSummaries(stockCodes).then((result) => receiveSummaries(result));
  }

  stockQuoteSelect(List<String> stockCodes, List<String> selectedIndexCodes, bool showMore) {
    prefs.setString(stockCodesKey, stockCodes.asJson());
    prefs.setString(indexCodesKey, selectedIndexCodes.asJson());
    emit(state.copyWith(loading: true, showMore: showMore));
    getFullQuote();
  }

  receiveSummaries(Map<String, DailyAssetSummary> summaries) {
    emit(state.copyWith(assetSummaries: summaries));
  }

  receiveFullQuotes(Map<String, dynamic> results) async {
    final selectedIndexCodes = (prefs.getString(indexCodesKey) ?? '').asList();

    final indexQuotes = (results['indexes'] as List<dynamic>).map((item) => StockQuote.fromJson(item as Map<String, dynamic>)).toList();
    final stockQuotes = (results['quotes'] as List<dynamic>).map((item) => StockQuote.fromJson(item as Map<String, dynamic>)).toList();
    final holdings = (results['holdings'] as List<dynamic>).map((item) => HoldingStock.fromJson(item as Map<String, dynamic>)).toList();
    final allQuotes = (results['allQuotes'] as Map<String, dynamic>).map((key, value) => MapEntry(key, StockQuote.fromJson(value)));
    final funds = (results['funds'] as List<dynamic>).map((item) => Fund.fromJson(item as Map<String, dynamic>)).toList();

    emit(state.copyWith(
      indexQuotes: indexQuotes,
      stockQuotes: stockQuotes,
      allQuotes: allQuotes,
      selectedIndexCodes: selectedIndexCodes,
      holdings: holdings,
      funds: funds,
      loading: false,
    ));
  }
}

@immutable
class FullQuoteState {
  final List<StockQuote>? indexQuotes;
  final List<StockQuote>? stockQuotes;
  final List<String>? selectedIndexCodes;
  final List<HoldingStock>? holdings;
  final Map<String, StockQuote>? allQuotes;
  final Map<String, DailyAssetSummary> assetSummaries;
  final List<Fund>? funds;
  final bool loading;
  final bool showMore;

  FullQuoteState({
    this.indexQuotes,
    this.stockQuotes,
    this.selectedIndexCodes,
    this.holdings,
    this.allQuotes,
    this.funds,
    required this.loading,
    this.showMore = false,
    Map<String, DailyAssetSummary>? assetSummaries,
  }) : assetSummaries = assetSummaries ?? {};

  FullQuoteState copyWith({
    List<StockQuote>? indexQuotes,
    List<StockQuote>? stockQuotes,
    List<String>? selectedIndexCodes,
    List<HoldingStock>? holdings,
    Map<String, StockQuote>? allQuotes,
    Map<String, DailyAssetSummary>? assetSummaries,
    List<Fund>? funds,
    bool? loading,
    bool? showMore,
  }) {
    return FullQuoteState(
      indexQuotes: indexQuotes ?? this.indexQuotes,
      stockQuotes: stockQuotes ?? this.stockQuotes,
      selectedIndexCodes: selectedIndexCodes ?? this.selectedIndexCodes,
      holdings: holdings ?? this.holdings,
      allQuotes: allQuotes ?? this.allQuotes,
      assetSummaries: assetSummaries ?? this.assetSummaries,
      funds: funds ?? this.funds,
      loading: loading ?? this.loading,
      showMore: showMore ?? this.showMore,
    );
  }
}
