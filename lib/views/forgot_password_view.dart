import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/services/auth/auth_exceptions.dart';
import 'package:notes_app/services/auth/bloc/auth_bloc.dart';
import 'package:notes_app/services/auth/bloc/auth_event.dart';
import 'package:notes_app/services/auth/bloc/auth_state.dart';
import 'package:notes_app/utils/dialogs/error_dialog.dart';
import 'package:notes_app/utils/dialogs/password_reset_email_sent_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {

  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthStateForgotPassword) {
            if (state.hasSentEmail) {
              _controller.clear();
              await showPasswordResetSentEmailDialog(context);
            }
            if (state.exception != null) {
              String message;
              if (state.exception is InvalidEmailAuthException){
                message = "Please check if you have correctly written your email.";
              } else {  
                message = "Please make sure that you are a registered user.";
              }
              if(context.mounted) await showErrorDialog(context, "We could not process your request. $message ");
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Reset Password"),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () {
                context.read<AuthBloc>().add(const AuthEventLogOut());
              },
            ),
          ),
          body: SafeArea(
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
                            Icons.lock_reset,
                            size: 48,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        Text(
                          "Reset Password",
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        Text(
                          "Forgot your password? Don't worry! It happens. Please enter the email address associated with your account.",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        
                        TextField(
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          autofocus: true,
                          controller: _controller,
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            hintText: 'Enter your email address',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        ElevatedButton(
                          onPressed: () {
                            String email = _controller.text;
                            context.read<AuthBloc>().add(AuthEventForgotPassword(email: email));
                          }, 
                          child: const Text("Send Reset Link"),
                        ),
                        const SizedBox(height: 16),
                        
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Check your email inbox and spam folder for the reset link.",
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        const Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text("OR"),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        OutlinedButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(const AuthEventLogOut());
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.arrow_back, size: 18),
                              SizedBox(width: 8),
                              Text("Back to Login"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}