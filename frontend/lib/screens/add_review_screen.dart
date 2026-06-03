import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddReviewScreen extends StatefulWidget {

  final String restaurantId;

  const AddReviewScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  State<AddReviewScreen> createState()
      => _AddReviewScreenState();
}

class _AddReviewScreenState
    extends State<AddReviewScreen> {

  final commentController =
      TextEditingController();

  int rating = 5;

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Thêm đánh giá",
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            DropdownButton<int>(
              value: rating,

              items: [1,2,3,4,5]
                  .map(
                    (e) =>
                        DropdownMenuItem(
                      value: e,
                      child: Text(
                        "$e sao",
                      ),
                    ),
                  )
                  .toList(),

              onChanged: (value) {
                setState(() {
                  rating = value!;
                });
              },
            ),

            TextField(
              controller:
                  commentController,

              maxLines: 4,

              decoration:
                  const InputDecoration(
                labelText:
                    "Nội dung đánh giá",
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton(
              onPressed: () async {
                try {
                  await ApiService.createReview(
                    widget.restaurantId,
                    rating,
                    commentController.text,
                  );

                  if (!mounted) return;

                  Navigator.pop(context, true);

                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Lỗi: $e"),
                    ),
                  );
                }
              },

              child: const Text(
                "Gửi đánh giá",
              ),
            ),
          ],
        ),
      ),
    );
  }
}