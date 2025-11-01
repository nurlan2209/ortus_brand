class UserModel {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String email;
  final String userType;

  UserModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.userType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      email: json['email'] ?? '',
      userType: json['userType'],
    );
  }

  bool get isAdmin => userType == 'admin';
}
