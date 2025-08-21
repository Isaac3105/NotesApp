import 'package:flutter/material.dart';
import 'package:to_do_app/constants/routes.dart';
import 'package:to_do_app/services/auth/auth_exceptions.dart';
import 'package:to_do_app/services/auth/auth_service.dart';
import 'package:to_do_app/utils/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
    void registerFirebase() async {
      final email = _email.text;
      final password = _password.text;
      try {
        await AuthService.firebase().createUser(
          email: email,
          password: password,
        );
        if (context.mounted) {
          await AuthService.firebase().sendEmailVerification();
          if (context.mounted) Navigator.of(context).pushNamed(verifyRoute);
        }
      } on InvalidEmailAuthException catch (_) {
        if (context.mounted) {
          await showErrorDialog(
            context,
            'The email provided is invalid.',
          );
        }
      } on WeakPasswordAuthException catch (_) {
        if (context.mounted) {
          await showErrorDialog(
            context,
            'The password provided is too weak.',
          );
        }
      } on EmailAlreadyInUseAuthException catch (_) {
        if (context.mounted) {
          await showErrorDialog(
            context,
            'An account already exists for that email.',
          );
        }
      } on GenericAuthException catch (_) {
        if (context.mounted) {
          await showErrorDialog(
            context,
            'Authentication error',
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: Colors.amber,
      ),
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
          TextButton(
            onPressed: registerFirebase,
            child: const Text("Register"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(loginRoute, (context) => false);
            },
            child: const Text("Registered? Go to Login!"),
          ),
        ],
      ),
    );
  }
}
