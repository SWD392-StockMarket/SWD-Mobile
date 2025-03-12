class UserResponse {
  final int id;
  final String userName;
  final String email;
  final String status;
  final String phoneNumber;
  final String createdAt;
  final String lastEdited;
  final String subscriptionStatus;

  UserResponse({
    required this.id,
    required this.userName,
    required this.email,
    required this.status,
    required this.phoneNumber,
    required this.createdAt,
    required this.lastEdited,
    required this.subscriptionStatus,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'],
      userName: json['userName'],
      email: json['email'],
      status: json['status'],
      phoneNumber: json['phoneNumber'],
      createdAt: json['createdAt'],
      lastEdited: json['lastEdited'],
      subscriptionStatus: json['subscriptionStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'email': email,
      'status': status,
      'createdAt': createdAt,
      'lastEdited': lastEdited,
      'subscriptionStatus': subscriptionStatus,
      'phoneNumber': phoneNumber,
    };
  }
}
