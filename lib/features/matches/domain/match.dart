import 'package:cloud_firestore/cloud_firestore.dart';

class Match {
  const Match({
    required this.id,
    required this.userIds,
    required this.matchedAt,
    this.lastMessage,
    this.lastMessageAt,
    this.unread = const {},
    this.expiresAt,
    this.isExtended = false,
    this.firstMessageSenderId,
    this.bumbleMode = false,
  });

  final String id;
  final List<String> userIds;
  final DateTime matchedAt;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final Map<String, bool> unread;

  /// When this match expires (Bumble mode only)
  final DateTime? expiresAt;

  /// Whether this match has been extended
  final bool isExtended;

  /// User ID who must send the first message (Bumble mode only)
  final String? firstMessageSenderId;

  /// Whether Bumble rules are enabled for this match
  final bool bumbleMode;

  String getOtherUserId(String currentUserId) {
    return userIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  bool hasUnread(String userId) => unread[userId] ?? false;

  /// Check if match is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Get remaining time until expiry
  Duration? get timeUntilExpiry {
    if (expiresAt == null) return null;
    final remaining = expiresAt!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Check if user can send first message
  bool canSendFirstMessage(String userId) {
    if (!bumbleMode) return true;
    if (lastMessage != null) return true; // Conversation already started
    return firstMessageSenderId == userId;
  }

  /// Check if match can be extended
  bool get canExtend {
    if (!bumbleMode) return false;
    if (isExtended) return false;
    if (lastMessage != null) return false; // Already have messages
    return true;
  }

  static String createMatchId(String userId1, String userId2) {
    final sorted = [userId1, userId2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userIds': userIds,
      'matchedAt': FieldValue.serverTimestamp(),
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt != null
          ? Timestamp.fromDate(lastMessageAt!)
          : null,
      'unread': unread,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'isExtended': isExtended,
      'firstMessageSenderId': firstMessageSenderId,
      'bumbleMode': bumbleMode,
    };
  }

  factory Match.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final matchedAtTimestamp = data['matchedAt'] as Timestamp?;
    final lastMessageAtTimestamp = data['lastMessageAt'] as Timestamp?;
    final expiresAtTimestamp = data['expiresAt'] as Timestamp?;

    return Match(
      id: doc.id,
      userIds: List<String>.from(data['userIds'] as List<dynamic>),
      matchedAt: matchedAtTimestamp?.toDate() ?? DateTime.now(),
      lastMessage: data['lastMessage'] as String?,
      lastMessageAt: lastMessageAtTimestamp?.toDate(),
      unread: Map<String, bool>.from(data['unread'] as Map? ?? {}),
      expiresAt: expiresAtTimestamp?.toDate(),
      isExtended: data['isExtended'] as bool? ?? false,
      firstMessageSenderId: data['firstMessageSenderId'] as String?,
      bumbleMode: data['bumbleMode'] as bool? ?? false,
    );
  }
}
