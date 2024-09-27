part of 'full_quote_settings_cubit.dart';

@immutable
final class FullQuoteSettingsState {
  final bool showMore;
  final List<TextEditingController> stockCodesControllers;
  final Map<String, bool> indexCodes;
  final String? snackMessage;

  const FullQuoteSettingsState({
    this.showMore = false,
    required this.stockCodesControllers,
    required this.indexCodes,
    this.snackMessage,
  });

  FullQuoteSettingsState copyWith({
    bool? showMore,
    List<TextEditingController>? stockCodesControllers,
    Map<String, bool>? indexCodes,
    String? snackMessage,
  }) {
    return FullQuoteSettingsState(
      showMore: showMore ?? this.showMore,
      stockCodesControllers: stockCodesControllers ?? this.stockCodesControllers,
      indexCodes: indexCodes ?? this.indexCodes,
      snackMessage: snackMessage ?? this.snackMessage,
    );
  }
}
