import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/gender.dart';
import '../domain/user_profile.dart';
import 'profile_repository.dart';

class LocalProfileRepository implements ProfileRepository {
  static const _profilePrefix = 'profile.';

  @override
  Future<UserProfile?> getProfile(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('$_profilePrefix$userId');
    if (json == null) return null;

    final data = jsonDecode(json) as Map<String, dynamic>;
    return _fromJson(data);
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_toJson(profile));
    await prefs.setString('$_profilePrefix${profile.userId}', json);
  }

  @override
  Future<String> uploadPhoto(String userId, String localPath) async {
    // In local stub, just return the local path as-is.
    // Firebase implementation would upload to Storage and return download URL.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return localPath;
  }

  @override
  Future<void> deletePhoto(String userId, String photoUrl) async {
    // In local stub, nothing to delete from remote storage.
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  Map<String, dynamic> _toJson(UserProfile profile) {
    return {
      'userId': profile.userId,
      'name': profile.name,
      'birthDate': profile.birthDate?.toIso8601String(),
      'gender': profile.gender?.index,
      'interestedIn': profile.interestedIn.map((g) => g.index).toList(),
      'bio': profile.bio,
      'school': profile.school,
      'job': profile.job,
      'photos': profile.photos,
      'latitude': profile.latitude,
      'longitude': profile.longitude,
    };
  }

  UserProfile _fromJson(Map<String, dynamic> data) {
    return UserProfile(
      userId: data['userId'] as String,
      name: data['name'] as String? ?? '',
      birthDate: data['birthDate'] != null
          ? DateTime.parse(data['birthDate'] as String)
          : null,
      gender: data['gender'] != null ? Gender.values[data['gender'] as int] : null,
      interestedIn: (data['interestedIn'] as List<dynamic>?)
              ?.map((i) => Gender.values[i as int])
              .toList() ??
          [],
      bio: data['bio'] as String? ?? '',
      school: data['school'] as String? ?? '',
      job: data['job'] as String? ?? '',
      photos: (data['photos'] as List<dynamic>?)?.cast<String>() ?? [],
      latitude: data['latitude'] as double?,
      longitude: data['longitude'] as double?,
    );
  }
}
