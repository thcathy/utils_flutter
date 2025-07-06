import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:utils_flutter/services/stock_service.dart';

@immutable
class StockTradingTaskState {
  final Map<String, bool>? enabledByMarket;

  StockTradingTaskState(this.enabledByMarket);
}

class StockTradingTaskCubit extends Cubit<StockTradingTaskState> {
  final StockService stockService;

  StockTradingTaskCubit(this.stockService) : super(StockTradingTaskState(null)) {
    stockService.getStockTradingEnable().then((isEnabled) => receiveFlag(isEnabled));
  }

  receiveFlag(Map<String, bool> enabledByMarket) {
    emit(StockTradingTaskState(enabledByMarket));
  }

  updateFlag(String market, bool isEnabled) {
    stockService.setStockTradingTaskEnable(market, isEnabled)
        .then((_) => stockService.getStockTradingEnable())
        .then((isEnabled) => receiveFlag(isEnabled));
  }
}
