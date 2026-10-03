import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoriteProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<String> favoriteTurfs = [];

  bool isLoading = false;

  // Load favorites from Firebase
  Future<void> loadFavorites() async {
    final user = _auth.currentUser;

    if (user == null) return;

    try {
      isLoading = true;
      notifyListeners();

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data();

        favoriteTurfs = List<String>.from(data?['favoriteTurfs'] ?? []);
      }
    } catch (e) {
      debugPrint('Load favorites error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Check whether turf is favorite
  bool isFavorite(String turfId) {
    return favoriteTurfs.contains(turfId);
  }

  // Add / remove favorite
  Future<void> toggleFavorite(String turfId) async {
    final user = _auth.currentUser;

    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);

    try {
      if (favoriteTurfs.contains(turfId)) {
        // Remove
        await userRef.update({
          'favoriteTurfs': FieldValue.arrayRemove([turfId]),
        });

        favoriteTurfs.remove(turfId);
      } else {
        // Add
        await userRef.update({
          'favoriteTurfs': FieldValue.arrayUnion([turfId]),
        });

        favoriteTurfs.add(turfId);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Toggle favorite error: $e');
    }
  }
}
