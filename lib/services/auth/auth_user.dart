import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

@immutable
class AuthUser {
  final String email;
  final bool isEmailVerified;
  final String uid;
  const AuthUser({required this.uid, required this.email, required this.isEmailVerified});

  factory AuthUser.fromFirebase(User user) =>
      AuthUser(email: user.email!, isEmailVerified: user.emailVerified, uid: user.uid);
}
