import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:utils_flutter/models/fund_holding.dart';

part 'market_data.g.dart';

@JsonSerializable()
class MarketDailyReport {
  final int date;
  final StockQuote? hsi;
  final StockQuote? hscei;

  MarketDailyReport({
    required this.date,
    this.hsi,
    this.hscei,
  });

  @override
  String toString() => jsonEncode(toJson());
  factory MarketDailyReport.fromJson(Map<String, dynamic> json) => _$MarketDailyReportFromJson(json);
  Map<String, dynamic> toJson() => _$MarketDailyReportToJson(this);
}

@JsonSerializable()
class StockQuote {
  final String stockCode;
  final String? stockName;
  final String? price;
  final String? pe;
  @JsonKey(name: 'yield')
  final String? yieldRate; // Changed to avoid conflict with Dart keyword
  final String? nav;
  final String? change;
  final String? changeAmount;
  final String? low;
  final String? high;
  final String? lastUpdate;

  StockQuote({
    required this.stockCode,
    this.stockName,
    this.price,
    this.pe,
    this.yieldRate,
    this.nav,
    this.change,
    this.changeAmount,
    this.low,
    this.high,
    this.lastUpdate,
  });

  @override
  String toString() => jsonEncode(toJson());
  factory StockQuote.fromJson(Map<String, dynamic> json) => _$StockQuoteFromJson(json);
  Map<String, dynamic> toJson() => _$StockQuoteToJson(this);
}
