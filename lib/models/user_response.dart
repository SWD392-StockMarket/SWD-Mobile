import 'dart:convert';

class LoginResponse {
  final int userId;
  final String token;

  LoginResponse({
    required this.userId,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final tokenData = json['token']; // Access the nested object

    return LoginResponse(
      userId: tokenData['id'] ?? 0, // Provide default value if null
      token: tokenData['result'] ?? "", // Provide default value if null
    );
  }
}

class WatchListResponse{
  final int watchListId;
  final int userId;
  final String label;
  final String status;

  WatchListResponse({
    required this.userId,
    required this.watchListId,
    required this.label,
    required this.status,
  });

  factory WatchListResponse.fromJson(Map<String, dynamic> json) {
    return WatchListResponse(
      watchListId: json['watchListId'] ?? 0,
      userId: json['userId'] ?? 0,
      label: json['label'] ?? "",
      status: json['status'] ?? ""
    );
  }
}
