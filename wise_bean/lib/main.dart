import 'package:flutter/material.dart';
import 'package:wise_bean/constants/routes.dart';
import 'package:wise_bean/views/reviews_view.dart';
import 'package:wise_bean/views/signup_view.dart';
import 'package:wise_bean/views/home_page.dart';
import 'package:wise_bean/views/login_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Wise Bean',
    initialRoute: homeRoute,
    routes: {
      homeRoute: (context) => const HomePage(),
      loginRoute: (context) => const LoginView(),
      signUpRoute: (context) => const SignUpView(),
      reviewsRoute: (context) => const ReviewsView(),
    },
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
  ));
}
