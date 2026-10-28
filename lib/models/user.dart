import 'dart:convert';

class User {
  String user_fullname;
  String user_email;
  String user_birthdate;
  String user_gender;
  String user_password;
  User({
    required this.user_fullname,
    required this.user_email,
    required this.user_birthdate,
    required this.user_gender,
    required this.user_password,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_fullname': user_fullname,
      'user_email': user_email,
      'user_birthdate': user_birthdate,
      'user_gender': user_gender,
      'user_password': user_password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      user_fullname: map['user_fullname'] ?? '',
      user_email: map['user_email'] ?? '',
      user_birthdate: map['user_birthdate'] ?? '',
      user_gender: map['user_gender'] ?? '',
      user_password: map['user_password'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}
