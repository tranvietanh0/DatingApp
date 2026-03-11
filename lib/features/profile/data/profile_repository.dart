import '../domain/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile?> getProfile(String userId);
  Future<void> saveProfile(UserProfile profile);
  Future<String> uploadPhoto(String userId, String localPath);
  Future<void> deletePhoto(String userId, String photoUrl);
}
