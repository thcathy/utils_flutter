// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketDailyReport _$MarketDailyReportFromJson(Map<String, dynamic> json) =>
    MarketDailyReport(
      date: (json['date'] as num).toInt(),
      hsi: json['hsi'] == null
          ? null
          : StockQuote.fromJson(json['hsi'] as Map<String, dynamic>),
      hscei: json['hscei'] == null
          ? null
          : StockQuote.fromJson(json['hscei'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MarketDailyReportToJson(MarketDailyReport instance) =>
    <String, dynamic>{
      'date': instance.date,
      'hsi': instance.hsi,
      'hscei': instance.hscei,
    };

StockQuote _$StockQuoteFromJson(Map<String, dynamic> json) => StockQuote(
      stockCode: json['stockCode'] as String,
      stockName: json['stockName'] as String?,
      price: json['price'] as String?,
      pe: json['pe'] as String?,
      yieldRate: json['yield'] as String?,
      nav: json['nav'] as String?,
      change: json['change'] as String?,
      changeAmount: json['changeAmount'] as String?,
      low: json['low'] as String?,
      high: json['high'] as String?,
      lastUpdate: json['lastUpdate'] as String?,
    );

Map<String, dynamic> _$StockQuoteToJson(StockQuote instance) =>
    <String, dynamic>{
      'stockCode': instance.stockCode,
      'stockName': instance.stockName,
      'price': instance.price,
      'pe': instance.pe,
      'yield': instance.yieldRate,
      'nav': instance.nav,
      'change': instance.change,
      'changeAmount': instance.changeAmount,
      'low': instance.low,
      'high': instance.high,
      'lastUpdate': instance.lastUpdate,
    };
