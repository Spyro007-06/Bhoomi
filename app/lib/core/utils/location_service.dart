import 'dart:async';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/farm_models.dart';

/// Lifecycle statuses for device GPS location acquisition.
enum LocationServiceStatus {
  idle,
  requesting,
  acquired,
  denied,
  deniedForever,
  disabled,
  timeout,
  error,
}

/// Result object holding acquired GPS coordinates and resolution status.
class LocationResult {
  final GeoPoint? location;
  final LocationServiceStatus status;
  final String? errorMessage;

  const LocationResult({
    this.location,
    required this.status,
    this.errorMessage,
  });

  bool get isSuccess => status == LocationServiceStatus.acquired && location != null;
  bool get isFailure => !isSuccess;
  bool get isDenied => status == LocationServiceStatus.denied || status == LocationServiceStatus.deniedForever;
  bool get isDeniedForever => status == LocationServiceStatus.deniedForever;
  bool get isDisabled => status == LocationServiceStatus.disabled;
  bool get isTimeout => status == LocationServiceStatus.timeout;
}

/// Abstract wrapper around Geolocator to allow test injection without native platform channel failures.
abstract class GeolocatorWrapper {
  Future<bool> isLocationServiceEnabled();
  Future<LocationPermission> checkPermission();
  Future<LocationPermission> requestPermission();
  Future<Position> getCurrentPosition({
    LocationAccuracy desiredAccuracy = LocationAccuracy.medium,
    Duration? timeLimit,
  });
  Future<Position?> getLastKnownPosition() => Future.value(null);
  Future<bool> openAppSettings();
  Future<bool> openLocationSettings();
}

/// Default implementation delegating directly to the native Geolocator plugin.
class DefaultGeolocatorWrapper implements GeolocatorWrapper {
  const DefaultGeolocatorWrapper();

  @override
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled().timeout(
        const Duration(seconds: 3),
        onTimeout: () => false,
      );
    } catch (_) {
      return false;
    }
  }

  @override
  Future<LocationPermission> checkPermission() async {
    try {
      return await Geolocator.checkPermission().timeout(
        const Duration(seconds: 3),
        onTimeout: () => LocationPermission.denied,
      );
    } catch (_) {
      return LocationPermission.denied;
    }
  }

  @override
  Future<LocationPermission> requestPermission() async {
    try {
      return await Geolocator.requestPermission().timeout(
        const Duration(seconds: 3),
        onTimeout: () => LocationPermission.denied,
      );
    } catch (_) {
      return LocationPermission.denied;
    }
  }

  @override
  Future<Position> getCurrentPosition({
    LocationAccuracy desiredAccuracy = LocationAccuracy.medium,
    Duration? timeLimit,
  }) async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: desiredAccuracy,
      timeLimit: timeLimit ?? const Duration(seconds: 10),
    );
  }

  @override
  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (_) {
      return false;
    }
  }
}

/// Device GPS Location Service.
/// Handles permission requests, service checks, and real coordinates acquisition using Geolocator.
class LocationService {
  final GeolocatorWrapper _geolocator;

  LocationService({GeolocatorWrapper? geolocatorWrapper})
      : _geolocator = geolocatorWrapper ?? const DefaultGeolocatorWrapper();

  /// Acquire real device GPS coordinates.
  /// 1. Verifies if location services are enabled on device.
  /// 2. Requests/checks runtime location permissions.
  /// 3. Obtains device coordinates with last known position fallback for instant indoor responses.
  Future<LocationResult> getCurrentLocation({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      // 1. Check if location services (GPS) are enabled
      final isServiceEnabled = await _geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        return const LocationResult(
          status: LocationServiceStatus.disabled,
          errorMessage: 'Location services are disabled on your device.',
        );
      }

      // 2. Check current location permission status
      var permission = await _geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Request permission if not yet determined/denied once
        permission = await _geolocator.requestPermission();
      }

      // 3. Handle permission outcomes
      if (permission == LocationPermission.denied) {
        return const LocationResult(
          status: LocationServiceStatus.denied,
          errorMessage: 'Location permission denied by user.',
        );
      }

      if (permission == LocationPermission.deniedForever) {
        return const LocationResult(
          status: LocationServiceStatus.deniedForever,
          errorMessage: 'Location permission permanently denied. Please enable in App Settings.',
        );
      }

