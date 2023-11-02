import 'package:flutter/material.dart';
import 'package:wise_bean/views/SignUpPage.dart';
import 'package:wise_bean/views/home_page.dart';
import 'package:wise_bean/views/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Wise Bean',
    initialRoute: '/login',
    routes: {
      '/': (context) => const HomePage(),
      '/login': (context) => const LoginPage(),
      '/signUp': (context) => const SignUpPage(),
    },
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
  ));
}
