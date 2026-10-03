import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:turfix/core/constants/app_constants.dart';
import 'package:turfix/view_model/common_provider.dart';

class BookingDetailsScreen extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> bookingDetails;
  const BookingDetailsScreen({super.key, required this.bookingDetails});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  @override
  void initState() {
    super.initState();

    final turfId = widget.bookingDetails['turfId'];

    if (turfId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<CommonProvider>().getTurfRating(turfId.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final provider = context.read<CommonProvider>();

    // const primary = Color(0xff16A34A);
    // created At
    final timestamp = widget.bookingDetails['createdAt'];
    final dateTime = timestamp.toDate();
    final formattedDate = DateFormat('d MMM yyyy').format(dateTime);
    final formattedDate2 = DateFormat('d MMM yyyy - h:mm a').format(dateTime);

    // start time
    final timestamp2 = widget.bookingDetails['startAt'];
    final dateTime2 = timestamp2.toDate();
    final formattedDate3 = DateFormat('h:mm a').format(dateTime2);

    // end time
    final timestamp3 = widget.bookingDetails['endAt'];
    final dateTime3 = timestamp3.toDate();
    final formattedDate4 = DateFormat('h:mm a').format(dateTime3);

    final bookingID = widget.bookingDetails['bookingId'];

    final duration = AppConstants.timeDifference(dateTime2, dateTime3);

    final sportType = widget.bookingDetails['sport'];
    // final status = bookingDetails['status'];

    final booking = widget.bookingDetails.data();

    final status = provider.getDisplayStatus(booking);

    final trufId = widget.bookingDetails['turfId'];

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Booking Details",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        ),
      ),

      // bottomNavigationBar: SafeArea(
      //   minimum: const EdgeInsets.all(20),
      //   child: SizedBox(
      //     width: double.infinity,
      //     height: 55,
      //     child:
      //   ),
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Turf Image
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                widget.bookingDetails['turfImage'],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.bookingDetails['turfName'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Consumer<CommonProvider>(
                  builder: (context, provider, child) {
                    return Text(
                      '⭐ ${provider.turfRating}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              widget.bookingDetails['turfLocation'],
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: BookingInfo(title: "Date", value: formattedDate),
                ),

                Expanded(
                  child: BookingInfo(
                    title: "Time",
                    value: "$formattedDate3 - $formattedDate4",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: BookingInfo(title: "Sport", value: sportType),
                ),

                Expanded(
                  child: BookingInfo(
                    title: "Duration",
                    value: "$duration Hour",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Divider(color: Colors.grey.shade300),

            const SizedBox(height: 25),

            BookingInfo(title: "Booking ID", value: bookingID),

            const SizedBox(height: 20),

            BookingInfo(title: "Booked On", value: formattedDate2),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: BookingInfo(title: "Status", value: status),
                ),

                status == "Completed"
                    ? MaterialButton(
                        color: Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onPressed: () {
                          provider.showRatingBottomSheet(
                            context,
                            turfId: trufId,
                            bookingId: bookingID,
                            userId: userId,
                          );
                        },
                        child: Text(
                          '⭐ Rate Turf',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    : SizedBox(),
              ],
            ),
            SizedBox(height: 20),
            // SizedBox(
            //   width: double.infinity,
            //   height: 50,
            //   child: OutlinedButton(
            //     onPressed: () {},
            //     style: OutlinedButton.styleFrom(
            //       side: const BorderSide(color: Colors.red),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(14),
            //       ),
            //     ),
            //     child: const Text(
            //       "Cancel Booking",
            //       style: TextStyle(
            //         color: Colors.red,
            //         fontWeight: FontWeight.w600,
            //         fontSize: 16,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class BookingInfo extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;

  const BookingInfo({
    super.key,
    required this.title,
    required this.value,
    this.valueColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),

        const SizedBox(height: 8),

        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
