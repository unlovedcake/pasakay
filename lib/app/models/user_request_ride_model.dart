import 'package:cloud_firestore/cloud_firestore.dart';

class UserRequestRideModel {
  final String contact;
  final DateTime createdAt;
  final double distance;
  final Driver driver;
  final String fcmToken;
  final String from;
  final String id;
  final String isRequestAccept;
  final String name;
  final Position position;
  final String requestId;
  final String to;
  final String vehicyleType;

  UserRequestRideModel({
    required this.contact,
    required this.createdAt,
    required this.distance,
    required this.driver,
    required this.fcmToken,
    required this.from,
    required this.id,
    required this.isRequestAccept,
    required this.name,
    required this.position,
    required this.requestId,
    required this.to,
    required this.vehicyleType,
  });

  factory UserRequestRideModel.fromJson(Map<String, dynamic> json) {
    return UserRequestRideModel(
      contact: json['contact'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      distance: double.parse(json['distance']),
      driver: Driver.fromJson(json['driver']),
      fcmToken: json['fcmToken'],
      from: json['from'],
      id: json['id'],
      isRequestAccept: json['isRequestAccept'],
      name: json['name'],
      position: Position.fromJson(json['position']),
      requestId: json['requestId'],
      to: json['to'],
      vehicyleType: json['vehicyleType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contact': contact,
      'createdAt': createdAt.toIso8601String(),
      'distance': distance.toString(),
      'driver': driver.toJson(),
      'fcmToken': fcmToken,
      'from': from,
      'id': id,
      'isRequestAccept': isRequestAccept,
      'name': name,
      'position': position.toJson(),
      'requestId': requestId,
      'to': to,
      'vehicyleType': vehicyleType,
    };
  }
}

class Driver {
  final String contact;
  final String id;
  final String name;

  Driver({
    required this.contact,
    required this.id,
    required this.name,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      contact: json['contact'],
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contact': contact,
      'id': id,
      'name': name,
    };
  }
}

class Position {
  final String geohash;
  final dynamic geopoint;

  Position({
    required this.geohash,
    required this.geopoint,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      geohash: json['geohash'],
      geopoint: json['geopoint'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'geohash': geohash,
      'geopoint': geopoint,
    };
  }
}

class Geopoint {
  final double latitude;
  final double longitude;

  Geopoint({
    required this.latitude,
    required this.longitude,
  });

  factory Geopoint.fromJson(Map<String, dynamic> json) {
    return Geopoint(
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
