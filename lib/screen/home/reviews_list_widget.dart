import 'package:flutter/material.dart';
import 'package:kaarigarhaat/models/review.dart';
import 'package:kaarigarhaat/utils/firestore_service.dart';
import '../../utils/colors.dart';

class ReviewsListWidget extends StatelessWidget {
  final String productId;

  const ReviewsListWidget({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<List<ReviewModel>>(
      stream: firestoreService.getProductReviews(productId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final reviews = snapshot.data ?? [];

        if (reviews.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text("No reviews yet. be the first to review!", style: TextStyle(color: Colors.grey)),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.background,
                        child: Text(review.userName[0].toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Row(
                              children: List.generate(5, (i) => Icon(
                                Icons.star, 
                                size: 12, 
                                color: i < review.rating ? Colors.amber : Colors.grey.shade300
                              )),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}",
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 48),
                    child: Text(
                      review.comment,
                      style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey.shade800, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
