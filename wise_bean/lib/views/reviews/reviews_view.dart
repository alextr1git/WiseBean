import 'package:flutter/material.dart';
import 'package:wise_bean/constants/routes.dart';
import 'package:wise_bean/enums/menu_action.dart';
import 'package:wise_bean/services/auth/auth_service.dart';
import 'package:wise_bean/services/crud/review_service.dart';
import 'package:wise_bean/utilities/dialogs/logout_dialog.dart';
import 'package:wise_bean/views/reviews/reviews_list_view.dart';

class ReviewsView extends StatefulWidget {
  const ReviewsView({super.key});

  @override
  State<ReviewsView> createState() => _ReviewsViewState();
}

class _ReviewsViewState extends State<ReviewsView> {
  late final ReviewsService _reviewsService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _reviewsService = ReviewsService();
    _reviewsService.open();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your reviews'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(createUpdateReviewRoute);
                },
                icon: const Icon(Icons.add)),
            PopupMenuButton<MenuAction>(onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logOutUser();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (_) => false,
                    );
                  } else {}
              }
            }, itemBuilder: (context) {
              return [
                const PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Log out'),
                ),
              ];
            })
          ],
        ),
        body: FutureBuilder(
          future: _reviewsService.getOrCreateUser(email: userEmail),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return StreamBuilder(
                  stream: _reviewsService.allReviews,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.active:
                      //0 notes created
                      case ConnectionState.waiting:
                        if (snapshot.hasData) {
                          final allReviews =
                              snapshot.data as List<DatabaseReview>;
                          return ReviewsListView(
                            reviews: allReviews,
                            onDeleteReview: (review) async {
                              await _reviewsService.deleteReview(id: review.id);
                            },
                            onTap: (review) {
                              Navigator.of(context).pushNamed(
                                createUpdateReviewRoute,
                                arguments: review,
                              );
                            },
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      default:
                        return const CircularProgressIndicator();
                    }
                  },
                );
              default:
                return const CircularProgressIndicator();
            }
          },
          
        ));
  }
}
