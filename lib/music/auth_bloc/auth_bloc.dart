import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

import '../../repositories/auth/user_auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  UserAuthRepository _authRepo = UserAuthRepository();

  AuthBloc() : super(AuthInitial()) {
    on<VerifyAuthEvent>(_authVerfication);
    on<AnonymousAuthEvent>(_authAnonymous);
    on<GoogleAuthEvent>(_authUser);
    on<SignOutEvent>(_signOut);
  }

  FutureOr<void> _authVerfication(event, emit) {
    if (_authRepo.isAuthenticated()) {
      emit(AuthSuccessState());
    } else {
      emit(UnAuthState());
    }
  }

  FutureOr<void> _signOut(event, emit) async {
    try {
      print('signing out');

      await _authRepo.signOut();

      print('signed out');

      print('Sign out success');

      ScaffoldMessenger.of(event.buildcontext)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Has cerrado sesión'),
          ),
        );

      emit(SignOutSuccessState());
    } catch (e) {
      emit(AuthErrorState());
    }
  }

  FutureOr<void> _authUser(event, emit) async {
    emit(AuthAwaitingState());
    try {
      await _authRepo.signInWithGoogle();

      ScaffoldMessenger.of(event.buildcontext)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Has iniciado sesión'),
          ),
        );

      emit(AuthSuccessState());
    } catch (e) {
      ScaffoldMessenger.of(event.buildcontext)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error al iniciar sesión: $e'),
          ),
        );
      emit(AuthErrorState());
    }
  }

  FutureOr<void> _authAnonymous(event, emit) {
    // TODO:
  }
}
