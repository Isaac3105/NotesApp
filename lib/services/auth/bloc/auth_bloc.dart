import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/services/auth/auth_provider.dart';
import 'package:to_do_app/services/auth/bloc/auth_event.dart';
import 'package:to_do_app/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateOnInitialize(isLoading: true)) {
    on<AuthEventForgotPassword>((event,emit) async {
      emit(const AuthStateForgotPassword(exception: null, hasSentEmail: false, isLoading: false));
      final email = event.email;
      if(email != null){
        emit(const AuthStateForgotPassword(exception: null, hasSentEmail: false, isLoading: true));
        Exception? exception;
        bool? hasSentEmail;
        try {
          await provider.sendPasswordReset(email: email);
          exception = null;
          hasSentEmail = true;
        } on Exception catch (e) {
          exception = e;
          hasSentEmail = false;
        }
        emit(AuthStateForgotPassword(exception: exception, hasSentEmail: hasSentEmail, isLoading: false));
      }
    });

    on<AuthEventSendEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });

    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;
      try {
        await provider.createUser(email: email, password: password);
        await provider.sendEmailVerification();
        emit(AuthStateNeedsVerification(isLoading: false));
      } on Exception catch(e) {
        emit(AuthStateRegistering(exception: e, isLoading: false));
      }
    });

    on<AuthEventShouldRegister>((event, emit) async {
      emit(AuthStateRegistering(exception: null, isLoading: false));
    });
    
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification(isLoading: false));
      } else {
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      }
    });

    on<AuthEventLogIn>((event, emit) async {
      emit(const AuthStateLoggedOut(
        exception: null, 
        isLoading: true, 
        loadingText: "Please wait while I log you in",
      ));
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.logIn(email: email, password: password);
        if(!user.isEmailVerified){
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
          emit(const AuthStateNeedsVerification(isLoading: false));
        } else {
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
          emit(AuthStateLoggedIn(user: user, isLoading: false));
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });

    on<AuthEventLogOut>((event, emit) async {
      emit(const AuthStateLoggedOut(exception: null, isLoading: true));
      try {
        await provider.logOut();
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });
  }
}
