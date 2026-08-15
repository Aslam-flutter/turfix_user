import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          onPressed: () {},
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        ),
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            FavoriteCard(
              image:
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTwq1O-qC-iZVN_4hkTobZRzKrsWYBbmqrrgls7NwcKUSzQuwJLvMC3xcU&s=10",

              name: "Green Field Arena",
              location: "Kozhikode, 2.5 km",
            ),

            SizedBox(height: 16),

            FavoriteCard(
              image:
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTwq1O-qC-iZVN_4hkTobZRzKrsWYBbmqrrgls7NwcKUSzQuwJLvMC3xcU&s=10",

              name: "Kick Off Turf",
              location: "Kozhikode, 3.1 km",
            ),

            SizedBox(height: 16),

            FavoriteCard(
              image:
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTwq1O-qC-iZVN_4hkTobZRzKrsWYBbmqrrgls7NwcKUSzQuwJLvMC3xcU&s=10",

              name: "Sports Hub Turf",
              location: "Kozhikode, 4.2 km",
            ),

            SizedBox(height: 16),

            FavoriteCard(
              image:
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTwq1O-qC-iZVN_4hkTobZRzKrsWYBbmqrrgls7NwcKUSzQuwJLvMC3xcU&s=10",

              name: "Victory Ground",
              location: "Kozhikode, 5.0 km",
            ),
          ],
        ),
      ),
    );
  }
}

class FavoriteCard extends StatelessWidget {
  final String image;
  final String name;
  final String location;

  const FavoriteCard({
    super.key,
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
            child: Image.network(
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
            onPressed: () {},
            icon: const Icon(Icons.favorite, color: Color(0xff16A34A)),
          ),
        ],
      ),
    );
  }
}
