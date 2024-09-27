import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'fund_holding.g.dart';

@JsonSerializable()
class FundHolding {
  final String code;
  final double quantity;
  final double gross;
  final DateTime date;
  final double price;
  final double? netProfit;
  late int latestTradeTime;

  FundHolding({required this.code, required this.quantity, required this.gross, required this.date, required this.price, this.netProfit});

  factory FundHolding.fromJson(Map<String, dynamic> json) => _$FundHoldingFromJson(json);
  Map<String, dynamic> toJson() => _$FundHoldingToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
