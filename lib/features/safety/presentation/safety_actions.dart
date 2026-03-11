import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../application/safety_providers.dart';
import 'report_dialog.dart';

/// Shows a bottom sheet with safety actions (block, report)
Future<void> showSafetyActions(
  BuildContext context,
  WidgetRef ref, {
  required String targetUserId,
  required String targetUserName,
  VoidCallback? onBlocked,
}) async {
  final result = await showModalBottomSheet<String>(
    context: context,
    builder: (context) => SafetyActionsSheet(
      targetUserName: targetUserName,
    ),
  );

  if (result == null || !context.mounted) return;

  final userId = ref.read(authControllerProvider).session?.userId;
  if (userId == null) return;

  final safetyController = ref.read(safetyControllerProvider);

  if (result == 'block') {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: Text(
          'Are you sure you want to block $targetUserName? '
          'They will no longer appear in your discovery, matches, or chats.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Block'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await safetyController.blockUser(userId, targetUserId);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$targetUserName has been blocked')),
        );
        onBlocked?.call();
      }
    }
  } else if (result == 'report') {
    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (context) => ReportDialog(
        onSubmit: (reason, details) async {
          final success = await safetyController.reportUser(
            reporterId: userId,
            reportedId: targetUserId,
            reason: reason,
            details: details,
          );
          if (success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Report submitted. Thank you.')),
            );
          }
        },
      ),
    );
  }
}

class SafetyActionsSheet extends StatelessWidget {
  const SafetyActionsSheet({
    required this.targetUserName,
    super.key,
  });

  final String targetUserName;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.block, color: Colors.red),
            title: Text('Block $targetUserName'),
            subtitle: const Text('They won\'t be able to see you'),
            onTap: () => Navigator.of(context).pop('block'),
          ),
          ListTile(
            leading: const Icon(Icons.flag, color: Colors.orange),
            title: Text('Report $targetUserName'),
            subtitle: const Text('Report inappropriate behavior'),
            onTap: () => Navigator.of(context).pop('report'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text('Cancel'),
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
