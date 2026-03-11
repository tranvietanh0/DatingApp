import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportReason {
  inappropriatePhotos,
  harassment,
  spam,
  fakeProfile,
  underage,
  other,
}

class Report {
  const Report({
    required this.id,
    required this.reporterId,
    required this.reportedId,
    required this.reason,
    this.details,
    required this.createdAt,
  });

  final String id;
  final String reporterId;
  final String reportedId;
  final ReportReason reason;
  final String? details;
  final DateTime createdAt;

  Map<String, dynamic> toFirestore() {
    return {
      'reporterId': reporterId,
      'reportedId': reportedId,
      'reason': reason.name,
      'details': details,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    };
  }

  factory Report.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final createdAt = data['createdAt'] as Timestamp?;

    return Report(
      id: doc.id,
      reporterId: data['reporterId'] as String,
      reportedId: data['reportedId'] as String,
      reason: ReportReason.values.firstWhere(
        (r) => r.name == data['reason'],
        orElse: () => ReportReason.other,
      ),
      details: data['details'] as String?,
      createdAt: createdAt?.toDate() ?? DateTime.now(),
    );
  }
}
