import '../domain/liker.dart';
import '../domain/premium_status.dart';
import 'premium_repository.dart';

/// Mock premium repository for testing without Firebase
class MockPremiumRepository implements PremiumRepository {
  @override
  Future<PremiumStatus> getPremiumStatus(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return const PremiumStatus(
      tier: PremiumTier.free,
      expiresAt: null,
    );
  }

  @override
  Stream<PremiumStatus> watchPremiumStatus(String userId) {
    return Stream.value(const PremiumStatus(
      tier: PremiumTier.free,
      expiresAt: null,
    ));
  }

  @override
  Future<void> useUndo(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> useBoost(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<DateTime?> getBoostExpiry(String userId) async {
    return null; // Not boosted
  }

  @override
  Future<List<Liker>> getWhoLikedYou(String userId, {required bool isPremium}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      Liker(
        oderId: 'liker1',
        visibleId: isPremium ? 'liker1' : 'hidden',
        likedAt: DateTime.now().subtract(const Duration(hours: 2)),
        name: isPremium ? 'Mai' : null,
        age: isPremium ? 24 : null,
      ),
      Liker(
        oderId: 'liker2',
        visibleId: isPremium ? 'liker2' : 'hidden',
        likedAt: DateTime.now().subtract(const Duration(days: 1)),
        name: isPremium ? 'Hoa' : null,
        age: isPremium ? 22 : null,
      ),
    ];
  }

  @override
  Future<int> getLikesCount(String userId) async {
    return 2; // Mock: 2 people liked you
  }

  @override
  Future<Map<String, dynamic>?> getLastSwipe(String userId) async {
    return null; // No last swipe
  }

  @override
  Future<void> deleteSwipe(String swipeId) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
