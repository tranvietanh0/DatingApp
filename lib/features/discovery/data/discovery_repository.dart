import '../../profile/domain/user_profile.dart';
import '../domain/discovery_filters.dart';
import '../domain/swipe.dart';
import '../domain/swipe_action.dart';

abstract class DiscoveryRepository {
  Future<List<UserProfile>> fetchCandidates({
    required String userId,
    required double latitude,
    required double longitude,
    required DiscoveryFilters filters,
    int limit = 20,
  });

  Future<void> recordSwipe({
    required String swiperId,
    required String targetId,
    required SwipeAction action,
  });

  Future<List<Swipe>> getSwipedUserIds(String userId);

  Future<bool> checkMutualLike({
    required String userId1,
    required String userId2,
  });
}
