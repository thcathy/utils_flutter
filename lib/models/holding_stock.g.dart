// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holding_stock.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HoldingStock _$HoldingStockFromJson(Map<String, dynamic> json) => HoldingStock(
      id: json['id'] as String,
      code: json['code'] as String,
      quantity: (json['quantity'] as num).toInt(),
      gross: (json['gross'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      hsce: (json['hsce'] as num?)?.toDouble(),
      side: $enumDecode(_$SideEnumMap, json['side']),
      price: (json['price'] as num).toDouble(),
      fundName: json['fundName'] as String?,
      fees: (json['fees'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$HoldingStockToJson(HoldingStock instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'quantity': instance.quantity,
      'gross': instance.gross,
      'date': instance.date.toIso8601String(),
      'hsce': instance.hsce,
      'side': _$SideEnumMap[instance.side]!,
      'price': instance.price,
      'fundName': instance.fundName,
      'fees': instance.fees,
    };

const _$SideEnumMap = {
  Side.BUY: 'BUY',
  Side.SELL: 'SELL',
};
