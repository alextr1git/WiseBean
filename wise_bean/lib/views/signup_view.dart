import 'package:flutter/material.dart';
import 'package:wise_bean/constants/routes.dart';
import 'package:wise_bean/services/auth/auth_exceptions.dart';
import 'package:wise_bean/services/auth/auth_service.dart';
import 'package:wise_bean/utilities/dialogs/error_dialog.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  bool _obscurePassword = true;

//INITIALIZE VARIABLES
  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text(
              "We've never met before!",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 10),
            Text(
              "Create your account!",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                  hintText: 'Enter your email',
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              keyboardType: TextInputType.emailAddress,
              enableSuggestions: false,
              autocorrect: false,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: const Icon(Icons.password_outlined),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: _obscurePassword
                      ? const Icon(Icons.visibility_outlined)
                      : const Icon(Icons.visibility_off_outlined),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )),
                  onPressed: () async {
                    final email = _emailController.text;
                    final password = _passwordController.text;
                    try {
                      await AuthService.firebase().createUser(
                        id: email,
                        password: password,
                      );

                      AuthService.firebase().sendVerification();
                      Navigator.of(context).pushNamed(verifyEmailRoute);
                    } on WeakPasswordAuthException {
                      await showErrorDialog(
                        context,
                        "Your password is too weak!",
                      );
                    } on EmailAlreadyInUseAuthException {
                      await showErrorDialog(
                        context,
                        "This email is already taken!",
                      );
                    } on NetworkRequestFailedAuthException {
                      await showErrorDialog(
                        context,
                        "No internet connection!",
                      );
                    } on InvalidEmailAuthException {
                      await showErrorDialog(
                        context,
                        "Invalid email!",
                      );
                    } on GenericAuthException {
                      await showErrorDialog(
                        context,
                        "Something went wrong.",
                      );
                    }
                  },
                  child: const Text('Sign up'),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?"),
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginRoute, (route) => false);
                  },
                  child: const Text("Login into existing one"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
