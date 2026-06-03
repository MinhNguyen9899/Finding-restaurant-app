import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';
import 'favorite_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

import '../services/api_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  List<Map<String, dynamic>> favoriteRestaurants = [];
  bool isLoggedIn = false;
  String username = "";

  @override
  void initState() {
    super.initState();

    loadLogin();
  }

  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getString("user_id");
    print("SAVE FAVORITES FOR USER = $userId");

    await prefs.setString(
      "favorites_$userId",
      jsonEncode(favoriteRestaurants),
    );
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    
    final userId = prefs.getString("user_id");
    final data = prefs.getString("favorites_$userId");
    print("LOAD FAVORITES FOR USER = $userId");
    
    if (data != null) {
      final saved = 
        List<Map<String, dynamic>>.from(
          jsonDecode(data),
        );

      for(int i = 0; i < saved.length; i++) {
        final lastest = await ApiService.getRestaurant(
          saved[i]["restaurant_id"],
        );

        saved[i] = lastest;
      }
      setState(() {
        favoriteRestaurants = saved;
      });
    }
  }

  Future<void> saveLogin(String name) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      "isLoggedIn",
      true,
    );

    await prefs.setString(
      "username",
      name,
      );
  }

  Future<void> loadLogin() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
      username = prefs.getString("username") ?? "";
    });

     if (isLoggedIn) {
      await loadFavorites();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("token");
    await prefs.remove("user_id");
    await prefs.remove("isLoggedIn");
    await prefs.remove("username");

    setState(() {
      isLoggedIn = false;
      username = "";
      favoriteRestaurants = [];
    });
  }

  Future<void> reloadUserData(String name) async {
    await loadFavorites();

    setState(() {
      isLoggedIn = true;
      username = name;
    });
  }


  @override
  Widget build(BuildContext context) {
   
    if (!isLoggedIn) {
        return LoginScreen(
          onLogin: (name) async {
            await saveLogin(name);
            await reloadUserData(name);

            setState(() {
              isLoggedIn = true;
              username = name;
            });
          },
        );
      } 
    
    final List screens = [
      HomeScreen(
        favoriteRestaurants: favoriteRestaurants,

        onToggleFavorite: (Map<String, dynamic> restaurant) {
          setState(() {
            final exists = favoriteRestaurants.any(
              (item) =>
                  item["restaurant_id"] == restaurant["restaurant_id"],
            );

            if (exists) {
              favoriteRestaurants.removeWhere(
                (item) => item["restaurant_id"] == restaurant["restaurant_id"],
              );
            } else {

              favoriteRestaurants.add(
                Map<String, dynamic>.from(restaurant)
              );
            }

            saveFavorites();
          });
        },
      ),

      FavoriteScreen(
        favoriteRestaurants: favoriteRestaurants,
        onToggleFavorite: (restaurant){
          setState(() {
            final exists = favoriteRestaurants.any(
              (item) => item["restaurant_id"] == restaurant["restaurant_id"],
            );

            if (exists) {
              favoriteRestaurants.removeWhere(
                (item) => item["restaurant_id"] == restaurant["restaurant_id"],
              );
            } else {
              favoriteRestaurants.add(
                Map<String, dynamic>.from(restaurant),
              );
            }

            saveFavorites();
          });
        },
      ),

      ProfileScreen(
        favoriteCount: favoriteRestaurants.length,
        username: username,
        onLogout:logout,
      ),
    ];

    return Scaffold(
      body: screens[currentIndex],

      bottomNavigationBar: BottomNavigationBar( 
        currentIndex: currentIndex,

        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home", 
          ),

        BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorite",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    ); 
  }
}