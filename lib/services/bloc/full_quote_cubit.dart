import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utils_flutter/extensions/string.dart';
import 'package:utils_flutter/models/holding_stock.dart';

import '../../models/fund.dart';
import '../../models/market_data.dart';
import '../stock_service.dart';

class FullQuoteCubit extends Cubit<FullQuoteState> {
  final stockCodesKey = 'CodesKey';
  final indexCodesKey = 'IndexCodesKey';
  final StockService stockService;
  late final SharedPreferences prefs;

  FullQuoteCubit(this.stockService) : super(const FullQuoteState(loading: true)) {
    init();
  }

  init() async {
    prefs = await SharedPreferences.getInstance();
    getFullQuote();
  }

  getFullQuote() {
    emit(state.copyWith(loading: true));
    final stockCodes = (prefs.getString(stockCodesKey) ?? '').asList().join(',');
    stockService.getFullQuote(codes: stockCodes).then((results) => receiveFullQuotes(results));
  }

  stockQuoteSelect(List<String> stockCodes, List<String> selectedIndexCodes) {
    prefs.setString(stockCodesKey, stockCodes.asJson());
    prefs.setString(indexCodesKey, selectedIndexCodes.asJson());
    getFullQuote();
  }

  receiveFullQuotes(Map<String, dynamic> results) async {
    final selectedIndexCodes = (prefs.getString(indexCodesKey) ?? '').asList();

    final indexQuotes = (results['indexes'] as List<dynamic>).map((item) => StockQuote.fromJson(item as Map<String, dynamic>)).toList();
    final stockQuotes = (results['quotes'] as List<dynamic>).map((item) => StockQuote.fromJson(item as Map<String, dynamic>)).toList();
    final holdings = (results['holdings'] as List<dynamic>).map((item) => HoldingStock.fromJson(item as Map<String, dynamic>)).toList();
    final allQuotes = (results['allQuotes'] as Map<String, dynamic>).map((key, value) => MapEntry(key, StockQuote.fromJson(value)));
    final funds = (results['funds'] as List<dynamic>).map((item) => Fund.fromJson(item as Map<String, dynamic>)).toList();

    emit(FullQuoteState(
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
  final List<Fund>? funds;
  final bool loading;

  const FullQuoteState({this.indexQuotes, this.stockQuotes, this.selectedIndexCodes
    , this.holdings, this.allQuotes, this.funds, required this.loading});

  FullQuoteState copyWith({
    List<StockQuote>? indexQuotes,
    List<StockQuote>? stockQuotes,
    List<String>? selectedIndexCodes,
    List<HoldingStock>? holdings,
    Map<String, StockQuote>? allQuotes,
    List<Fund>? funds,
    bool? loading,
  }) {
    return FullQuoteState(
      indexQuotes: indexQuotes ?? this.indexQuotes,
      stockQuotes: stockQuotes ?? this.stockQuotes,
      selectedIndexCodes: selectedIndexCodes ?? this.selectedIndexCodes,
      holdings: holdings ?? this.holdings,
      allQuotes: allQuotes ?? this.allQuotes,
      funds: funds ?? this.funds,
      loading: loading ?? this.loading,
    );
  }
}
