import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'review_screen.dart';
import 'add_review_screen.dart';
import '../services/api_service.dart';

class DetailScreen extends StatefulWidget {
  final Map restaurant;
  final Function(Map<String, dynamic>) onToggleFavorite;
  final bool isFavorite;

  const DetailScreen({
    super.key,
    required this.restaurant,
    required this.onToggleFavorite,
    required this.isFavorite
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late bool favorite;
  late Map restaurantData;

  @override
  void initState() {
    super.initState();
    favorite = widget.isFavorite;

    restaurantData = Map<String, dynamic>.from(widget.restaurant);
    
    reloadRestaurant();
  }

  
  Future<void> reloadRestaurant() async {
    try {
      
      final updated = await ApiService.getRestaurant(
        restaurantData["restaurant_id"],
      );

      setState(() {
        restaurantData = updated;
      });
    } catch (e) {
      print(e);
    }
  }

  void openMap(BuildContext context) async {
    final address = restaurantData["address"];

    if (address == null) return;

    final url = "https://www.google.com/maps/search/?api=1&query=$address";
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void callPhone() async {
    final phone = restaurantData["phone"];
    if (phone == null) return;
    final uri = Uri.parse("tel:$phone");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          restaurantData["restaurant_name"] ?? "Chi tiết quán",
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Padding (
              padding:  const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  "assets/images/default.jpg",
                  width: double.infinity,
                  height: 280,
                  fit: BoxFit.cover,
                ),
              ),
            ),
           
            Padding(
              padding: const EdgeInsets.all(16),
              
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,

                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      
                      child: Row(
                        children: [
                          const Icon(Icons.location_on),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              restaurantData["address"] ??"Chưa có địa chỉ",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      const Icon(Icons.access_time),
                      const SizedBox(width: 10),

                      Text (restaurantData["opening_hours"] ?? "Chưa cập nhật",),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Row (
                    children: [
                      const Icon(Icons.phone),
                      const SizedBox(width: 10),

                      Text(
                        restaurantData["phone"] ?? "Chưa có số điện thoại",
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.orange,
                      ),

                      const SizedBox(width: 10),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: Text(
                          "⭐ ${restaurantData["average_rating"] ?? 0}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      TextButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReviewScreen(
                                restaurant: restaurantData,
                              ),
                            ),
                          );

                          if (result == true) {
                            await reloadRestaurant();
                          }
                        },

                        icon: const Icon(Icons.rate_review),

                        label: const Text(
                          "Xem đánh giá",
                        ),
                      ),

                      const SizedBox(width: 5),

                      Container(
                        margin: const EdgeInsets.only(
                          left: 10,
                        ),

                        child: Text(
                          '(${restaurantData["review_count"] ?? 0} đánh giá)',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            callPhone();
                          },

                          icon: const Icon(Icons.call),
                          label: const Text("Gọi điện"),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            openMap(context);
                          },
                          
                          icon: const Icon(Icons.map),
                          label: const Text("Bản đồ"),
                        ),
                      ), 
                    ],
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton.icon(
                      onPressed: () async {

                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddReviewScreen(
                              restaurantId: restaurantData["restaurant_id"],
                            ),
                          ),
                        );
                         if (result == true) {
                          await reloadRestaurant();
                        }
                      },

                      icon: const Icon(
                        Icons.rate_review,
                      ),

                      label: const Text(
                        "Viết đánh giá",
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        widget.onToggleFavorite(
                          Map<String, dynamic>.from(restaurantData),
                        );

                        setState(() {
                          favorite = !favorite;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              favorite
                                  ? "Đã thêm vào danh sách yêu thích"
                                  :"Đã gỡ khỏi danh sách yêu thích",
                            ),
                          ),
                        );
                      },

                      icon: Icon(
                        favorite
                            ? Icons.favorite_border
                            : Icons.favorite,
                      ),

                      label: Text(
                        favorite
                            ? "Gỡ khỏi yêu thích"
                            : "Thêm vào yêu thích",
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Mô tả",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    restaurantData["description"] ?? "Chưa có mô tả",
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ] 
              ),
            ),
          ],
        ),
      ),
    );
  }
}