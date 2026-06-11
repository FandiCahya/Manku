// Domain models for the Auth feature.

class UserModel {
  final String name;
  final String email;
  final String? photoUrl;

  const UserModel({
    required this.name,
    required this.email,
    this.photoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      photoUrl: json['photo'] as String?,
    );
  }
}

class TokenModel {
  final String access;
  final String refresh;

  const TokenModel({required this.access, required this.refresh});

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
    );
  }
}

class AuthResult {
  final TokenModel tokens;
  final UserModel? user;
  final String? message;

  const AuthResult({required this.tokens, this.user, this.message});
}
