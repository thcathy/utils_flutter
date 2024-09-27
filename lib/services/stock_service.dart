import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:utils_flutter/services/squote_base_service.dart';

import '../models/holding_stock.dart';
import '../models/market_data.dart';

class StockService extends SquoteBaseService {
  final String _listHoldingUrl = '/rest/stock/holding/list';
  final String _deleteHoldingUrl = '/rest/stock/holding/delete/';
  final String _stockPerformanceUrl = '/rest/stock/liststocksperf';
  final String _marketDailyReportUrl = '/rest/stock/marketreports';
  final String _indexQuoteUrl = '/rest/stock/indexquotes';
  final String _fullQuoteUrl = '/rest/stock/fullquote';
  final String _saveQueryUrl = '/rest/stock/save/query';
  final String _loadQueryUrl = '/rest/stock/load/query';

  StockService({required super.idToken});

  Future<List<HoldingStock>> getStockHoldings() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$_listHoldingUrl'), headers: buildHeaders());
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => HoldingStock.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load stock holdings');
      }
    } catch (e, stack) {
      throw Exception('Failed to load funds: $e \n $stack');
    }
  }

  Future<List<HoldingStock>> deleteStockHolding(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$_deleteHoldingUrl$id'), headers: buildHeaders());
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => HoldingStock.fromJson(item)).toList();
      } else {
        throw Exception('Failed to delete stock holding');
      }
    } catch (e, stack) {
      throw Exception('Failed to load funds: $e \n $stack');
    }
  }

  // Future<List<StockQuote>> getStockPerformanceQuotes() async {
  //   try {
  //     final response = await http.get(Uri.parse(stockPerformanceUrl), headers: buildHeaders());
  //     if (response.statusCode == 200) {
  //       List<dynamic> data = json.decode(response.body);
  //       return data.map((item) => StockQuote.fromJson(item)).toList();
  //     } else {
  //       throw Exception('Failed to load stock performance quotes');
  //     }
  //   } catch (error) {
  //     handleError(error);
  //     return [];
  //   }
  // }

  Future<Map<String, MarketDailyReport>> getMarketDailyReport() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$_marketDailyReportUrl'), headers: buildHeaders());
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return data.map((key, value) => MapEntry(key, MarketDailyReport.fromJson(value)));
      } else {
        throw Exception('Failed to load market daily report. StatusCode=${response.statusCode}');
      }
    } catch (e, stack) {
      throw Exception('Failed to getMarketDailyReport: $e \n $stack');
    }
  }

  Future<Map<String, dynamic>> getFullQuote({String codes = ''}) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$_fullQuoteUrl?codes=$codes'), headers: buildHeaders());
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to load full quote');
      }
    } catch (e, stack) {
      throw Exception('Failed to load funds: $e \n $stack');
    }
  }

  // Future<List<StockQuote>> getIndexQuotes() async {
  //   try {
  //     final response = await http.get(Uri.parse(indexQuoteUrl));
  //     if (response.statusCode == 200) {
  //       List<dynamic> data = json.decode(response.body);
  //       return data.map((item) => StockQuote.fromJson(item)).toList();
  //     } else {
  //       throw Exception('Failed to load index quotes');
  //     }
  //   } catch (error) {
  //     handleError(error);
  //     return [];
  //   }
  // }

  Future<String> saveQuery({String codes = ''}) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$_saveQueryUrl?codes=$codes'), headers: buildHeaders());
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to save query');
      }
    } catch (e, stack) {
      throw Exception('Failed to load funds: $e \n $stack');
    }
  }

  Future<String> loadQuery() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$_loadQueryUrl'), headers: buildHeaders());
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to load query');
      }
    } catch (e, stack) {
      throw Exception('Failed to load funds: $e \n $stack');
    }
  }

}
