import 'package:flutter/material.dart';

import '../domain/report.dart';

class ReportDialog extends StatefulWidget {
  const ReportDialog({
    required this.onSubmit,
    super.key,
  });

  final void Function(ReportReason reason, String? details) onSubmit;

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  ReportReason? _selectedReason;
  final _detailsController = TextEditingController();

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  String _reasonLabel(ReportReason reason) {
    switch (reason) {
      case ReportReason.inappropriatePhotos:
        return 'Inappropriate photos';
      case ReportReason.harassment:
        return 'Harassment or bullying';
      case ReportReason.spam:
        return 'Spam or scam';
      case ReportReason.fakeProfile:
        return 'Fake profile';
      case ReportReason.underage:
        return 'User appears underage';
      case ReportReason.other:
        return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Report User'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Why are you reporting this user?'),
            const SizedBox(height: 16),
            ...ReportReason.values.map((reason) => RadioListTile<ReportReason>(
                  title: Text(_reasonLabel(reason)),
                  value: reason,
                  groupValue: _selectedReason,
                  onChanged: (value) => setState(() => _selectedReason = value),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                )),
            const SizedBox(height: 16),
            TextField(
              controller: _detailsController,
              decoration: const InputDecoration(
                labelText: 'Additional details (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selectedReason == null
              ? null
              : () {
                  widget.onSubmit(
                    _selectedReason!,
                    _detailsController.text.trim().isEmpty
                        ? null
                        : _detailsController.text.trim(),
                  );
                  Navigator.of(context).pop();
                },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
