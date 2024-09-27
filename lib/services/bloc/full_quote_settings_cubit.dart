import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:utils_flutter/extensions/string.dart';
import 'package:utils_flutter/services/stock_service.dart';

part 'full_quote_settings_state.dart';

class FullQuoteSettingsCubit extends Cubit<FullQuoteSettingsState> {
  final List<String> stockCodes;
  final Map<String, bool> indexCodes;

  final StockService stockService;

  FullQuoteSettingsCubit(this.stockService, this.stockCodes, this.indexCodes)
      : super(FullQuoteSettingsState(stockCodesControllers: const [], indexCodes: indexCodes)) {
    stockCodesLoaded(stockCodes);
  }

  showMoreChanged(bool value) => emit(state.copyWith(showMore: value));

  stockCodesLoaded(List<String> codes, {String? snackMessage}) {
    final controllers = codes.map((code) {
      final controller = TextEditingController();
      controller.text = code;
      return controller;
    }).toList();
    emit(state.copyWith(stockCodesControllers: controllers, snackMessage: snackMessage));
  }

  stockCodesSaved() {
    emit(state.copyWith(snackMessage: 'stock code saved'));
  }

  removeCodeControllerAt(int pos) {
    state.stockCodesControllers.removeAt(pos);
    emit(state.copyWith(stockCodesControllers: state.stockCodesControllers));
  }

  addStockCode() {
    state.stockCodesControllers.add(TextEditingController());
    emit(state.copyWith(stockCodesControllers: state.stockCodesControllers));
  }

  saveStockCodesToServer() {
    final codesAsJson = state.stockCodesControllers.map((c) => c.text).where((t) => t.isNotEmpty).toSet().toList().asJson();
    stockService.saveQuery(codes: codesAsJson).then((s) {
      if (s.isNotEmpty) stockCodesSaved();
    });
  }

  loadStockCodesFromServer() {
    stockService.loadQuery().then((codes) => stockCodesLoaded(
          codes.asList(),
          snackMessage: 'stock code loaded',
        ));
  }

  indexCodeChanged(String key, bool value) {
    state.indexCodes[key] = value;
    emit(state.copyWith(indexCodes: state.indexCodes));
  }
}
