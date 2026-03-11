import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../profile/application/profile_providers.dart';

class LocationStep extends ConsumerStatefulWidget {
  const LocationStep({super.key});

  @override
  ConsumerState<LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends ConsumerState<LocationStep> {
  bool _isLoading = false;
  String? _errorMessage;
  bool _locationGranted = false;

  Future<void> _requestLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled. Please enable them in settings.';
          _isLoading = false;
        });
        return;
      }

      // Check and request permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permission denied.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permission permanently denied. Please enable it in settings.';
          _isLoading = false;
        });
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Generate geohash
      final geohash = _generateGeohash(position.latitude, position.longitude);

      // Update profile with location
      final profileController = ref.read(profileControllerProvider);
      await profileController.updateProfile(
        latitude: position.latitude,
        longitude: position.longitude,
        geohash: geohash,
      );

      setState(() {
        _locationGranted = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get location. Please try again.';
        _isLoading = false;
      });
    }
  }

  String _generateGeohash(double lat, double lng, {int precision = 6}) {
    const base32 = '0123456789bcdefghjkmnpqrstuvwxyz';
    var minLat = -90.0, maxLat = 90.0;
    var minLng = -180.0, maxLng = 180.0;
    var hash = '';
    var isEven = true;
    var bit = 0;
    var ch = 0;

    while (hash.length < precision) {
      if (isEven) {
        final mid = (minLng + maxLng) / 2;
        if (lng >= mid) {
          ch |= 1 << (4 - bit);
          minLng = mid;
        } else {
          maxLng = mid;
        }
      } else {
        final mid = (minLat + maxLat) / 2;
        if (lat >= mid) {
          ch |= 1 << (4 - bit);
          minLat = mid;
        } else {
          maxLat = mid;
        }
      }
      isEven = !isEven;
      if (bit < 4) {
        bit++;
      } else {
        hash += base32[ch];
        bit = 0;
        ch = 0;
      }
    }
    return hash;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileController = ref.watch(profileControllerProvider);
    final hasLocation = profileController.profile?.hasLocation ?? false;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Icon(
            _locationGranted || hasLocation
                ? Icons.location_on_rounded
                : Icons.location_searching_rounded,
            size: 80,
            color: _locationGranted || hasLocation
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
          ),
          const SizedBox(height: 32),
          Text(
            _locationGranted || hasLocation
                ? 'Location enabled!'
                : 'Enable location',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            _locationGranted || hasLocation
                ? 'You\'re all set to discover people nearby.'
                : 'We need your location to show you potential matches in your area.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _errorMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          if (!_locationGranted && !hasLocation)
            FilledButton.icon(
              onPressed: _isLoading ? null : _requestLocation,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location_rounded),
              label: Text(_isLoading ? 'Getting location...' : 'Enable Location'),
            ),
          if (_locationGranted || hasLocation)
            FilledButton(
              onPressed: () {
                // Profile is complete, router will redirect
              },
              child: const Text('Continue'),
            ),
          const SizedBox(height: 16),
          if (!_locationGranted && !hasLocation)
            TextButton(
              onPressed: () {
                // Skip for now - user can enable later
              },
              child: const Text('Skip for now'),
            ),
        ],
      ),
    );
  }
}
