part of 'manage_holding_cubit.dart';

@immutable
sealed class ManageHoldingState {
  final List<HoldingStock> holdings;

  ManageHoldingState({List<HoldingStock>? holdings})
    : holdings = holdings ?? [];
}

final class ManageHoldingInitial extends ManageHoldingState {}

final class ManageHoldingLoaded extends ManageHoldingState {
  ManageHoldingLoaded({super.holdings});
}
