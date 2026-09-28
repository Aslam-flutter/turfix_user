import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turfix/view/screens/user_screens/booking_details_screen.dart';
import 'package:turfix/view/screens/user_screens/user_main_screen.dart';
import 'package:turfix/view_model/common_provider.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    // const primary = Color(0xff16A34A);
    final provider = Provider.of<CommonProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "My Bookings",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserMainScreen()),
            );
          },
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            /// Tabs
            // Row(
            //   children: [
            //     tabButton("Upcoming", 0),
            //     const SizedBox(width: 10),
            //     tabButton("Completed", 1),
            //     const SizedBox(width: 10),
            //     tabButton("Cancelled", 2),
            //   ],
            // ),

            // const SizedBox(height: 25),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('bookings')
                    .where(
                      'userId',
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final bookingDetails = snapshot.data!.docs;

                  if (bookingDetails.isEmpty) {
                    return Text('No booking details found');
                  }
                  return ListView.builder(
                    itemCount: bookingDetails.length,
                    itemBuilder: (context, index) {
                      final bookingDetail = bookingDetails[index].data();
                      final bookingDetailss = bookingDetails[index];

                      final status = provider.getDisplayStatus(bookingDetail);

                      Color statusColor;

                      switch (status) {
                        case 'Confirmed':
                          statusColor = Colors.orange;
                          break;

                        case 'Playing':
                          statusColor = Colors.green;
                          break;

                        case 'Completed':
                          statusColor = Colors.grey;
                          break;

                        default:
                          statusColor = Colors.grey;
                      }

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingDetailsScreen(
                                bookingDetails: bookingDetailss,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  bookingDetail['turfImage'],
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bookingDetail['turfName'],
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      bookingDetail['turfLocation'],
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      bookingDetail['sport'],
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 14,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(.12),
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        child: Text(
                                          status,
                                          style: TextStyle(
                                            color: statusColor,

                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tabButton(String title, int index) {
    final selected = selectedTab == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            color: selected ? const Color(0xff16A34A) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// class BookingCard extends StatelessWidget {
//   final String image;
//   final String title;
//   final String date;
//   final String sport;
//   final String status;
//   final Color statusColor;

//   const BookingCard({
//     super.key,
//     required this.image,
//     required this.title,
//     required this.date,
//     required this.sport,
//     required this.status,
//     required this.statusColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: Colors.grey.shade200),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(.04),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: Image.network(
//               image,
//               height: 80,
//               width: 80,
//               fit: BoxFit.cover,
//             ),
//           ),

//           const SizedBox(width: 14),

//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 17,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),

//                 const SizedBox(height: 6),

//                 Text(
//                   date,
//                   style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
//                 ),

//                 const SizedBox(height: 6),

//                 Text(
//                   sport,
//                   style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
//                 ),

//                 const SizedBox(height: 10),

//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 5,
//                     ),
//                     decoration: BoxDecoration(
//                       color: statusColor.withOpacity(.12),
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     child: Text(
//                       status,
//                       style: TextStyle(
//                         color: statusColor,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
