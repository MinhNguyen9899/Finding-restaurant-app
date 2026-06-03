import 'package:flutter/material.dart';
import 'search_history_screen.dart';

class ProfileScreen extends StatelessWidget {
  final int favoriteCount;
  final String username;
  final VoidCallback onLogout;
  
  const ProfileScreen({
    super.key,
    required this.favoriteCount,
    required this.username,
    required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hồ sơ"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [

            Container(
              width: double.infinity,
              height: 180,
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 30,
                bottom: 40,),
              color: Colors.grey.shade200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration:  BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        username.isNotEmpty
                            ? username[0].toUpperCase()
                            : "?",
                        style: const TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                                
                  const SizedBox(width: 20),

                  Expanded(
                    child: SizedBox(
                      height: 90,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "$username@gmail.com",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),             
            ),

            const SizedBox(height: 30),

             ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Thông tin cá nhân"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.lock_clock_outlined),
              title: const Text("Đổi mật khẩu"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Lịch sử tìm kiếm"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SearchHistoryScreen(),
                  ),
                );
              },
            ),

            const Divider(),

             ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Cài đặt"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),

            const Divider(),

            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),

              title: const Text(
                "Đăng xuất",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),

              onTap: () async {
                final result = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Đăng xuất"),
                      content: const Text("Bạn có chắc muốn đăng xuất?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: const Text("Hủy"),
                        ),

                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          child: const Text("Đăng xuất"),
                        ),
                      ],
                    );
                  },
                );

                if (result == true) {
                  onLogout();
                }
              },
            ),
          ],
        ),
      )
    );
  }
}