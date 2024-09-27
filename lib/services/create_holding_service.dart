import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:utils_flutter/services/squote_base_service.dart';

import '../models/fund.dart';
import '../models/holding_stock.dart';

class CreateHoldingService extends SquoteBaseService {
  final String _createHoldingStockUrl = '/rest/createholding/create?';
  final String _updateFundByHoldingUrl = '/rest/createholding/updatefund?';

  CreateHoldingService({required super.idToken});

  Future<HoldingStock> createHoldingStock(String message, String hscei) async {
    final queryString = 'message=${Uri.encodeComponent(message)}&hscei=$hscei';
    final response = await http.get(Uri.parse('$baseUrl$_createHoldingStockUrl$queryString'), headers: buildHeaders());

    print('createHoldingStock response: ${response.body}');
    if (response.statusCode == 200) {
      return HoldingStock.fromJson(json.decode(response.body)); // Adjust according to your model
    } else {
      throw Exception('Failed to createHoldingStock');
    }
  }

  Future<Fund> updateFundByHolding(String fundName, String holdingId, {double fee = 0}) async {
    final queryString = 'fundName=$fundName&holdingId=${Uri.encodeComponent(holdingId)}&fee=$fee';
    print('updateFundByHolding query: $queryString');

    final response = await http.get(Uri.parse('$baseUrl$_updateFundByHoldingUrl$queryString'), headers: buildHeaders());

    if (response.statusCode == 200) {
      print('updateFundByHolding response: ${response.body}');
      return Fund.fromJson(json.decode(response.body)); // Adjust according to your model
    } else {
      throw Exception('Failed to updateFundByHolding. Response: ${response.statusCode} ${response.reasonPhrase}');
    }
  }
}
