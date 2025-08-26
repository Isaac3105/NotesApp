import 'package:flutter/material.dart';
import 'package:to_do_app/services/auth/auth_user.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthStateOnInitialize extends AuthState {
  const AuthStateOnInitialize();
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;
  const AuthStateRegistering({required this.exception});
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn({required this.user});
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification();
}

class AuthStateLoggedOut extends AuthState with EquatableMixin{
  final Exception? exeption;
  final bool isLoading;
  const AuthStateLoggedOut({required this.exeption, required this.isLoading});
  
  @override
  List<Object?> get props => [exeption,isLoading];
}
