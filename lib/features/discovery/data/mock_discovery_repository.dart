import '../../profile/domain/gender.dart';
import '../../profile/domain/user_profile.dart';
import '../domain/discovery_filters.dart';
import '../domain/swipe.dart';
import '../domain/swipe_action.dart';
import 'discovery_repository.dart';

/// Mock repository for testing without Firebase
class MockDiscoveryRepository implements DiscoveryRepository {
  final List<String> _swipedIds = [];

  static final _mockProfiles = [
    UserProfile(
      userId: 'mock1',
      name: 'Linh',
      birthDate: DateTime(1999, 5, 15),
      gender: Gender.female,
      bio: 'Cafe explorer, pilates addict, and always planning the next city escape.',
      job: 'UX Designer',
      photos: [],
      latitude: 21.0285,
      longitude: 105.8542,
    ),
    UserProfile(
      userId: 'mock2',
      name: 'Mai',
      birthDate: DateTime(1998, 8, 22),
      gender: Gender.female,
      bio: 'Dog mom, coffee enthusiast, weekend hiker.',
      school: 'Hanoi University',
      photos: [],
      latitude: 21.0300,
      longitude: 105.8500,
    ),
    UserProfile(
      userId: 'mock3',
      name: 'Hoa',
      birthDate: DateTime(2000, 3, 10),
      gender: Gender.female,
      bio: 'Love traveling, trying new foods, and lazy Sundays.',
      job: 'Software Engineer',
      photos: [],
      latitude: 21.0250,
      longitude: 105.8600,
    ),
    UserProfile(
      userId: 'mock4',
      name: 'Trang',
      birthDate: DateTime(1997, 11, 5),
      gender: Gender.female,
      bio: 'Bookworm by day, Netflix binger by night.',
      job: 'Marketing Manager',
      photos: [],
      latitude: 21.0320,
      longitude: 105.8450,
    ),
    UserProfile(
      userId: 'mock5',
      name: 'Ngoc',
      birthDate: DateTime(1999, 7, 18),
      gender: Gender.female,
      bio: 'Yoga instructor, plant parent, sunset chaser.',
      job: 'Yoga Instructor',
      photos: [],
      latitude: 21.0280,
      longitude: 105.8580,
    ),
  ];

  @override
  Future<List<UserProfile>> fetchCandidates({
    required String userId,
    required double latitude,
    required double longitude,
    required DiscoveryFilters filters,
    int limit = 20,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return _mockProfiles
        .where((p) => !_swipedIds.contains(p.userId))
        .take(limit)
        .toList();
  }

  @override
  Future<void> recordSwipe({
    required String swiperId,
    required String targetId,
    required SwipeAction action,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _swipedIds.add(targetId);
  }

  @override
  Future<List<Swipe>> getSwipedUserIds(String userId) async {
    return [];
  }

  @override
  Future<bool> checkMutualLike({
    required String userId1,
    required String userId2,
  }) async {
    // 30% chance of match for demo
    return DateTime.now().millisecond % 3 == 0;
  }
}
