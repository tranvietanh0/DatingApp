import 'package:flutter/foundation.dart';

import '../data/profile_repository.dart';
import '../domain/gender.dart';
import '../domain/user_profile.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({required ProfileRepository repository})
      : _repository = repository;

  final ProfileRepository _repository;

  UserProfile? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isComplete => _profile?.isComplete ?? false;

  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _repository.getProfile(userId);
      _profile ??= UserProfile(userId: userId);
    } catch (e) {
      _errorMessage = 'Failed to load profile';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateName(String name) async {
    await _updateProfile((p) => p.copyWith(name: name.trim()));
  }

  Future<void> updateBirthDate(DateTime birthDate) async {
    await _updateProfile((p) => p.copyWith(birthDate: birthDate));
  }

  Future<void> updateGender(Gender gender) async {
    await _updateProfile((p) => p.copyWith(gender: gender));
  }

  Future<void> updateInterestedIn(List<Gender> interestedIn) async {
    await _updateProfile((p) => p.copyWith(interestedIn: interestedIn));
  }

  Future<void> updateBio(String bio) async {
    await _updateProfile((p) => p.copyWith(bio: bio.trim()));
  }

  Future<void> updateSchool(String school) async {
    await _updateProfile((p) => p.copyWith(school: school.trim()));
  }

  Future<void> updateJob(String job) async {
    await _updateProfile((p) => p.copyWith(job: job.trim()));
  }

  Future<void> updateLocation(double latitude, double longitude) async {
    await _updateProfile((p) => p.copyWith(
          latitude: latitude,
          longitude: longitude,
        ));
  }

  Future<void> updateProfile({
    String? name,
    DateTime? birthDate,
    Gender? gender,
    List<Gender>? interestedIn,
    String? bio,
    String? school,
    String? job,
    double? latitude,
    double? longitude,
    String? geohash,
  }) async {
    await _updateProfile((p) => p.copyWith(
          name: name,
          birthDate: birthDate,
          gender: gender,
          interestedIn: interestedIn,
          bio: bio,
          school: school,
          job: job,
          latitude: latitude,
          longitude: longitude,
          geohash: geohash,
        ));
  }

  Future<void> addPhoto(String localPath) async {
    if (_profile == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final photoUrl = await _repository.uploadPhoto(_profile!.userId, localPath);
      final updatedPhotos = [..._profile!.photos, photoUrl];
      await _updateProfile((p) => p.copyWith(photos: updatedPhotos));
    } catch (e) {
      _errorMessage = 'Failed to upload photo';
      notifyListeners();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> removePhoto(int index) async {
    if (_profile == null || index >= _profile!.photos.length) return;

    final photoUrl = _profile!.photos[index];
    final updatedPhotos = [..._profile!.photos]..removeAt(index);

    await _repository.deletePhoto(_profile!.userId, photoUrl);
    await _updateProfile((p) => p.copyWith(photos: updatedPhotos));
  }

  Future<void> reorderPhotos(int oldIndex, int newIndex) async {
    if (_profile == null) return;

    final photos = [..._profile!.photos];
    final photo = photos.removeAt(oldIndex);
    photos.insert(newIndex < oldIndex ? newIndex : newIndex - 1, photo);

    await _updateProfile((p) => p.copyWith(photos: photos));
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _updateProfile(UserProfile Function(UserProfile) update) async {
    if (_profile == null) return;

    _profile = update(_profile!);
    notifyListeners();

    try {
      await _repository.saveProfile(_profile!);
    } catch (e) {
      _errorMessage = 'Failed to save profile';
      notifyListeners();
    }
  }
}
