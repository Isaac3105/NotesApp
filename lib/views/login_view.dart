import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as devtools show log;
import 'package:to_do_app/constants/routes.dart';
import 'package:to_do_app/services/auth/auth_exceptions.dart';
import 'package:to_do_app/services/auth/auth_service.dart';
import 'package:to_do_app/services/auth/bloc/auth_bloc.dart';
import 'package:to_do_app/services/auth/bloc/auth_event.dart';
import 'package:to_do_app/utils/dialogs/error_dialog.dart';

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
        context.read<AuthBloc>().add(AuthEventLogIn(email, password));
      } on UserNotFoundAuthException catch (_) {
        if (context.mounted) {
          await showErrorDialog(context, 'No user found for that email.');
        }
      } on WrongPasswordAuthException catch (_) {
        if (context.mounted) {
          await showErrorDialog(
            context,
            'Invalid email or password. Please try again.',
          );
        }
      } on InvalidCredentialAuthException catch (_) {
        if (context.mounted) {
          await showErrorDialog(
            context,
            'Invalid email or password. Please try again.',
          );
        }
      } on GenericAuthException catch (_) {
        if (context.mounted) {
          await showErrorDialog(context, 'Authentication error');
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
