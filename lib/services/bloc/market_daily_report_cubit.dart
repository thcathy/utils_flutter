import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/market_data.dart';
import '../stock_service.dart';

class MarketDailyReportCubit extends Cubit<MarketDailyReportState> {
  final StockService stockService;

  MarketDailyReportCubit(this.stockService) : super(MarketDailyReportInitial()) {
    stockService.getMarketDailyReport().then((reports) => receiveMarketReports(reports));
  }

  receiveMarketReports(Map<String, MarketDailyReport> reports) => emit(MarketDailyReportReceived(reports));
}

@immutable
sealed class MarketDailyReportState {
  final Map<String, MarketDailyReport> reports;
  const MarketDailyReportState(this.reports);
}

final class MarketDailyReportInitial extends MarketDailyReportState {
  MarketDailyReportInitial() : super({});
}

final class MarketDailyReportReceived extends MarketDailyReportState {
  MarketDailyReportReceived(super.reports);
}


