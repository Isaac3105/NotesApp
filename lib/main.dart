import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:to_do_app/constants/routes.dart';
import 'package:to_do_app/services/auth/auth_service.dart';
import 'package:to_do_app/views/login_view.dart';
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
      home: const RouteView(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        verifyRoute: (context) => const VerifyEmailView(),
        todoRoute: (context) => const ToDoView(),
      },
    ),
  );
}
