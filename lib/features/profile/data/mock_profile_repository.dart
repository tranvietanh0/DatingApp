import '../domain/gender.dart';
import '../domain/user_profile.dart';
import 'profile_repository.dart';

/// Mock profile repository with demo data for testing
class MockProfileRepository implements ProfileRepository {
  UserProfile? _currentProfile;

  @override
  Future<UserProfile?> getProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Return existing profile or create a demo one
    _currentProfile ??= UserProfile(
      userId: userId,
      name: 'Demo User',
      birthDate: DateTime(1998, 6, 15),
      gender: Gender.male,
      interestedIn: [Gender.female],
      bio: 'Testing the dating app!',
      job: 'Software Developer',
      photos: ['https://picsum.photos/400/600'],
      latitude: 21.0285,
      longitude: 105.8542,
      isVisible: true,
    );

    return _currentProfile;
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _currentProfile = profile;
  }

  @override
  Future<String> uploadPhoto(String userId, String localPath) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return localPath;
  }

  @override
  Future<void> deletePhoto(String userId, String photoUrl) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
