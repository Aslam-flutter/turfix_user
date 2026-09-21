import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider extends ChangeNotifier {
  LocationProvider() {
    getCurrentLocation();
  }

  Position? _currentPosition;

  Position? get currentPosition => _currentPosition;

  String _currentLocation = 'Getting location...';

  String get currentLocation => _currentLocation;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> getCurrentLocation() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check if location service is enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        _currentLocation = 'Location disabled';
        return;
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _currentLocation = 'Location permission denied';
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _currentLocation = 'Location permission permanently denied';
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Save current position
      _currentPosition = position;

      // Convert coordinates to address
      final geocoding = Geocoding();

      final placemarks = await geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        _currentLocation = 'Unknown location';
        return;
      }

      final place = placemarks.first;

      final city = place.locality ?? place.subAdministrativeArea ?? '';

      final state = place.administrativeArea ?? '';

      if (city.isEmpty && state.isEmpty) {
        _currentLocation = 'Unknown location';
      } else if (state.isEmpty) {
        _currentLocation = city;
      } else if (city.isEmpty) {
        _currentLocation = state;
      } else {
        _currentLocation = '$city, $state';
      }
    } catch (e) {
      log('Location error: $e');
      _currentLocation = 'Unable to get location';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
