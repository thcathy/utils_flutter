// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_asset_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyAssetSummary _$DailyAssetSummaryFromJson(Map<String, dynamic> json) =>
    DailyAssetSummary(
      symbol: json['symbol'] as String,
      date: DateTime.parse(json['date'] as String),
      stdDevs: (json['stdDevs'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(int.parse(k), (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$DailyAssetSummaryToJson(DailyAssetSummary instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'date': instance.date.toIso8601String(),
      'stdDevs': instance.stdDevs.map((k, e) => MapEntry(k.toString(), e)),
    };
