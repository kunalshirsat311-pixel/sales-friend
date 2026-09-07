import 'package:cloud_firestore/cloud_firestore.dart';

class VisitModel {
  final String id;
  final String userId;
  final String clientName;
  final String notes;
  final double latitude;
  final double longitude;
  final String locationAddress;
  final String? photoUrl;
  final DateTime visitTime;

  VisitModel({
    required this.id,
    required this.userId,
    required this.clientName,
    required this.notes,
    required this.latitude,
    required this.longitude,
    required this.locationAddress,
    this.photoUrl,
    required this.visitTime,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'clientName': clientName,
      'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
      'locationAddress': locationAddress,
      'photoUrl': photoUrl,
      'visitTime': visitTime.toIso8601String(),
    };
  }

  // Convert Firebase data back to VisitModel
  factory VisitModel.fromMap(Map<String, dynamic> map) {
    DateTime parsedTime;
    final rawTime = map['visitTime'];
    if (rawTime is Timestamp) {
      parsedTime = rawTime.toDate();
    } else if (rawTime is String) {
      parsedTime = DateTime.parse(rawTime);
    } else {
      parsedTime = DateTime.now();
    }

    return VisitModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      clientName: map['clientName'] ?? '',
      notes: map['notes'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      locationAddress: map['locationAddress'] ?? '',
      photoUrl: map['photoUrl'],
      visitTime: parsedTime,
    );
  }
}
