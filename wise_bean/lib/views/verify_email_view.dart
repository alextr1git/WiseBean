import 'package:flutter/material.dart';
import 'package:wise_bean/constants/routes.dart';
import 'package:wise_bean/services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify email')),
      body: Column(children: [
        const Text(
            "We've sent you an email verification. Please verify your account."),
        const Text(
            "If you haven't received verification yet, please press the button belows"),
        TextButton(
            onPressed: () async {
              AuthService.firebase().sendVerification();
            },
            child: const Text("Resend email verification")),
        TextButton(
          onPressed: () async {
            await AuthService.firebase().logOutUser();
            Navigator.of(context).pushNamedAndRemoveUntil(
              signUpRoute,
              (route) => false,
            );
          },
          child: const Text('Go back'),
        )
      ]),
    );
  }
}