      // 4. Permission granted: acquire real device position
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final position = await _geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: timeout,
        );

        return LocationResult(
          location: GeoPoint(
            lat: position.latitude,
            lng: position.longitude,
          ),
          status: LocationServiceStatus.acquired,
        );
      }

      return const LocationResult(
        status: LocationServiceStatus.error,
        errorMessage: 'Unable to determine location permission status.',
      );
    } on TimeoutException {
      return const LocationResult(
        status: LocationServiceStatus.timeout,
        errorMessage: 'GPS location request timed out.',
      );
    } on MissingPluginException {
      return const LocationResult(
        status: LocationServiceStatus.disabled,
        errorMessage: 'Location services are unavailable on this platform.',
      );
    } on PlatformException catch (e) {
      return LocationResult(
        status: LocationServiceStatus.error,
        errorMessage: e.message ?? e.toString(),
      );
    } catch (e) {
      if (e is TimeoutException || e.toString().toLowerCase().contains('timeout')) {
        return const LocationResult(
          status: LocationServiceStatus.timeout,
          errorMessage: 'GPS location request timed out.',
        );
      }
      return LocationResult(
        status: LocationServiceStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Open device App Settings so user can grant permanently denied permissions.
  Future<bool> openAppSettings() => _geolocator.openAppSettings();

  /// Open device Location/GPS Settings so user can enable disabled location services.
  Future<bool> openLocationSettings() => _geolocator.openLocationSettings();

  /// Fallback regional coordinate estimator when GPS is unavailable and farmer enters location manually.
  static GeoPoint estimateCoordinatesForRegion(String region) {
    final lower = region.toLowerCase().trim();
    if (lower.contains('coimbatore')) return const GeoPoint(lat: 11.0168, lng: 76.9558);
    if (lower.contains('chennai')) return const GeoPoint(lat: 13.0827, lng: 80.2707);
    if (lower.contains('madurai')) return const GeoPoint(lat: 9.9252, lng: 78.1198);
    if (lower.contains('tamil') || lower.contains('tn')) return const GeoPoint(lat: 11.1271, lng: 78.6569);

    if (lower.contains('pune')) return const GeoPoint(lat: 18.5204, lng: 73.8567);
    if (lower.contains('nagpur')) return const GeoPoint(lat: 21.1458, lng: 79.0882);
    if (lower.contains('kolhapur')) return const GeoPoint(lat: 16.7050, lng: 74.2433);
    if (lower.contains('aurangabad') || lower.contains('chhatrapati sambhajinagar') || lower.contains('sambhajinagar')) {
      return const GeoPoint(lat: 19.8762, lng: 75.3433);
    }
    if (lower.contains('solapur')) return const GeoPoint(lat: 17.6599, lng: 75.9064);
    if (lower.contains('amravati')) return const GeoPoint(lat: 20.9374, lng: 77.7796);
    if (lower.contains('nashik') || lower.contains('nasik')) return const GeoPoint(lat: 19.9975, lng: 73.7898);
    if (lower.contains('maharashtra') || lower.contains('mh')) return const GeoPoint(lat: 19.7515, lng: 75.7139);

    if (lower.contains('dharwad') || lower.contains('hubli')) return const GeoPoint(lat: 15.4589, lng: 75.0078);
    if (lower.contains('bengaluru') || lower.contains('bangalore')) return const GeoPoint(lat: 12.9716, lng: 77.5946);
    if (lower.contains('karnataka') || lower.contains('ka')) return const GeoPoint(lat: 15.3173, lng: 75.7139);

    if (lower.contains('hyderabad') || lower.contains('telangana')) return const GeoPoint(lat: 17.3850, lng: 78.4867);
    if (lower.contains('andhra') || lower.contains('ap')) return const GeoPoint(lat: 15.9129, lng: 79.7400);

    if (lower.contains('ahmedabad') || lower.contains('gujarat')) return const GeoPoint(lat: 22.2587, lng: 71.1924);
    if (lower.contains('indore') || lower.contains('bhopal') || lower.contains('madhya pradesh') || lower.contains('mp')) {
      return const GeoPoint(lat: 22.7196, lng: 75.8577);
    }
    if (lower.contains('punjab') || lower.contains('haryana')) return const GeoPoint(lat: 30.7333, lng: 76.7794);
    if (lower.contains('uttar pradesh') || lower.contains('up')) return const GeoPoint(lat: 26.8467, lng: 80.9462);

    // Default to Nashik / Maharashtra agricultural center
    return const GeoPoint(lat: 19.9975, lng: 73.7898);
  }
}

