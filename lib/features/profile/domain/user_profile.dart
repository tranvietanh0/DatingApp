import 'package:cloud_firestore/cloud_firestore.dart';

import 'gender.dart';

class UserProfile {
  const UserProfile({
    required this.userId,
    this.phoneNumber,
    this.name = '',
    this.birthDate,
    this.gender,
    this.interestedIn = const [],
    this.bio = '',
    this.school = '',
    this.job = '',
    this.photos = const [],
    this.latitude,
    this.longitude,
    this.geohash,
    this.lastActive,
    this.isVisible = true,
    this.createdAt,
  });

  final String userId;
  final String? phoneNumber;
  final String name;
  final DateTime? birthDate;
  final Gender? gender;
  final List<Gender> interestedIn;
  final String bio;
  final String school;
  final String job;
  final List<String> photos;
  final double? latitude;
  final double? longitude;
  final String? geohash;
  final DateTime? lastActive;
  final bool isVisible;
  final DateTime? createdAt;

  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    var age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  bool get isComplete =>
      name.trim().isNotEmpty &&
      birthDate != null &&
      gender != null &&
      interestedIn.isNotEmpty &&
      photos.isNotEmpty;

  bool get hasLocation => latitude != null && longitude != null;

  GeoPoint? get geoPoint {
    if (latitude == null || longitude == null) return null;
    return GeoPoint(latitude!, longitude!);
  }

  UserProfile copyWith({
    String? phoneNumber,
    String? name,
    DateTime? birthDate,
    Gender? gender,
    List<Gender>? interestedIn,
    String? bio,
    String? school,
    String? job,
    List<String>? photos,
    double? latitude,
    double? longitude,
    String? geohash,
    DateTime? lastActive,
    bool? isVisible,
    DateTime? createdAt,
  }) {
    return UserProfile(
      userId: userId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      interestedIn: interestedIn ?? this.interestedIn,
      bio: bio ?? this.bio,
      school: school ?? this.school,
      job: job ?? this.job,
      photos: photos ?? this.photos,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geohash: geohash ?? this.geohash,
      lastActive: lastActive ?? this.lastActive,
      isVisible: isVisible ?? this.isVisible,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'phoneNumber': phoneNumber,
      'name': name,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'gender': gender?.name,
      'interestedIn': interestedIn.map((g) => g.name).toList(),
      'bio': bio,
      'school': school,
      'job': job,
      'photos': photos,
      'location': geoPoint,
      'geohash': geohash,
      'lastActive': FieldValue.serverTimestamp(),
      'isVisible': isVisible,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return UserProfile(userId: doc.id);
    }

    final location = data['location'] as GeoPoint?;
    final birthTimestamp = data['birthDate'] as Timestamp?;
    final lastActiveTimestamp = data['lastActive'] as Timestamp?;
    final createdAtTimestamp = data['createdAt'] as Timestamp?;

    return UserProfile(
      userId: doc.id,
      phoneNumber: data['phoneNumber'] as String?,
      name: data['name'] as String? ?? '',
      birthDate: birthTimestamp?.toDate(),
      gender: _parseGender(data['gender'] as String?),
      interestedIn: _parseGenderList(data['interestedIn'] as List<dynamic>?),
      bio: data['bio'] as String? ?? '',
      school: data['school'] as String? ?? '',
      job: data['job'] as String? ?? '',
      photos: List<String>.from(data['photos'] as List<dynamic>? ?? []),
      latitude: location?.latitude,
      longitude: location?.longitude,
      geohash: data['geohash'] as String?,
      lastActive: lastActiveTimestamp?.toDate(),
      isVisible: data['isVisible'] as bool? ?? true,
      createdAt: createdAtTimestamp?.toDate(),
    );
  }

  static Gender? _parseGender(String? value) {
    if (value == null) return null;
    return Gender.values.where((g) => g.name == value).firstOrNull;
  }

  static List<Gender> _parseGenderList(List<dynamic>? values) {
    if (values == null) return [];
    return values
        .map((v) => _parseGender(v as String?))
        .whereType<Gender>()
        .toList();
  }
}
