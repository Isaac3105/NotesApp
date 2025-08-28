import 'package:firebase_core/firebase_core.dart';
import 'package:to_do_app/firebase_options.dart';
import 'package:to_do_app/services/auth/auth_user.dart';
import 'package:to_do_app/services/auth/auth_provider.dart' as auth_provider;
import 'package:to_do_app/services/auth/auth_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthProvider implements auth_provider.AuthProvider {
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotFoundAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else if (e.code == 'weak-password') {
        throw WeakPasswordAuthException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (e) {
      throw UnknownException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw UserNotFoundAuthException();
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw InvalidCredentialAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (e) {
      throw UnknownException();
    }
  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await  FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }
  
  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
  }
  
  @override
  Future<void> sendPasswordReset({required String email}) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  } on FirebaseAuthException catch(e) {
    switch (e.code) {
      case "firebase_auth/invalid-email":
        throw InvalidEmailAuthException();
      case "firebase_auth/user-not-found":
        throw UserNotFoundAuthException();
      default:
        throw GenericAuthException();
    }
  } catch (_) {
    throw GenericAuthException();
  }
  }
}
