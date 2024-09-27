// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fund.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Fund _$FundFromJson(Map<String, dynamic> json) => Fund(
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      profit: (json['profit'] as num?)?.toDouble(),
      netProfit: (json['netProfit'] as num?)?.toDouble(),
      cashoutAmount: (json['cashoutAmount'] as num?)?.toDouble(),
      holdings: (json['holdings'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, FundHolding.fromJson(e as Map<String, dynamic>)),
      ),
      type: json['type'] as String,
      cashinAmount: (json['cashinAmount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$FundToJson(Fund instance) => <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'date': instance.date.toIso8601String(),
      'profit': instance.profit,
      'netProfit': instance.netProfit,
      'cashoutAmount': instance.cashoutAmount,
      'holdings': instance.holdings,
      'cashinAmount': instance.cashinAmount,
    };
