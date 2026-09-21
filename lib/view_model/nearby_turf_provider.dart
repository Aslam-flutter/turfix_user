import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class NearbyTurfProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _nearbyTurfs = [];

  List<Map<String, dynamic>> get nearbyTurfs => _nearbyTurfs;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _hasLoaded = false;

  Future<void> getNearbyTurfs(Position userPosition) async {
    if (_hasLoaded) return;

    try {
      _hasLoaded = true;

      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore.collection('turfs').get();

      final List<Map<String, dynamic>> turfs = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();

        final latitude = (data['latitude'] as num?)?.toDouble();

        final longitude = (data['longitude'] as num?)?.toDouble();

        if (latitude == null || longitude == null) {
          continue;
        }

        final distance = Geolocator.distanceBetween(
          userPosition.latitude,
          userPosition.longitude,
          latitude,
          longitude,
        );

        turfs.add({...data, 'id': doc.id, 'distance': distance});
      }

      turfs.sort(
        (a, b) => (a['distance'] as double).compareTo(b['distance'] as double),
      );

      _nearbyTurfs = turfs.take(10).toList();
    } catch (e) {
      debugPrint('Nearby turf error: $e');

      _nearbyTurfs = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String getDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m away';
    }

    final km = meters / 1000;

    return '${km.toStringAsFixed(1)} km away';
  }
}
