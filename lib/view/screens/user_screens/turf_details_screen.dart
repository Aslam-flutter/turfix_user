import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:turfix/core/constants/app_fuctions.dart';
import 'package:turfix/model/date_booking_model.dart';
import 'package:turfix/view/screens/user_screens/booking_screen.dart';
import 'package:turfix/view_model/bookig_provider.dart';

class TurfDetailsScreen extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> turfDetails;
  const TurfDetailsScreen({super.key, required this.turfDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 280,
              child: Stack(
                children: [
                  /// IMAGE
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    child: Image.network(
                      turfDetails['turfImages'][0], // Your Image
                      width: double.infinity,
                      height: 280,
                      fit: BoxFit.cover,
                    ),
                  ),

                  /// GRADIENT
                  Container(
                    height: 280,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black54,
                          Colors.black87,
                        ],
                      ),
                    ),
                  ),

                  /// TOP BUTTONS
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 15,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          circleButton(Icons.arrow_back, () {}),

                          Row(
                            children: [
                              circleButton(Icons.share, () {}),

                              const SizedBox(width: 12),

                              circleButton(Icons.favorite_border, () {}),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// DETAILS
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 22,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          turfDetails['turfName'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.orange,
                                    size: 18,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    turfDetails['rating'].toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 10),

                            Text(
                              "(${turfDetails['reviewCount']} reviews)",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                              ),
                            ),

                            const Spacer(),

                            const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 20,
                            ),

                            const SizedBox(width: 5),

                            const Text(
                              "2.5 km",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            SizedBox(
              height: 30,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: turfDetails['sportTypes'].length,
                itemBuilder: (context, index) {
                  final turf = turfDetails['sportTypes'][index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 30),
                      Icon(
                        AppFuctions.getSportIcon(turf),
                        color: Color(0xff16A34A),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: turf,
                              style: TextStyle(
                                color: Color(0xff16A34A),
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                              ),
                            ),
                            TextSpan(
                              text: " • Outdoor",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Facilities",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: turfDetails['facilities'].length,
                itemBuilder: (context, index) {
                  final facility = turfDetails['facilities'][index];
                  return Container(
                    width: 78,
                    margin: const EdgeInsets.only(left: 14),
                    child: Column(
                      children: [
                        Container(
                          height: 56,
                          width: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.04),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            AppFuctions.getFacilityIcon(facility),
                            color: const Color(0xff16A34A),
                            size: 26,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          facility,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Select Date",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.calendar_today_outlined, size: 20),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 110,
              child: Consumer<BookingProvider>(
                builder: (_, provider, __) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.dates.length,
                    itemBuilder: (_, index) {
                      return DateCard(
                        bookingDate: provider.dates[index],
                        onTap: () => provider.selectDate(index),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Select Time",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Selector<BookingProvider, String>(
                selector: (_, provider) => provider.dateFormat,

                builder: (context, dateId, _) {
                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('turfs')
                        .doc(turfDetails.id)
                        .collection('slots')
                        .doc(dateId)
                        .collection('times')
                        .orderBy('startAt')
                        .snapshots(),

                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No slots available'));
                      }

                      final slots = snapshot.data!.docs;

                      return Consumer<BookingProvider>(
                        builder: (context, provider, _) {
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),

                            itemCount: slots.length,

                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.9,
                                ),

                            itemBuilder: (context, index) {
                              final slotDocument = slots[index];

                              final data = slotDocument.data();

                              final startAt = (data['startAt'] as Timestamp)
                                  .toDate();

                              final endAt = (data['endAt'] as Timestamp)
                                  .toDate();

                              final status = data['status'];

                              final isAvailable = status == 'available';

                              final isSelected = provider.isSlotSelected(
                                slotDocument.id,
                              );

                              final slotIds = slots
                                  .map((doc) => doc.id)
                                  .toList();

                              final availableSlotIds = slots
                                  .where(
                                    (doc) =>
                                        doc.data()['status'] == 'available',
                                  )
                                  .map((doc) => doc.id)
                                  .toList();

                              final canSelect =
                                  isAvailable &&
                                  provider.canSelectSlot(
                                    index: index,
                                    slotIds: slotIds,
                                    availableSlotIds: availableSlotIds,
                                  );

                              return TimeSlotCard(
                                startTime: DateFormat('h:mm a').format(startAt),

                                endTime: DateFormat('h:mm a').format(endAt),

                                price: '₹${data['price']}',

                                status: isAvailable
                                    ? SlotStatus.available
                                    : SlotStatus.booked,

                                isSelected: isSelected,

                                onTap: canSelect
                                    ? () {
                                        provider.toggleSlot(
                                          slotId: slotDocument.id,
                                          slotData: data,
                                        );
                                      }
                                    : null,
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      floatingActionButton: Consumer<BookingProvider>(
        builder: (context, provider, _) {
          final hasSelection = provider.selectedSlots.isNotEmpty;

          return SizedBox(
            width: MediaQuery.of(context).size.width - 32,
            height: 56,
            child: FloatingActionButton.extended(
              onPressed: !hasSelection
                  ? null
                  : () async {
                      provider.sortSelectedSlots();

                      final customerName = await provider.getCustomerName();

                      if (customerName == null) {
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingScreen(
                            turf: turfDetails,
                            date: provider.selectedDate!,
                            selectedSlots: provider.selectedSlots,
                            customerName: customerName,
                          ),
                        ),
                      );
                    },
              backgroundColor: const Color(0xff16A34A),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              label: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, color: Colors.white),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget circleButton(IconData icon, GestureTapCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        width: 48,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black87),
      ),
    );
  }
}

class FacilityCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const FacilityCard({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      margin: const EdgeInsets.only(left: 14),
      child: Column(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xff16A34A), size: 26),
          ),

          const SizedBox(height: 8),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class DateCard extends StatelessWidget {
  final BookingDateModel bookingDate;
  final VoidCallback onTap;

  const DateCard({super.key, required this.bookingDate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = bookingDate.date;
    final selected = bookingDate.selected;

    final dayName = date.day == DateTime.now().day
        ? "Today"
        : ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][date.weekday - 1];

    final month = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ][date.month - 1];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        width: 70,
        margin: const EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xff16A34A) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xff16A34A) : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayName,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xff16A34A),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : Colors.black,
              ),
            ),
            Text(
              month,
              style: TextStyle(color: selected ? Colors.white70 : Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

enum SlotStatus { available, booked, unavailable }

class TimeSlotCard extends StatelessWidget {
  final String startTime;
  final String endTime;
  final String price;
  final SlotStatus status;
  final bool isSelected;
  final VoidCallback? onTap;

  const TimeSlotCard({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.status,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;
    String statusText;

    switch (status) {
      case SlotStatus.available:
        bgColor = isSelected
            ? const Color(0xff16A34A)
            : const Color(0xffF5FCF7);
        borderColor = const Color(0xff16A34A);
        textColor = isSelected ? Colors.white : Colors.black;
        statusText = "Available";
        break;

      case SlotStatus.booked:
        bgColor = Colors.grey.shade100;
        borderColor = Colors.grey.shade300;
        textColor = Colors.grey.shade500;
        statusText = "Booked";
        break;

      case SlotStatus.unavailable:
        bgColor = const Color(0xffFDECEC);
        borderColor = Colors.red.shade300;
        textColor = Colors.red.shade700;
        statusText = "Unavailable";
        break;
    }

    return InkWell(
      onTap: status == SlotStatus.available ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 95,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              startTime,
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),

            Text(endTime, style: TextStyle(color: textColor)),

            const SizedBox(height: 8),

            Text(statusText, style: TextStyle(fontSize: 12, color: textColor)),

            const SizedBox(height: 4),

            Text(
              price,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xff16A34A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
