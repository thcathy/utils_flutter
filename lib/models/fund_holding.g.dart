// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fund_holding.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FundHolding _$FundHoldingFromJson(Map<String, dynamic> json) => FundHolding(
      code: json['code'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      gross: (json['gross'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      price: (json['price'] as num).toDouble(),
      netProfit: (json['netProfit'] as num?)?.toDouble(),
    )..latestTradeTime = (json['latestTradeTime'] as num).toInt();

Map<String, dynamic> _$FundHoldingToJson(FundHolding instance) =>
    <String, dynamic>{
      'code': instance.code,
      'quantity': instance.quantity,
      'gross': instance.gross,
      'date': instance.date.toIso8601String(),
      'price': instance.price,
      'netProfit': instance.netProfit,
      'latestTradeTime': instance.latestTradeTime,
    };
