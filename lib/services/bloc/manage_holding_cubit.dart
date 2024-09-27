import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:utils_flutter/models/holding_stock.dart';
import 'package:utils_flutter/services/stock_service.dart';

part 'manage_holding_state.dart';

class ManageHoldingCubit extends Cubit<ManageHoldingState> {
  final StockService stockService;

  ManageHoldingCubit(this.stockService) : super(ManageHoldingInitial()) {
    stockService.getStockHoldings().then((holdings) => receiveStockHoldings(holdings));
  }

  receiveStockHoldings(List<HoldingStock> holdings) {
    emit(ManageHoldingLoaded(holdings: holdings));
  }

  deleteHolding(String id) {
    stockService.deleteStockHolding(id).then((holdings) => receiveStockHoldings(holdings));
  }
}
