import 'package:flutter/material.dart';
import 'package:wise_bean/views/signup_view.dart';
import 'package:wise_bean/views/home_page.dart';
import 'package:wise_bean/views/login_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Wise Bean',
    initialRoute: '/',
    routes: {
      '/': (context) => const HomePage(),
      '/login': (context) => const LoginView(),
      '/signUp': (context) => const SignUpView(),
    },
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
  ));
}
