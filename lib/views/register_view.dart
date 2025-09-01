import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/services/auth/auth_exceptions.dart';
import 'package:notes_app/services/auth/bloc/auth_bloc.dart';
import 'package:notes_app/services/auth/bloc/auth_event.dart';
import 'package:notes_app/services/auth/bloc/auth_state.dart';
import 'package:notes_app/utils/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool passwordHidden = true;

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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if( state is AuthStateRegistering){
            if(state.exception is WeakPasswordAuthException){
              await showErrorDialog(context, 'The password provided is too weak.');
            } else if(state.exception is InvalidEmailAuthException){
              await showErrorDialog(context, 'The email provided is invalid.');
            } else if(state.exception is EmailAlreadyInUseAuthException){
              await showErrorDialog(context, 'An account already exists for that email.');
            } else if(state.exception is GenericAuthException){
              await showErrorDialog(context, 'Failed to register');
            }
          }
        },
        child: Scaffold(
          body:SafeArea( 
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.note_alt,
                            size: 64,
                            color: Colors.amber,
                          ),
                        ),

                        const SizedBox(height: 24),
                        
                        Text(
                          "Greetings!",
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                        ),
                        
                        const SizedBox(height: 8),

                        Text(
                          "Create your account with an email and password",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          controller: _email,
                          autocorrect: false,
                          enableSuggestions: false,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    passwordHidden = !passwordHidden;
                                  });
                                }, 
                                icon: Icon(passwordHidden? Icons.visibility : Icons.visibility_off),
                              )
                          ),
                          controller: _password,
                          obscureText: passwordHidden,
                          autocorrect: false,
                          enableSuggestions: false,
                        ),
                        const SizedBox(height: 24),
                        
                        ElevatedButton(
                          onPressed: () async {
                            final email = _email.text;
                            final password = _password.text;
                            context.read<AuthBloc>().add(AuthEventRegister(email, password,));
                          },
                          child: const Text("Register"),
                        ),
                        const SizedBox(height: 16),
                        
                        TextButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(const AuthEventLogOut());
                          },
                          child: const Text("Registered? Go to Login!"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          )
        )
      )
    );
  }
}
