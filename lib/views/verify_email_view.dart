import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    void sendVerification() async {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Email"),
        backgroundColor: Colors.amber,
      ),
      body: Column(
        children: [
          const Text("Please verify your email adress"),
          TextButton(
            onPressed: sendVerification,
            child: const Text("Send email verification"),
          ),
        ],
      )
    );
    
  }
}
