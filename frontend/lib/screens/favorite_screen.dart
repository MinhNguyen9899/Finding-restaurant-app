import 'package:flutter/material.dart';
import 'package:frontend/screens/detail_screen.dart';

class FavoriteScreen extends StatelessWidget {
  final List<Map<String, dynamic>> favoriteRestaurants;
  final Function(Map<String, dynamic>) onToggleFavorite;

  const FavoriteScreen({
    super.key,
    required this.favoriteRestaurants,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final favorites = favoriteRestaurants;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quán ăn yêu thích"),
      ),

      body: favorites.isEmpty
          ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.favorite_border,
                  size: 80,
                  color: Colors.grey,
                ),
                
                const SizedBox(height: 15),

                const Text(
                  "Chưa có quán ăn yêu thích",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          )
        : Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),

              child: Text(
                "Tổng số quán yêu thích: ${favorites.length}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: favorites.length,
                itemBuilder: (context,index) {
                  final item = favorites[index];

                  print(item);

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),

                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          "assets/images/default.jpg",
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),

                      title: Text(
                        item["restaurant_name"] ?? "",
                      ),

                      subtitle: Text(
                        item["address"] ?? "Chưa có địa chỉ",
                      ),

                      trailing: SizedBox(
                        width: 70,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${item["average_rating"] ?? 0} ⭐",
                            ),

                            Text(
                              "${item["review_count"] ?? 0} đánh giá",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),                
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(
                              restaurant: item,
                              onToggleFavorite: onToggleFavorite,
                              isFavorite: true,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ], 
        ),     
    );
  }
}