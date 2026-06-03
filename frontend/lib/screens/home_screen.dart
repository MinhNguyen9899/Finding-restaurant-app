import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diacritic/diacritic.dart';
import '../services/api_service.dart';
import 'detail_screen.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final List<Map<String, dynamic>> favoriteRestaurants;
  final Function(Map<String, dynamic>) onToggleFavorite;
  const HomeScreen({
    super.key,
    required this.favoriteRestaurants,
    required this.onToggleFavorite,
  });

  @override
  State<HomeScreen> createState()  => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> restaurants = [];
  List<Map<String, dynamic>> filteredRestaurants = [];
  List<Map<String, dynamic>> recentRestaurants = [];
  bool loading = true;

  List<String> searchHistory = [];

  List<dynamic> categories = [];
  List<dynamic> areas = [];
  
  int? selectedCategoryId;
  int? selectedAreaId;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
    loadSearchHistory();
    loadRecentRestaurants();
    loadCategories();
    loadAreas();
  }

  Future<void> loadCategories() async {
    try {
      final data =
          await ApiService.getCategories();

      setState(() {
        categories = data;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> loadAreas() async {
    try {
      final data =
          await ApiService.getAreas();

      setState(() {
        areas = data;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void fetchData() async {
    try{
      final data = await ApiService.getRestaurants(
        keyword: searchController.text.isEmpty
            ? null
            : searchController.text,
        
        categoryId: selectedCategoryId,
        areaId: selectedAreaId,
      );
      
      setState(() {
        restaurants = List<Map<String, dynamic>>.from(data);
        filteredRestaurants = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;        
      });
      debugPrint(e.toString());
    }
  }

  // SEARCH
  void searchRestaurant(String keyword) {
    final searchText = removeDiacritics(keyword.toLowerCase());

    final results = restaurants.where((item) {
      final name = removeDiacritics(
        (item["restaurant_name"] ?? "")
            .toString()
            .toLowerCase(),
      );

      final address = removeDiacritics(
        (item["address"] ?? "")
        .toString()
        .toLowerCase(),
      );

      return name.contains(searchText) || address.contains(searchText);
    }).toList();

    setState(() {
      filteredRestaurants = results;
    });
  }

  void addSearchHistory(String keyword) {
    if (keyword.isEmpty) return;

    setState(() {
      searchHistory.remove(keyword);

      searchHistory.insert(0, keyword);

      if (searchHistory.length >10) {
        searchHistory.removeLast();
      }
    });

    saveSearchHistory();
  }

  // FILTER CATEGORY
  void filterCategory(String category) {
    final results = restaurants.where((item) {
      final name = item["restaurant_name"]
          .toString()
          .toLowerCase();

      return name.contains(category.toLowerCase());
    }).toList();

    setState(() {
      filteredRestaurants = results;
    });
  }

  //RESET FILTER
  void resetFilter() {
    setState(() {
      filteredRestaurants = restaurants;
    });
  }

  Future<void> saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList("searchHistory", searchHistory);
  } 

  Future<void> loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      searchHistory = prefs.getStringList("searchHistory") ?? [];
    });
  }

  Future<void> loadRecentRestaurants() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString("recentRestaurants");

    if (data != null) {
      setState(() {
        recentRestaurants = List<Map<String, dynamic>>.from(jsonDecode(data),
        );
      });
    }
  }

  Future<void> saveRecentRestaurants() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      "recentRestaurants",
      jsonEncode(recentRestaurants),
    );
  }

  void addRecentRestaurant(
    Map<String, dynamic> restaurant,
  ) {
    setState(() {
      recentRestaurants.removeWhere(
        (item) =>
            item["restaurant_id"] ==
            restaurant["restaurant_id"],
      );

      recentRestaurants.insert(
        0,
        restaurant,
      );

      if (recentRestaurants.length > 10) {
        recentRestaurants.removeLast();
      }
    });

    saveRecentRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
        
          decoration: InputDecoration(
            hintText: "Tìm quán ăn...",
            border: InputBorder.none,

            prefixIcon: const Icon(Icons.search),

            suffixIcon: IconButton(
              onPressed: () {
                searchController.clear();

                setState(() {
                  filteredRestaurants = restaurants;
                });
              },
              icon: const Icon(Icons.clear),
            ),
          ),

          onSubmitted: (value){
            addSearchHistory(value);
            fetchData();
          },
        ),
      ),

      body: Column(
        children: [

          if (searchHistory.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Tìm kiếm gần đây",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      TextButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove(
                            "searchHistory",
                          );

                          setState(() {
                            searchHistory.clear();
                          });
                        },
                        child: const Text(
                          "Xóa",
                        ),
                      ),
                    ],
                  ),

                  Wrap(
                    spacing: 8,

                    children: searchHistory
                        .take(5)
                        .map(
                          (keyword) => ActionChip(
                            label: Text(keyword),
                            
                            onPressed: (){
                              searchController.text = keyword;
                              fetchData();
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 5),

          Padding(
            padding: const EdgeInsets.all(10),

            child: DropdownButtonFormField<int>(
              value: selectedCategoryId,

              decoration: const InputDecoration(
                labelText: "Danh mục",
                border: OutlineInputBorder(),
              ),

              items: [
                const DropdownMenuItem<int>(
                  value: null,
                  child: Text("Tất cả"),
                ),

                ...categories.map(
                  (category) =>
                      DropdownMenuItem<int>(
                    value: category["category_id"],

                    child: Text(
                      category["category_name"],
                    ),
                  ),
                ),
              ],

              onChanged: (value) {
                setState(() {
                  selectedCategoryId = value;
                });

                fetchData();
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10),

            child: DropdownButtonFormField<int>(
              value: selectedAreaId,

              decoration: const InputDecoration(
                labelText: "Khu vực",
                border: OutlineInputBorder(),
              ),

              items: [
                const DropdownMenuItem<int>(
                  value: null,
                  child: Text("Tất cả"),
                ),

                ...areas.map(
                  (area) =>
                      DropdownMenuItem<int>(
                    value: area["area_id"],

                    child: Text(
                      area["area_name"],
                    ),
                  ),
                ),
              ],

              onChanged: (value) {
                setState(() {
                  selectedAreaId = value;
                });

                fetchData();
              },
            ),
          ),

          if (recentRestaurants.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(10),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Đã xem gần đây",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      TextButton(
                        onPressed: () async {
                          final prefs =
                              await SharedPreferences.getInstance();

                          await prefs.remove("recentRestaurants");

                          setState(() {
                            recentRestaurants.clear();
                          });
                        },
                        child: const Text("Xóa"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    height: 50,

                    child: ListView.builder(
                      scrollDirection:
                          Axis.horizontal,

                      itemCount:
                          recentRestaurants.length,

                      itemBuilder:
                          (context, index) {
                        final item =
                            recentRestaurants[index];

                        return Container(
                          width: 180,
                          margin:
                              const EdgeInsets.only(
                            right: 10,
                          ),

                          child: Card(
                            child: Padding(
                              padding:
                                  const EdgeInsets.all(
                                      10),
                              child: Text(
                                item[
                                        "restaurant_name"] ??
                                    "",
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // LIST
          Expanded(
            child: loading
                ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.orange,
                      ),

                      SizedBox(height: 15),

                      Text(
                        "Đang tải dữ liệu",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      )
                    ],
                  ),
                )

                : filteredRestaurants.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 80,
                            color: Colors.grey,
                          ),

                          const SizedBox(height: 15),

                          const Text(
                            "Không tìm thấy quán ăn",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text (
                            "Hãy thử từ khóa khác",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],        
                      ),
                    )
                
                  : ListView.builder(
                    itemCount: filteredRestaurants.length,

                    itemBuilder: (context, index) {
                      final item = filteredRestaurants[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8
                        ),

                        elevation: 4,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),

                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),

                          onTap: () {
                            addRecentRestaurant(item);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(
                                  restaurant: item,
                                  onToggleFavorite: widget.onToggleFavorite,

                                  isFavorite: widget.favoriteRestaurants.any(
                                    (restaurant) => restaurant["restaurant_id"] == item["restaurant_id"],
                                  ),
                                ),
                              ),
                            );
                          },

                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            
                            child: Row(
                              children: [

                                //IMAGE
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),

                                  child: Image.asset(
                                    "assets/images/default.jpg",
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                const SizedBox(width: 15),

                                // INFO
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,

                                    children: [
                                      Text(
                                        item["restaurant_name"] ?? "",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 5),

                                      Text(
                                        item["category_name"] ?? "Chưa phân loại",
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      const SizedBox(height: 5),

                                      Text(item["address"] ?? "Chưa có địa chỉ"),

                                      const SizedBox(height: 5),

                                      Row (
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [

                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("⭐ ${item["average_rating"] ?? 0}",
                                                style: const TextStyle(
                                                  color: Colors.orange,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              
                                              Text(
                                                 "${item["review_count"] ?? 0} đánh giá",
                                                 style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                 ),
                                              ),
                                            ],
                                          ),

                                          IconButton(
                                            onPressed: () {
                                              widget.onToggleFavorite(item);
                                            },

                                            icon: Icon(
                                              widget.favoriteRestaurants.any(
                                                (restaurant) =>
                                                    restaurant["restaurant_id"] == item["restaurant_id"],
                                              )
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: Colors.red,
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
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
} 