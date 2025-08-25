import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/services/auth/bloc/auth_bloc.dart';
import 'package:to_do_app/services/auth/bloc/auth_event.dart';
import 'package:to_do_app/services/auth/bloc/auth_state.dart';
import 'package:to_do_app/views/login_view.dart';
import 'package:to_do_app/views/notes/notes_view.dart';
import 'verify_email_view.dart';

class RouteView extends StatelessWidget {
  const RouteView({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocBuilder<AuthBloc,AuthState>(
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const ToDoView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()), backgroundColor: Colors.black,
          );
        }
      },
    );
  }
}