import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:utils_flutter/services/stock_service.dart';

@immutable
class StockTradingTaskState {
  final bool? isEnabled;

  StockTradingTaskState(this.isEnabled);
}

class StockTradingTaskCubit extends Cubit<StockTradingTaskState> {
  final StockService stockService;

  StockTradingTaskCubit(this.stockService) : super(StockTradingTaskState(null)) {
    stockService.getStockTradingEnable().then((isEnabled) => receiveFlag(isEnabled));
  }

  receiveFlag(bool isEnabled) {
    emit(StockTradingTaskState(isEnabled));
  }

  updateFlag(bool isEnabled) {
    stockService.setStockTradingTaskEnable(isEnabled)
        .then((_) => stockService.getStockTradingEnable())
        .then((isEnabled) => receiveFlag(isEnabled));
  }
}
