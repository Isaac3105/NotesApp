import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:to_do_app/constants/routes.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;

  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void logInFirebase() async {
      final email = _email.text;
      final password = _password.text;
      try {
        final navigator = Navigator.of(context);

        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (!mounted) return;

        navigator.pushNamedAndRemoveUntil(todoRoute, (route) => false);

        devtools.log(FirebaseAuth.instance.currentUser.toString());
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          
          devtools.log('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          devtools.log('Wrong password provided for that user.');
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Login"), backgroundColor: Colors.amber),
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Enter your email here',
            ),
            controller: _email,
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.emailAddress,
          ),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Enter your password here',
            ),
            controller: _password,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
          ),
          TextButton(onPressed: logInFirebase, child: const Text("Log In")),
          TextButton(
            onPressed: () {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(registerRoute, (route) => false);
            },
            child: const Text("Not registered yet? Press here!"),
          ),
        ],
      ),
    );
  }
}
