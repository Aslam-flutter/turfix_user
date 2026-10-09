import 'package:flutter/material.dart';

class SearchTurfProvider extends ChangeNotifier {
  String selectedSport = 'All';
  String searchQuery = '';

  final List<String> sports = [
    'All',
    'Football',
    'Cricket',
    'Volleyball',
    'Badminton',
  ];

  void selectSport(String sport) {
    selectedSport = sport;
    notifyListeners();
  }

  void updateSearch(String query) {
    searchQuery = query.trim().toLowerCase();
    notifyListeners();
  }
}
