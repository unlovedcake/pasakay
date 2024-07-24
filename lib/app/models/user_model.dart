import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String id;
  final String name;
  final String contact;
  final String email;
  final String fcmToken;
  final String image;

  UserData({
    required this.id,
    required this.name,
    required this.contact,
    required this.email,
    required this.fcmToken,
    required this.image,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      contact: json['contact'] ?? '',
      email: json['email'] ?? '',
      fcmToken: json['fcmToken'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'email': email,
      'fcmToken': fcmToken,
      'image': image,
    };
  }
}

class DriverData {
  final String id;
  final String name;
  final String contact;
  final String email;
  final String image;
  final String vehicleType;

  DriverData({
    required this.id,
    required this.name,
    required this.contact,
    required this.email,
    required this.image,
    required this.vehicleType,
  });

  factory DriverData.fromJson(Map<String, dynamic> json) {
    return DriverData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      contact: json['contact'] ?? '',
      email: json['email'] ?? '',
      image: json['image'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'email': email,
      'image': image,
      'vehicleType': vehicleType,
    };
  }
}

class UserModel {
  final UserData user;
  final DriverData driver;
  final String role;
  final DateTime createdAt;

  UserModel({
    required this.user,
    required this.driver,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      user: UserData.fromJson(json['user'] ?? {}),
      driver: DriverData.fromJson(json['driver'] ?? {}),
      role: json['role'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user': user.toMap(),
      'driver': driver.toMap(),
      'role': role,
      'createdAt': createdAt,
    };
  }
}
