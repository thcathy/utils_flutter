import 'package:json_annotation/json_annotation.dart';

part 'daily_asset_summary.g.dart';

@JsonSerializable()
class DailyAssetSummary {
  String symbol;
  DateTime date;
  Map<int, double> stdDevs;

  DailyAssetSummary({
    required this.symbol,
    required this.date,
    Map<int, double>? stdDevs,
  }) : stdDevs = stdDevs ?? {};

  factory DailyAssetSummary.fromJson(Map<String, dynamic> json) =>
      _$DailyAssetSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$DailyAssetSummaryToJson(this);
}
