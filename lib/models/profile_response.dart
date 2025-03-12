class UserResponse {
  final int? id;
  final String? userName;
  final String? email;
  final String? status;
  final String? phoneNumber;
  final String? createdAt;
  final String? lastEdited;
  final String? subscriptionStatus;

  UserResponse({
    required this.id,
     this.userName,
     this.email,
     this.status,
     this.phoneNumber,
     this.createdAt,
     this.lastEdited,
     this.subscriptionStatus,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] ?? 1, // Giá trị mặc định nếu id null
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
