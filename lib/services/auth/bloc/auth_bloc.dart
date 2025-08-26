import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/services/auth/auth_provider.dart';
import 'package:to_do_app/services/auth/bloc/auth_event.dart';
import 'package:to_do_app/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateOnInitialize()) {
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
        emit(AuthStateNeedsVerification());
      } on Exception catch(e) {
        emit(AuthStateRegistering(exception: e));
      }
    });

    on<AuthEventShouldRegister>((event, emit) async {
      emit(AuthStateRegistering(exception: null));
    });
    
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(exeption: null, isLoading: false));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLoggedIn(user: user));
      }
    });

    on<AuthEventLogIn>((event, emit) async {
      emit(const AuthStateLoggedOut(exeption: null, isLoading: true));
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.logIn(email: email, password: password);
        if(!user.isEmailVerified){
          emit(const AuthStateLoggedOut(exeption: null, isLoading: false));
          emit(const AuthStateNeedsVerification());
        } else {
          emit(const AuthStateLoggedOut(exeption: null, isLoading: false));
          emit(AuthStateLoggedIn(user: user));
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exeption: e, isLoading: false));
      }
    });

    on<AuthEventLogOut>((event, emit) async {
      emit(const AuthStateLoggedOut(exeption: null, isLoading: true));
      try {
        await provider.logOut();
        emit(const AuthStateLoggedOut(exeption: null, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exeption: e, isLoading: false));
      }
    });
  }
}
