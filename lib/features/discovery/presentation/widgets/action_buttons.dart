import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({
    super.key,
    required this.onPass,
    required this.onLike,
    required this.onSuperLike,
    this.onUndo,
    this.onBoost,
    this.enabled = true,
  });

  final VoidCallback onPass;
  final VoidCallback onLike;
  final VoidCallback onSuperLike;
  final VoidCallback? onUndo;
  final VoidCallback? onBoost;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Undo button
        if (onUndo != null)
          _ActionButton(
            onPressed: enabled ? onUndo : null,
            icon: Icons.undo_rounded,
            color: Colors.amber,
            size: 44,
          ),
        if (onUndo != null) const SizedBox(width: 12),

        // Pass button
        _ActionButton(
          onPressed: enabled ? onPass : null,
          icon: Icons.close_rounded,
          color: theme.colorScheme.error,
          size: 56,
        ),
        const SizedBox(width: 12),

        // Super Like button
        _ActionButton(
          onPressed: enabled ? onSuperLike : null,
          icon: Icons.star_rounded,
          color: Colors.blue,
          size: 48,
        ),
        const SizedBox(width: 12),

        // Like button
        _ActionButton(
          onPressed: enabled ? onLike : null,
          icon: Icons.favorite_rounded,
          color: theme.colorScheme.primary,
          size: 56,
        ),

        // Boost button
        if (onBoost != null) const SizedBox(width: 12),
        if (onBoost != null)
          _ActionButton(
            onPressed: enabled ? onBoost : null,
            icon: Icons.bolt_rounded,
            color: Colors.purple,
            size: 44,
          ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.color,
    required this.size,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          backgroundColor: Colors.white,
          foregroundColor: color,
          elevation: 4,
          shadowColor: color.withValues(alpha: 0.4),
        ),
        child: Icon(icon, size: size * 0.5),
      ),
    );
  }
}
