import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turfix/core/constants/app_constants.dart';
import 'package:turfix/view/screens/user_screens/favorite_screen.dart';
import 'package:turfix/view/screens/user_screens/search_turf_screen.dart';
import 'package:turfix/view/screens/user_screens/slot_maintenance.dart';
import 'package:turfix/view/screens/user_screens/user_notifications_screen.dart';
import 'package:turfix/view_model/location_provider.dart';
import 'package:turfix/view_model/nearby_turf_provider.dart';
import 'package:turfix/widgets/custom_sized_box.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final locatnPrvdr = context.read<LocationProvider>();
    // locatnPrvdr.getCurrentLocation();
    return SlotMaintenance(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Hello',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "Find and book your favorite turf",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UserNotificationsScreen(),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                  size: 30,
                                  semanticLabel: 'Notifications',
                                ),
                              ),

                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FavoritesScreen(),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.favorite_outline,
                                  color: Colors.white,
                                  size: 30,
                                  semanticLabel: 'Favorites',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      sh(20),
                      TextField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey.shade400,
                          ),
                          hintText: 'Search turfs, sports,locations...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            // fontWeight: FontWeight.bold,/
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchTurfScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.black),
                  child: Container(
                    // padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Consumer<LocationProvider>(
                                builder: (context, locationProvider, child) {
                                  return Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: AppConstants.primaryGreen,
                                      ),
                                      sw(10),
                                      Text(
                                        locationProvider.currentLocation,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              sh(10),
                              Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  image: DecorationImage(
                                    image: AssetImage(
                                      "assets/images/football_card.png",
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              sh(20),
                              // Row(
                              //   mainAxisAlignment:
                              //       MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     Text(
                              //       "Select Sport",
                              //       style: TextStyle(
                              //         fontSize: 16,
                              //         fontWeight: FontWeight.bold,
                              //       ),
                              //     ),
                              //     InkWell(
                              //       onTap: () {},
                              //       child: Row(
                              //         children: [
                              //           Text(
                              //             'See All',
                              //             style: TextStyle(
                              //               color: Colors.grey.shade400,
                              //               fontWeight: FontWeight.bold,
                              //               fontSize: 14,
                              //             ),
                              //           ),
                              //           Icon(
                              //             Icons.keyboard_arrow_right,
                              //             color: Colors.grey.shade400,
                              //           ),
                              //         ],
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              // sh(10),
                              // Row(
                              //   mainAxisAlignment:
                              //       MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     Column(
                              //       children: [
                              //         Container(
                              //           padding: EdgeInsets.all(10),
                              //           decoration: BoxDecoration(
                              //             color: Colors.grey.shade100,
                              //             borderRadius: BorderRadius.circular(
                              //               16,
                              //             ),
                              //           ),
                              //           child: Icon(
                              //             Icons.sports_soccer,
                              //             size: 50,
                              //           ),
                              //         ),
                              //         sh(6),
                              //         Text(
                              //           'Football',
                              //           style: TextStyle(
                              //             fontWeight: FontWeight.bold,
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //     Column(
                              //       children: [
                              //         Container(
                              //           padding: EdgeInsets.all(10),
                              //           decoration: BoxDecoration(
                              //             color: Colors.grey.shade100,
                              //             borderRadius: BorderRadius.circular(
                              //               16,
                              //             ),
                              //           ),
                              //           child: Icon(
                              //             Icons.sports_cricket,
                              //             size: 50,
                              //           ),
                              //         ),
                              //         sh(6),
                              //         Text(
                              //           'Cricket',
                              //           style: TextStyle(
                              //             fontWeight: FontWeight.bold,
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //     Column(
                              //       children: [
                              //         Container(
                              //           padding: EdgeInsets.all(10),
                              //           decoration: BoxDecoration(
                              //             color: Colors.grey.shade100,
                              //             borderRadius: BorderRadius.circular(
                              //               16,
                              //             ),
                              //           ),
                              //           child: SizedBox(
                              //             height: 50,
                              //             child: Image.asset(
                              //               "assets/icons/badminton_icon.png",
                              //             ),
                              //           ),
                              //         ),
                              //         sh(6),
                              //         Text(
                              //           'Badminton',
                              //           style: TextStyle(
                              //             fontWeight: FontWeight.bold,
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //     Column(
                              //       children: [
                              //         Container(
                              //           padding: EdgeInsets.all(10),
                              //           decoration: BoxDecoration(
                              //             color: Colors.grey.shade100,
                              //             borderRadius: BorderRadius.circular(
                              //               16,
                              //             ),
                              //           ),
                              //           child: Icon(
                              //             Icons.sports_volleyball,
                              //             size: 50,
                              //           ),
                              //         ),
                              //         sh(6),
                              //         Text(
                              //           'Volleyball',
                              //           style: TextStyle(
                              //             fontWeight: FontWeight.bold,
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ],
                              // ),
                              // sh(20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Nearby Turfs',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {},
                                    child: Text(
                                      'See all',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppConstants.darkGreen,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 310,
                          child: Consumer<LocationProvider>(
                            builder: (context, locationProvider, child) {
                              final position = locationProvider.currentPosition;
                              if (position == null) {
                                return const SizedBox(
                                  height: 310,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              // Location is available
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (context.mounted) {
                                  context
                                      .read<NearbyTurfProvider>()
                                      .getNearbyTurfs(position);
                                }
                              });

                              return Consumer<NearbyTurfProvider>(
                                builder: (context, turfProvider, child) {
                                  if (turfProvider.isLoading) {
                                    return const SizedBox(
                                      height: 310,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }

                                  if (turfProvider.nearbyTurfs.isEmpty) {
                                    return const SizedBox(
                                      height: 150,
                                      child: Center(
                                        child: Text('No nearby turfs found'),
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: turfProvider.nearbyTurfs.length,
                                    itemBuilder: (context, index) {
                                      final turf =
                                          turfProvider.nearbyTurfs[index];
                                      final dist = turf['distance'] as double;
                                      final distance = turfProvider.getDistance(
                                        dist,
                                      );
                                      return Row(
                                        children: [
                                          sw(16),
                                          Column(
                                            children: [
                                              Container(
                                                height: 150,
                                                width: 200,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(20),
                                                        topRight:
                                                            Radius.circular(20),
                                                      ),
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                      turf['turfImages'][0],
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.all(10),
                                                height: 160,
                                                width: 200,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color:
                                                          Colors.grey.shade300,
                                                      blurRadius: 1,
                                                      spreadRadius: 1,
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.only(
                                                        bottomRight:
                                                            Radius.circular(20),
                                                        bottomLeft:
                                                            Radius.circular(20),
                                                      ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      turf['turfName'],
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.star,
                                                          color: Colors.amber,
                                                        ),
                                                        sw(6),
                                                        Text(
                                                          '${turf['rating']}',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: AppConstants
                                                                .primary,
                                                          ),
                                                        ),
                                                        Text(
                                                          '${turf['reviewCount']}',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors
                                                                .grey
                                                                .shade400,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    sh(6),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.location_on,
                                                          color: Colors.blue,
                                                        ),
                                                        Text(
                                                          distance,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Spacer(),
                                                        Text(
                                                          '₹ ${turf['pricePerHour']}/hr',
                                                          style: TextStyle(
                                                            color: AppConstants
                                                                .darkGreen,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    sh(6),
                                                    MaterialButton(
                                                      height: 50,
                                                      minWidth: double.infinity,
                                                      color: AppConstants
                                                          .darkGreen,
                                                      textColor: Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),
                                                      onPressed: () {},
                                                      child: Text(
                                                        "Book Now",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
