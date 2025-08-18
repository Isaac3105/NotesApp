import 'package:flutter/material.dart';
import 'package:to_do_app/constants/routes.dart';
import 'package:to_do_app/services/auth/auth_service.dart';
import 'package:to_do_app/util.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Email"),
        backgroundColor: Colors.amber,
      ),
      body: Center(
        child: Column(
          children: [
            const Text(
              "We've already sent a email verification to your account.",
            ),
            const Text(
              "If you haven't received a verification email, please pres the button below:",
            ),
            TextButton(
              onPressed: () => sendVerification(context),
              child: const Text("Send email verification"),
            ),
            TextButton(
              onPressed: () async {
                await AuthService.firebase().logOut();
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(registerRoute, (route) => false);
                }
              },
              child: const Text("Restart"),
            ),
          ],
        ),
      ),
    );
  }
}

void sendVerification(BuildContext context) async {
  await AuthService.firebase().sendEmailVerification();
  if (context.mounted) {
    await showMessageDialog(context, "Email Authentification", "Email sent.");
  }
}
