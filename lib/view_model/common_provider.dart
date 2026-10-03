import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:turfix/view/screens/user_screens/booking_screen.dart';

class CommonProvider extends ChangeNotifier {
  bool isLoading = false;
  String bookDate = DateFormat('d MMMM yyyy').format(DateTime.now());
  bool imageErrored = false;
  bool isObscure = true;
  String selectedPaymentMethod = PaymentMethod.upi.name;

  void selectPaymentMethod(String value) {
    selectedPaymentMethod = value;
    notifyListeners();
  }

  void pickBookDate(BuildContext context) async {
    final picker = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );
    if (picker != null) {
      bookDate = DateFormat('d MMMM yyyy').format(picker);
      notifyListeners();
    }
  }

  void load(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void imageError(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void obscurePassword() {
    isObscure = !isObscure;
    notifyListeners();
  }

  String getDisplayStatus(Map<String, dynamic> booking) {
    // Cancellation is stored permanently in Firebase
    if (booking['status']?.toString().toLowerCase() == 'cancelled') {
      return 'Cancelled';
    }

    final startAt = booking['startAt'];

    final endAt = booking['endAt'];

    if (startAt is! Timestamp || endAt is! Timestamp) {
      return 'Confirmed';
    }

    final now = DateTime.now();

    final startTime = startAt.toDate();
    final endTime = endAt.toDate();

    if (now.isBefore(startTime)) {
      return 'Confirmed';
    }

    if (now.isBefore(endTime)) {
      return 'Playing';
    }

    return 'Completed';
  }

  void showRatingBottomSheet(
    BuildContext context, {
    required String turfId,
    required String bookingId,
    required String userId,
  }) {
    int selectedRating = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 12,
                bottom: 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Icon
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xff16A34A).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: Color(0xff16A34A),
                      size: 34,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Rate this Turf',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'How was your experience?',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),

                  const SizedBox(height: 22),

                  // Stars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final rating = index + 1;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedRating = rating;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Icon(
                            rating <= selectedRating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            size: 42,
                            color: rating <= selectedRating
                                ? Colors.amber
                                : Colors.grey.shade400,
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 10),

                  // Rating text
                  if (selectedRating > 0)
                    Text(
                      _ratingText(selectedRating),
                      style: const TextStyle(
                        color: Color(0xff16A34A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: selectedRating == 0
                              ? null
                              : () async {
                                  final commonProvider = context
                                      .read<CommonProvider>();
                                  commonProvider.load(true);
                                  notifyListeners();
                                  final success = await addTurfRating(
                                    turfId: turfId,
                                    bookingId: bookingId,
                                    userId: userId,
                                    newRating: selectedRating,
                                  );

                                  if (!context.mounted) return;

                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? 'Thank you for rating the turf!'
                                            : 'This booking has already been rated.',
                                      ),
                                    ),
                                  );
                                  commonProvider.load(false);
                                  notifyListeners();
                                },
                          child: isLoading
                              ? const SizedBox(
                                  height: 10,
                                  width: 10,
                                  child: CircularProgressIndicator(),
                                )
                              : const Text(
                                  'Submit',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _ratingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Could be better';
      case 3:
        return 'Good';
      case 4:
        return 'Very good';
      case 5:
        return 'Excellent!';
      default:
        return '';
    }
  }

  Future<bool> addTurfRating({
    required String turfId,
    required String bookingId,
    required String userId,
    required int newRating,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;

      final turfRef = firestore.collection('turfs').doc(turfId);

      final ratingRef = firestore.collection('ratings').doc(bookingId);

      final result = await firestore.runTransaction<bool>((transaction) async {
        // Get turf
        final turfSnapshot = await transaction.get(turfRef);

        // Turf doesn't exist
        if (!turfSnapshot.exists) {
          return false;
        }

        // Check whether this booking has already been rated
        final ratingSnapshot = await transaction.get(ratingRef);

        if (ratingSnapshot.exists) {
          return false;
        }

        final data = turfSnapshot.data()!;

        // Existing rating information
        final oldReviewCount = (data['reviewCount'] as num?)?.toInt() ?? 0;

        final oldRatingTotal = (data['ratingTotal'] as num?)?.toInt() ?? 0;

        // New values
        final newReviewCount = oldReviewCount + 1;

        final newRatingTotal = oldRatingTotal + newRating;

        final newAverageRating = newRatingTotal / newReviewCount;

        // Update turf
        transaction.update(turfRef, {
          'rating': double.parse(newAverageRating.toStringAsFixed(1)),
          'reviewCount': newReviewCount,
          'ratingTotal': newRatingTotal,
        });

        // Create rating record
        transaction.set(ratingRef, {
          'bookingId': bookingId,
          'userId': userId,
          'turfId': turfId,
          'rating': newRating,
          'createdAt': FieldValue.serverTimestamp(),
        });

        return true;
      });

      return result;
    } catch (e) {
      debugPrint('Rating error: $e');
      return false;
    }
  }

  double turfRating = 0.0;

  Future<void> getTurfRating(String turfId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('turfs')
          .doc(turfId)
          .get();

      if (!doc.exists) {
        turfRating = 0.0;
        notifyListeners();
        return;
      }

      final data = doc.data();

      turfRating = (data?['rating'] as num?)?.toDouble() ?? 0.0;

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching rating: $e');
    }
  }
}
