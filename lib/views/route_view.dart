import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:to_do_app/firebase_options.dart';
import 'package:to_do_app/views/login_view.dart';
import 'verify_email_view.dart';

class RouteView extends StatelessWidget {
  const RouteView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, asyncSnapshot) {
        switch (asyncSnapshot.connectionState) {
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            if (user?.emailVerified ?? false) {
              print("verified user");
            } else {
              print("not verified user");
              return const LoginView();
            }
            print("tá aquiiiiiiiii: ${user}");
            return const Text("Done");
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
