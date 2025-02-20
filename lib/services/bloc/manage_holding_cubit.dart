import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:utils_flutter/models/holding_stock.dart';
import 'package:utils_flutter/services/stock_service.dart';

import '../../models/side.dart';

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

  selectFundName(String? fundName) {
    emit(ManageHoldingState(holdings: state.holdings, selectedHoldings: null, possibleHolding: null, selectedFundName: fundName));
  }

  selectHolding(HoldingStock holding) {
    if (state.selectedHoldings.any((h) => h.id == holding.id)) {
      state.selectedHoldings.remove(holding);
      emit(ManageHoldingState(holdings: state.holdings, selectedHoldings: state.selectedHoldings, possibleHolding: null, selectedFundName: state.selectedFundName)
      );
      return;
    }

    if (state.selectedHoldings.length == 1) {
      state.selectedHoldings.add(holding);
      emit(ManageHoldingState(holdings: state.holdings, selectedHoldings: state.selectedHoldings, possibleHolding: null, selectedFundName: state.selectedFundName)
      );
      return;
    }

    var possibleHoldings = state.holdings.where((h) {
      if (h.quantity != holding.quantity || h.code != holding.code) {
        return false;
      }

      if (holding.side == Side.SELL) {
        return h.side == Side.BUY && h.price < holding.price;
      } else {
        return h.side == Side.SELL && h.price > holding.price;
      }
    }).toList();

    possibleHoldings.sort((a, b) {
      if (holding.side == Side.SELL) {
        return a.price.compareTo(b.price);
      } else {
        return b.price.compareTo(a.price);
      }
    });

    emit(ManageHoldingState(holdings: state.holdings, selectedHoldings: [holding],
        possibleHolding: possibleHoldings.isNotEmpty ? possibleHoldings.first : null,
        selectedFundName: state.selectedFundName)
    );
  }
}
