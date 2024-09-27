import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:utils_flutter/models/holding_stock.dart';
import 'package:utils_flutter/models/holding_stock.dart';
import 'package:utils_flutter/services/create_holding_service.dart';
import 'package:utils_flutter/services/fund_service.dart';

import '../../models/fund.dart';

part 'create_holding_state.dart';

class CreateHoldingCubit extends Cubit<CreateHoldingState> {
  final CreateHoldingService createHoldingService;
  final FundService fundService;

  CreateHoldingCubit(this.createHoldingService, this.fundService) : super(CreateHoldingInitial());

  clear() {
    emit(CreateHoldingInitial());
  }

  holdingCreated(String execMessage, HoldingStock holding, List<Fund> funds) {
    emit(CreateHoldingSuccess(execMessage: execMessage, holding: holding, funds: funds));
  }

  receiveError(Object error, StackTrace stackTrace) {
    return '$error\n $stackTrace';
  }

  submit(String execMessage) async {
    try {
      final holding = await createHoldingService.createHoldingStock(execMessage, '');
      final funds = await fundService.getFunds();
      holdingCreated(execMessage, holding, funds);
    } catch (e, st) {
      receiveError(e, st);
    }
  }

  selectFund(Fund fund) {
    if (state is CreateHoldingSuccess)
    {
      final successState = state as CreateHoldingSuccess;
      emit(successState.copyWith(selectedFund: fund));
    }
  }

  selectFee(double? fee) {
    if (state is CreateHoldingSuccess)
    {
      final successState = state as CreateHoldingSuccess;
      emit(successState.copyWith(selectedFee: fee));
    }
  }

  updateFundByHolding(double fee) async {
    if (state is !CreateHoldingSuccess) return;

    final successState = state as CreateHoldingSuccess;

    try {
      final updatedFund = await createHoldingService.updateFundByHolding(successState.selectedFund!.name, successState.holding.id, fee: fee);
      emit(successState.copyWith(updatedFund: updatedFund));
    } catch (e, st) {
      receiveError(e, st);
    }
  }
}
