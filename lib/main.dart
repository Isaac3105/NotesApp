import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:to_do_app/firebase_options.dart';
import 'package:to_do_app/views/login_view.dart';
import 'package:to_do_app/views/register_view.dart';
import 'package:to_do_app/views/verify_email_view.dart';
import 'package:to_do_app/views/to_do_view.dart';
import 'views/route_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const RouteView(),
      routes: {
        '/login' : (context) => const LoginView(),
        '/register' : (context) => const RegisterView(),
        '/verify': (context) => const VerifyEmailView(),
        '/todo': (context) => const ToDoView(),
      },
    ),
  );
}
