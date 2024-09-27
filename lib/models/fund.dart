import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:utils_flutter/models/fund_holding.dart';

part 'fund.g.dart';

@JsonSerializable()
class Fund {
  final String name;
  final String type;
  final DateTime date;
  final double? profit;
  final double? netProfit;
  final double? cashoutAmount;
  final Map<String, FundHolding> holdings;
  final double? cashinAmount;

  Fund({
    required this.name,
    required this.date,
    required this.profit,
    required this.netProfit,
    required this.cashoutAmount,
    required this.holdings,
    required this.type,
    this.cashinAmount,
  });

  @override
  String toString() => jsonEncode(toJson());

  factory Fund.fromJson(Map<String, dynamic> json) => _$FundFromJson(json);
  Map<String, dynamic> toJson() => _$FundToJson(this);
}
