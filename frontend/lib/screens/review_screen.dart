import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ReviewScreen extends StatefulWidget {
  final Map restaurant;

  const ReviewScreen({
    super.key,
    required this.restaurant,
  });

  @override
  State<ReviewScreen> createState() =>
    _ReviewScreenState();
}
class _ReviewScreenState extends State<ReviewScreen> {
  List reviews = [];
  bool loading = true;

  final TextEditingController reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadReviews();
  }

  Future<void> loadReviews() async {

    try {

      final data =
          await ApiService.getReviews(
        widget.restaurant["restaurant_id"].toString(),
      );
      
      print(data.runtimeType);
      print(data);

      setState(() {
        reviews = data;
        loading = false;
      });

    } catch (e, stackTrace) {

      print("ERROR = $e");
      print("STACKTRACE = $stackTrace");

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> showAddReviewDialog() async {

    final commentController =
        TextEditingController();

    int rating = 5;

    showDialog(
      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            "Đánh giá quán",
          ),

          content: StatefulBuilder(
            builder: (
              context,
              setDialogState,
            ) {

              return Column(
                mainAxisSize:
                    MainAxisSize.min,

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

                      setDialogState(() {
                        rating = value!;
                      });
                    },
                  ),

                  TextField(
                    controller:
                        commentController,

                    decoration:
                        const InputDecoration(
                      hintText:
                          "Nhập nhận xét",
                    ),
                  ),
                ],
              );
            },
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                "Hủy",
              ),
            ),

            ElevatedButton(
              onPressed: () async {

                await submitReview(
                  rating,
                  commentController.text,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text(
                "Gửi",
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> submitReview(
    int rating,
    String comment,
  ) async {
    print("SUBMIT REVIEW");
    print(rating);
    print(comment);

    try{
      await ApiService.createReview(
        widget.restaurant["restaurant_id"].toString(),
        rating,
        comment,
      );

      await loadReviews();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Đánh giá thành công",
          ),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.restaurant["restaurant_name"] ?? "Đánh giá",
        ),
      ),

      body: loading

    ? const Center(
        child:
            CircularProgressIndicator(),
      )

    : Column(
        children: [
          Expanded(
            child: reviews.isEmpty

                ? const Center(
                    child: Text(
                      "Chưa có đánh giá",
                    ),
                  )

                : ListView.builder(
                    itemCount:
                        reviews.length,

                    itemBuilder:
                        (context, index) {

                      final review =
                          reviews[index];

                      return Card(

                        margin:
                            const EdgeInsets.all(
                          10,
                        ),

                        child: ListTile(

                          leading:
                              const Icon(
                            Icons.person,
                          ),

                          title: Text(
                            review["username"]
                                    ??
                                "Ẩn danh",
                          ),

                          subtitle: Text(
                            review["comment"]
                                    ??
                                "",
                          ),

                          trailing: Text(
                            "⭐ ${review["rating"]}",
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
}

