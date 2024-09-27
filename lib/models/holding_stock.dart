import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:utils_flutter/models/side.dart';

part 'holding_stock.g.dart';

@JsonSerializable()
class HoldingStock {
  final String id;
  final String code;
  final int quantity;
  final double gross;
  final DateTime date;
  final double? hsce;
  final Side side;
  final double price;
  final String? fundName;
  final Map<String, double>? fees;

  HoldingStock({
    required this.id,
    required this.code,
    required this.quantity,
    required this.gross,
    required this.date,
    this.hsce,
    required this.side,
    required this.price,
    this.fundName,
    this.fees,
  });

  factory HoldingStock.fromJson(Map<String, dynamic> json) => _$HoldingStockFromJson(json);

  Map<String, dynamic> toJson() => _$HoldingStockToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
