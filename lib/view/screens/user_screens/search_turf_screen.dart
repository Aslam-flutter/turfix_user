import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turfix/core/constants/app_constants.dart';
import 'package:turfix/view/screens/user_screens/turf_details_screen.dart';
import 'package:turfix/view_model/search_turf_provider.dart';
import 'package:turfix/widgets/custom_sized_box.dart';

class SearchTurfScreen extends StatelessWidget {
  const SearchTurfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final provider = Provider.of<CommonProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                  sw(10),
                  Text(
                    'Search Turfs',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (value) {
                  context.read<SearchTurfProvider>().updateSearch(value);
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                  hintText: 'Search turfs, sports,locations...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    // fontWeight: FontWeight.bold,/
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
              ),
            ),
            sh(16),
            Consumer<SearchTurfProvider>(
              builder: (context, provider, _) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: provider.sports.map((sport) {
                      final isSelected = provider.selectedSport == sport;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () => provider.selectSport(sport),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppConstants.darkGreen
                                  : Colors.white,
                              border: Border.all(
                                color: isSelected
                                    ? AppConstants.darkGreen
                                    : Colors.grey.shade400,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              sport,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            // SingleChildScrollView(
            //   scrollDirection: Axis.horizontal,
            //   child: Row(
            //     children: [
            //       sw(16),
            //       Container(
            //         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            //         decoration: BoxDecoration(
            //           color: AppConstants.darkGreen,
            //           borderRadius: BorderRadius.circular(50),
            //         ),
            //         child: Text(
            //           'All',
            //           style: TextStyle(
            //             fontSize: 14,
            //             fontWeight: FontWeight.bold,
            //             color: Colors.white,
            //           ),
            //         ),
            //       ),
            //       sw(6),
            //       Container(
            //         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            //         decoration: BoxDecoration(
            //           color: Colors.white,
            //           border: Border.all(color: Colors.grey.shade400),
            //           borderRadius: BorderRadius.circular(50),
            //         ),
            //         child: Text(
            //           'Football',
            //           style: TextStyle(
            //             fontSize: 14,
            //             fontWeight: FontWeight.bold,
            //             color: Colors.black,
            //           ),
            //         ),
            //       ),
            //       sw(6),
            //       Container(
            //         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            //         decoration: BoxDecoration(
            //           color: Colors.white,
            //           border: Border.all(color: Colors.grey.shade400),
            //           borderRadius: BorderRadius.circular(50),
            //         ),
            //         child: Text(
            //           'Cricket',
            //           style: TextStyle(
            //             fontSize: 14,
            //             fontWeight: FontWeight.bold,
            //             color: Colors.black,
            //           ),
            //         ),
            //       ),
            //       sw(6),

            //       Container(
            //         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            //         decoration: BoxDecoration(
            //           color: Colors.white,
            //           border: Border.all(color: Colors.grey.shade400),
            //           borderRadius: BorderRadius.circular(50),
            //         ),
            //         child: Text(
            //           'Volleyball',
            //           style: TextStyle(
            //             fontSize: 14,
            //             fontWeight: FontWeight.bold,
            //             color: Colors.black,
            //           ),
            //         ),
            //       ),
            //       sw(6),

            //       Container(
            //         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            //         decoration: BoxDecoration(
            //           color: Colors.white,
            //           border: Border.all(color: Colors.grey.shade400),
            //           borderRadius: BorderRadius.circular(50),
            //         ),
            //         child: Text(
            //           'Badminton',
            //           style: TextStyle(
            //             fontSize: 14,
            //             fontWeight: FontWeight.bold,
            //             color: Colors.black,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            sh(20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('turfs')
                    .where('isVerified', isEqualTo: 1)
                    .snapshots(),
                builder: (context, asyncSnapshot) {
                  if (asyncSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return SizedBox(child: CircularProgressIndicator());
                  }
                  final allTurfs = asyncSnapshot.data!.docs;

                  final provider = context.watch<SearchTurfProvider>();

                  final turfs = allTurfs.where((turf) {
                    final data = turf.data();

                    final sportTypes = List<String>.from(
                      data['sportTypes'] ?? [],
                    );

                    final matchesSport =
                        provider.selectedSport == 'All' ||
                        sportTypes.any(
                          (sport) =>
                              sport.toLowerCase() ==
                              provider.selectedSport.toLowerCase(),
                        );

                    final name = (data['turfName'] ?? '')
                        .toString()
                        .toLowerCase();
                    final location = (data['location'] ?? '')
                        .toString()
                        .toLowerCase();

                    final matchesSearch =
                        provider.searchQuery.isEmpty ||
                        name.contains(provider.searchQuery) ||
                        location.contains(provider.searchQuery) ||
                        sportTypes.any(
                          (sport) => sport.toLowerCase().contains(
                            provider.searchQuery,
                          ),
                        );

                    return matchesSport && matchesSearch;
                  }).toList();

                  if (turfs.isEmpty) {
                    return SizedBox(child: Text('No turf detaiis found'));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: turfs.length,
                    itemBuilder: (context, index) {
                      final turf = turfs[index];
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TurfDetailsScreen(turfDetails: turf),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(5),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade200,
                                    spreadRadius: 1.5,
                                    blurRadius: 1.5,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      turf['turfImages'][0],
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  sw(10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          turf['turfName'],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        sh(6),
                                        Text(
                                          turf['location'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                        sh(12),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            Text(
                                              ' ${turf['rating']}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Spacer(),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              child: Text(
                                                '₹${turf['pricePerHour']}/hr',
                                                style: TextStyle(
                                                  color: AppConstants.darkGreen,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
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
                          ),
                          sh(10),
                        ],
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
}
