import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../services/token_storage.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  final Function(String) onLogin;

  const LoginScreen({
    super.key,
    required this.onLogin,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final String baseUrl = "http://10.0.2.2:8000";
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String error = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  const Text("Đăng nhập"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            TextField(
              controller: usernameController,

              decoration: const InputDecoration(
                labelText: "Tên đăng nhập",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,

              decoration: const InputDecoration(
                labelText: "Mật khẩu",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            if (error.isNotEmpty)
              Text(
                error,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
          

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {

                try {

                  await ApiService.login(
                    usernameController.text,
                    passwordController.text,
                  );

                  final me =
                      await ApiService.getMe();

                  final prefs =
                      await SharedPreferences.getInstance();

                  await prefs.setString(
                    "user_id",
                    me["user_id"].toString(),
                  );

                  await prefs.setString(
                    "username",
                    me["user_name"].toString(),
                  );

                  print("ME = $me");
 
                  setState(() {
                    error = "";
                  });

                  widget.onLogin(
                    me["user_name"].toString(),
                  );

                } catch (e) {

                  print("LOGIN ERROR = $e");

                  setState(() {
                    error = "Sai tài khoản hoặc mật khẩu";
                  });

                }
              },

              child: const Text(
                "Đăng nhập",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> login() async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "username": usernameController.text,
          "password": passwordController.text,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data["access_token"];

        await TokenStorage.saveToken(token);

        setState(() {
          error = "";
        });

        widget.onLogin(usernameController.text);
      } else {
        setState(() {
          error = data["detail"] ?? "Sai tài khoản hoặc mật khẩu";
        });
      }
    } catch (e) {
      setState(() {
        error = "Không kết nối được server";
      });
    }
  }
}