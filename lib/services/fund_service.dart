import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:utils_flutter/services/squote_base_service.dart';

import '../models/fund.dart';

class FundService extends SquoteBaseService {
  final String _allFundUrl = '/rest/fund/getall';
  final String _baseRequestUrl = '/rest/fund/';
  
  FundService({required super.idToken});

  Future<List<Fund>> getFunds() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$_allFundUrl'), headers: buildHeaders());
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Fund.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load funds: http code=${response.statusCode}');
      }
    } catch (e, stack) {
      throw Exception('Failed to load funds: $e \n $stack');
    }
  }

  Future<String> submitRequest(String request) async {
    if (request.endsWith('/')) {
      request = request.substring(0, request.length - 1);
    }

    print('Calling fund request URL: $baseUrl$_baseRequestUrl$request');

    try {
      final response = await http.get(Uri.parse('$baseUrl$_baseRequestUrl$request'), headers: buildHeaders());
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return 'Request failed: http code=${response.statusCode}';
      }
    } catch (error, stack) {
      return 'Request failed:: $error \n $stack';
    }
  }
}
