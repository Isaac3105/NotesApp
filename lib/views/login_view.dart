import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/services/auth/auth_exceptions.dart';
import 'package:to_do_app/services/auth/bloc/auth_bloc.dart';
import 'package:to_do_app/services/auth/bloc/auth_event.dart';
import 'package:to_do_app/services/auth/bloc/auth_state.dart';
import 'package:to_do_app/utils/dialogs/error_dialog.dart';
import 'package:to_do_app/utils/dialogs/loading_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  CloseDialog? _closeDialogHandle;

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {

          final closeDialog = _closeDialogHandle;

          if(!state.isLoading && closeDialog != null){
            closeDialog();
            _closeDialogHandle = null;
          } else if(state.isLoading && closeDialog == null){
            _closeDialogHandle = showLoadingDialog(context: context, text: 'Loading...');
          }
          if (state.exeption is UserNotFoundAuthException) {
            await showErrorDialog(context, "User not found");
          } else if (state.exeption is WrongPasswordAuthException ||
              state.exeption is InvalidCredentialAuthException) {
            await showErrorDialog(context, "Wrong credentials");
          } else if (state.exeption is GenericAuthException) {
            await showErrorDialog(context, 'Failed to login');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Login"),
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
              onPressed: () {
                final email = _email.text;
                final password = _password.text;
                context.read<AuthBloc>().add(AuthEventLogIn(email, password));
              },
              child: const Text("Log In"),
            ),
            TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(const AuthEventShouldRegister());
              },
              child: const Text("Not registered yet? Press here!"),
            ),
          ],
        ),
      ),
    );
  }
}
