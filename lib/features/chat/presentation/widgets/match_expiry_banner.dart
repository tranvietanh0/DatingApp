import 'dart:async';

import 'package:flutter/material.dart';

import '../../../matches/domain/match.dart';

class MatchExpiryBanner extends StatefulWidget {
  const MatchExpiryBanner({
    required this.match,
    required this.currentUserId,
    required this.onExtend,
    super.key,
  });

  final Match match;
  final String currentUserId;
  final VoidCallback onExtend;

  @override
  State<MatchExpiryBanner> createState() => _MatchExpiryBannerState();
}

class _MatchExpiryBannerState extends State<MatchExpiryBanner> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateRemaining() {
    final remaining = widget.match.timeUntilExpiry;
    if (remaining != null) {
      setState(() => _remaining = remaining);
    }
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final match = widget.match;

    if (!match.bumbleMode) return const SizedBox.shrink();
    if (match.lastMessage != null) return const SizedBox.shrink();

    final canSendFirst = match.canSendFirstMessage(widget.currentUserId);
    final isExpired = match.isExpired;

    if (isExpired) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        color: theme.colorScheme.errorContainer,
        child: Text(
          'This match has expired',
          style: TextStyle(color: theme.colorScheme.onErrorContainer),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: theme.colorScheme.primaryContainer,
      child: Row(
        children: [
          Icon(
            Icons.timer_outlined,
            size: 20,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              canSendFirst
                  ? 'Send a message! Expires in ${_formatDuration(_remaining)}'
                  : 'Waiting for her to message first... ${_formatDuration(_remaining)}',
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontSize: 13,
              ),
            ),
          ),
          if (match.canExtend && !canSendFirst)
            TextButton(
              onPressed: widget.onExtend,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Extend 24h'),
            ),
        ],
      ),
    );
  }
}
