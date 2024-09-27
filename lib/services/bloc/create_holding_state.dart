part of 'create_holding_cubit.dart';

@immutable
sealed class CreateHoldingState {
  final String errorMessage;
  final String execMessage;

  const CreateHoldingState({execMessage, errorMessage})
      : execMessage = execMessage ?? '',
        errorMessage = errorMessage ?? '';
}

final class CreateHoldingInitial extends CreateHoldingState {}

final class CreateHoldingSuccess extends CreateHoldingState {
  final HoldingStock holding;
  final List<Fund> funds;
  final Fund? selectedFund;
  final double? selectedFee;
  final Fund? updatedFund;

  const CreateHoldingSuccess({
    super.execMessage,
    required this.holding,
    required this.funds,
    this.selectedFund,
    this.selectedFee,
    this.updatedFund,
  });

  CreateHoldingSuccess copyWith({
    String? execMessage,
    HoldingStock? holding,
    List<Fund>? funds,
    Fund? selectedFund,
    double? selectedFee,
    Fund? updatedFund,
  }) {
    return CreateHoldingSuccess(
      execMessage: execMessage ?? this.execMessage,
      holding: holding ?? this.holding,
      funds: funds ?? this.funds,
      selectedFund: selectedFund ?? this.selectedFund,
      selectedFee: selectedFee ?? this.selectedFee,
      updatedFund: updatedFund ?? this.updatedFund,
    );
  }
}
