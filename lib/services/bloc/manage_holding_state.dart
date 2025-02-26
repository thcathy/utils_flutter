part of 'manage_holding_cubit.dart';

@immutable
class ManageHoldingState {
  final List<HoldingStock> holdings;
  final List<HoldingStock> selectedHoldings;
  final HoldingStock? possibleHolding;
  final String selectedFundName;

  ManageHoldingState({List<HoldingStock>? holdings, List<HoldingStock>? selectedHoldings, this.possibleHolding, String? selectedFundName}) :
        holdings = holdings ?? [],
        selectedHoldings = selectedHoldings ?? [],
        selectedFundName = selectedFundName ?? '';

  ManageHoldingState copyWith({
    List<HoldingStock>? holdings,
    List<HoldingStock>? selectedHoldings,
    HoldingStock? possibleHolding,
    String? selectedFundName,
  }) {
    return ManageHoldingState(
      holdings: holdings ?? this.holdings,
      selectedHoldings: selectedHoldings ?? this.selectedHoldings,
      possibleHolding: possibleHolding ?? this.possibleHolding,
      selectedFundName: selectedFundName ?? this.selectedFundName,
    );
  }
}

final class ManageHoldingInitial extends ManageHoldingState {}

final class ManageHoldingLoaded extends ManageHoldingState {
  ManageHoldingLoaded({super.holdings, super.selectedFundName});
}
