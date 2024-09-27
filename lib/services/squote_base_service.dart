import 'package:flutter_dotenv/flutter_dotenv.dart';

class SquoteBaseService {
  late final String baseUrl;
  final String idToken;

  SquoteBaseService({required this.idToken}) {
    baseUrl = dotenv.get('SERVER_HOST');
  }

  Map<String, String> buildHeaders() {
    return {
      'Authorization': 'Bearer $idToken',
      'Content-Type': 'application/json',
    };
  }
}
