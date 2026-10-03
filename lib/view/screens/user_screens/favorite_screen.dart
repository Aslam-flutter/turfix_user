import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view favorites')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Favorites",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        ),
      ),

      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),

          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (userSnapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const Center(child: Text('User data not found'));
            }

            final userData = userSnapshot.data!.data();

            final List<String> favoriteIds = List<String>.from(
              userData?['favoriteTurfs'] ?? [],
            );

            // No favorites
            if (favoriteIds.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_border, size: 70, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'No favorite turfs yet',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Add turfs to your favorites',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
              future: _getFavoriteTurfs(favoriteIds),

              builder: (context, turfSnapshot) {
                if (turfSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (turfSnapshot.hasError) {
                  return const Center(child: Text('Unable to load favorites'));
                }

                final turfs = turfSnapshot.data ?? [];

                if (turfs.isEmpty) {
                  return const Center(child: Text('No favorite turfs found'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: turfs.length,

                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 12);
                  },

                  itemBuilder: (context, index) {
                    final turf = turfs[index];

                    if (!turf.exists) {
                      return const SizedBox.shrink();
                    }

                    final data = turf.data()!;

                    final images = List<String>.from(data['turfImages'] ?? []);

                    final image = images.isNotEmpty ? images.first : '';

                    final name = data['turfName']?.toString() ?? 'Unknown Turf';

                    final location =
                        data['location']?.toString() ?? 'Location unavailable';

                    return FavoriteCard(
                      turfId: turf.id,
                      image: image,
                      name: name,
                      location: location,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> _getFavoriteTurfs(
    List<String> favoriteIds,
  ) async {
    final firestore = FirebaseFirestore.instance;

    final List<DocumentSnapshot<Map<String, dynamic>>> turfs = [];

    for (final turfId in favoriteIds) {
      final document = await firestore.collection('turfs').doc(turfId).get();

      if (document.exists) {
        turfs.add(document);
      }
    }

    return turfs;
  }
}

class FavoriteCard extends StatelessWidget {
  final String turfId;
  final String image;
  final String name;
  final String location;

  const FavoriteCard({
    super.key,
    required this.turfId,
    required this.image,
    required this.name,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: image.isEmpty
                ? Container(
                    height: 70,
                    width: 70,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  )
                : Image.network(
                    image,
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                  ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),

                    const SizedBox(width: 4),

                    Expanded(
                      child: Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;

              if (user == null) return;

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .update({
                    'favoriteTurfs': FieldValue.arrayRemove([turfId]),
                  });
            },
            icon: const Icon(Icons.favorite, color: Color(0xff16A34A)),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// class FavoritesScreen extends StatelessWidget {
//   const FavoritesScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,

//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         title: const Text(
//           "Favorites",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
//         ),
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
//         ),
//       ),

//       body: SafeArea(
//         child: ListView(
//           padding: const EdgeInsets.all(16),
//           children: const [
//             FavoriteCard(
//               image:
//                   "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTwq1O-qC-iZVN_4hkTobZRzKrsWYBbmqrrgls7NwcKUSzQuwJLvMC3xcU&s=10",

//               name: "Green Field Arena",
//               location: "Kozhikode, 2.5 km",
//             ),

//             SizedBox(height: 16),

//             FavoriteCard(
//               image:
//                   "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTwq1O-qC-iZVN_4hkTobZRzKrsWYBbmqrrgls7NwcKUSzQuwJLvMC3xcU&s=10",

//               name: "Kick Off Turf",
//               location: "Kozhikode, 3.1 km",
//             ),

//             SizedBox(height: 16),

//             FavoriteCard(
//               image:
//                   "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTwq1O-qC-iZVN_4hkTobZRzKrsWYBbmqrrgls7NwcKUSzQuwJLvMC3xcU&s=10",

//               name: "Sports Hub Turf",
//               location: "Kozhikode, 4.2 km",
//             ),

//             SizedBox(height: 16),

//             FavoriteCard(
//               image:
//                   "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTwq1O-qC-iZVN_4hkTobZRzKrsWYBbmqrrgls7NwcKUSzQuwJLvMC3xcU&s=10",

//               name: "Victory Ground",
//               location: "Kozhikode, 5.0 km",
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class FavoriteCard extends StatelessWidget {
//   final String image;
//   final String name;
//   final String location;

//   const FavoriteCard({
//     super.key,
//     required this.image,
//     required this.name,
//     required this.location,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(.03),
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: Image.network(
//               image,
//               height: 70,
//               width: 70,
//               fit: BoxFit.cover,
//             ),
//           ),

//           const SizedBox(width: 14),

//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   style: const TextStyle(
//                     fontSize: 17,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),

//                 const SizedBox(height: 6),

//                 Row(
//                   children: [
//                     Icon(
//                       Icons.location_on,
//                       size: 16,
//                       color: Colors.grey.shade600,
//                     ),

//                     const SizedBox(width: 4),

//                     Expanded(
//                       child: Text(
//                         location,
//                         style: TextStyle(
//                           color: Colors.grey.shade600,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           IconButton(
//             onPressed: () {},
//             icon: const Icon(Icons.favorite, color: Color(0xff16A34A)),
//           ),
//         ],
//       ),
//     );
//   }
// }
