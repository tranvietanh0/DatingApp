import '../../profile/domain/gender.dart';

class DiscoveryFilters {
  const DiscoveryFilters({
    this.minAge = 18,
    this.maxAge = 50,
    this.maxDistanceKm = 50,
    this.interestedIn = const [],
  });

  final int minAge;
  final int maxAge;
  final double maxDistanceKm;
  final List<Gender> interestedIn;

  DiscoveryFilters copyWith({
    int? minAge,
    int? maxAge,
    double? maxDistanceKm,
    List<Gender>? interestedIn,
  }) {
    return DiscoveryFilters(
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      interestedIn: interestedIn ?? this.interestedIn,
    );
  }
}
