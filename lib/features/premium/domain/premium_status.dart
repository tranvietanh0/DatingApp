import 'package:cloud_firestore/cloud_firestore.dart';

enum PremiumTier {
  free,
  gold,
  platinum,
}

class PremiumStatus {
  const PremiumStatus({
    this.tier = PremiumTier.free,
    this.expiresAt,
    this.undosRemaining = 0,
    this.boostsRemaining = 0,
    this.superLikesRemaining = 0,
  });

  final PremiumTier tier;
  final DateTime? expiresAt;
  final int undosRemaining;
  final int boostsRemaining;
  final int superLikesRemaining;

  bool get isPremium => tier != PremiumTier.free && !isExpired;

  bool get isExpired {
    if (expiresAt == null) return tier == PremiumTier.free;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get canUndo => isPremium || undosRemaining > 0;
  bool get canBoost => isPremium || boostsRemaining > 0;
  bool get canSuperLike => isPremium || superLikesRemaining > 0;
  bool get canSeeWhoLikedYou => isPremium;

  PremiumStatus copyWith({
    PremiumTier? tier,
    DateTime? expiresAt,
    int? undosRemaining,
    int? boostsRemaining,
    int? superLikesRemaining,
  }) {
    return PremiumStatus(
      tier: tier ?? this.tier,
      expiresAt: expiresAt ?? this.expiresAt,
      undosRemaining: undosRemaining ?? this.undosRemaining,
      boostsRemaining: boostsRemaining ?? this.boostsRemaining,
      superLikesRemaining: superLikesRemaining ?? this.superLikesRemaining,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tier': tier.name,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'undosRemaining': undosRemaining,
      'boostsRemaining': boostsRemaining,
      'superLikesRemaining': superLikesRemaining,
    };
  }

  factory PremiumStatus.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) return const PremiumStatus();

    final expiresAtTimestamp = data['expiresAt'] as Timestamp?;

    return PremiumStatus(
      tier: PremiumTier.values.firstWhere(
        (t) => t.name == data['tier'],
        orElse: () => PremiumTier.free,
      ),
      expiresAt: expiresAtTimestamp?.toDate(),
      undosRemaining: data['undosRemaining'] as int? ?? 0,
      boostsRemaining: data['boostsRemaining'] as int? ?? 0,
      superLikesRemaining: data['superLikesRemaining'] as int? ?? 0,
    );
  }
}
