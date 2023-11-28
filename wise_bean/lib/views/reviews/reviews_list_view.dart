import 'package:flutter/material.dart';
import 'package:wise_bean/services/crud/review_service.dart';
import 'package:wise_bean/utilities/dialogs/delete_dialog.dart';

typedef ReviewCallback = void Function(DatabaseReview review);

class ReviewsListView extends StatelessWidget {
  final List<DatabaseReview> reviews;
  final ReviewCallback onDeleteReview;
  final ReviewCallback onTap;
  const ReviewsListView({
    super.key,
    required this.reviews,
    required this.onDeleteReview,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];

        return ListTile(
          onTap: () {
            onTap(review);
          },
          title: Text(
            review.remarks,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDeleteReview(review);
              }
            },
          ),
        );
      },
    );
  }
}
