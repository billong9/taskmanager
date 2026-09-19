class AuthUser {
  final String token;
  final int userId;
  final String fullName;
  final String email;

  AuthUser({
    required this.token,
    required this.userId,
    required this.fullName,
    required this.email,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      token: json['token'],
      userId: json['userId'],
      fullName: json['fullName'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'userId': userId,
        'fullName': fullName,
        'email': email,
      };
}
