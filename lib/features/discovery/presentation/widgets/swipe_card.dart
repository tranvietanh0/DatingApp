import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../profile/domain/user_profile.dart';

class SwipeCard extends StatelessWidget {
  const SwipeCard({
    super.key,
    required this.profile,
    this.distance,
  });

  final UserProfile profile;
  final double? distance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Photo
          if (profile.photos.isNotEmpty)
            CachedNetworkImage(
              imageUrl: profile.photos.first,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.person,
                  size: 80,
                  color: theme.colorScheme.outline,
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.primary,
                  ],
                ),
              ),
              child: Icon(
                Icons.person,
                size: 80,
                color: theme.colorScheme.onPrimary,
              ),
            ),

          // Gradient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Distance chip
          if (distance != null)
            Positioned(
              left: 16,
              top: 16,
              child: Chip(
                avatar: const Icon(Icons.place_rounded, size: 16),
                label: Text(_formatDistance(distance!)),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),

          // Profile info
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${profile.name}, ${profile.age ?? '?'}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (profile.job.isNotEmpty || profile.school.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    profile.job.isNotEmpty ? profile.job : profile.school,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
                if (profile.bio.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    profile.bio,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDistance(double km) {
    if (km < 1) {
      return '${(km * 1000).round()} m away';
    }
    return '${km.toStringAsFixed(1)} km away';
  }
}
