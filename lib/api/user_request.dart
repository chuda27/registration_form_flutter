import 'dart:convert';

class UserRequest {
  int code;
  String status;
  UserRequest({required this.code, required this.status});

  Map<String, dynamic> toMap() {
    return {'code': code, 'status': status};
  }

  factory UserRequest.fromMap(Map<String, dynamic> map) {
    return UserRequest(
      code: map['code']?.toInt() ?? 0,
      status: map['status'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserRequest.fromJson(String source) =>
      UserRequest.fromMap(json.decode(source));
}
