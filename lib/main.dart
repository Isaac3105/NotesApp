import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:to_do_app/constants/routes.dart';
import 'package:to_do_app/services/auth/auth_service.dart';
import 'package:to_do_app/services/auth/bloc/auth_bloc.dart';
import 'package:to_do_app/services/auth/firebase_auth_provider.dart';
import 'package:to_do_app/views/login_view.dart';
import 'package:to_do_app/views/notes/create_update_note_view.dart';
import 'package:to_do_app/views/register_view.dart';
import 'package:to_do_app/views/verify_email_view.dart';
import 'package:to_do_app/views/notes/notes_view.dart';
import 'views/route_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await AuthService.firebase().initialize();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const RouteView(),
      ),
      routes: {
        createUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        verifyRoute: (context) => const VerifyEmailView(),
        todoRoute: (context) => const ToDoView(),
      },
    ),
  );
}
