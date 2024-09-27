import 'dart:convert';

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_user.g.dart';

@immutable
@JsonSerializable()
class AuthUser {
  final String? email;
  final String idToken;
  final DateTime expiresAt;

  const AuthUser({
    required this.email,
    required this.idToken,
    required this.expiresAt,
  });

  factory AuthUser.fromAuth0(Credentials credentials)
     => AuthUser(email: credentials.user.email, idToken: credentials.idToken, expiresAt: credentials.expiresAt);

  @override
  String toString() => jsonEncode(toJson());
  factory AuthUser.fromJson(Map<String, dynamic> json) => _$AuthUserFromJson(json);
  Map<String, dynamic> toJson() => _$AuthUserToJson(this);
}
