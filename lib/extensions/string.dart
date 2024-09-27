import 'dart:convert';

extension ConvertJsonToList on String {
  List<String> asList() {
    try {
      return List<String>.from(json.decode(this));
    } catch (e) {
      return [];
    }
  }
}

extension ConvertListToJson on List<dynamic> {
  String asJson() => json.encode(this);
}
