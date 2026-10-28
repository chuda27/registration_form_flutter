import 'dart:convert';

import 'package:registration_flutter/models/user.dart';

class UserResponse {
  int code;
  String status;
  // ignore: non_constant_identifier_names
  List<User> user_list;
  UserResponse({
    required this.code,
    required this.status,
    // ignore: non_constant_identifier_names
    required this.user_list,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'status': status,
      'user_list': user_list.map((x) => x.toMap()).toList(),
    };
  }

  factory UserResponse.fromMap(Map<String, dynamic> map) {
    return UserResponse(
      code: map['code']?.toInt() ?? 0,
      status: map['status'] ?? '',
      user_list: List<User>.from(map['user_list']?.map((x) => User.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserResponse.fromJson(String source) =>
      UserResponse.fromMap(json.decode(source));
}
