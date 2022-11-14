import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:music_app/music/favorites_bloc/favorites_bloc.dart';
import 'package:music_app/music/music_bloc/music_bloc.dart';
import 'package:music_app/music/home_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'music/auth_bloc/auth_bloc.dart';
import 'music/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MusicBloc(),
        ),
        BlocProvider(
          create: (context) => FavoritesBloc(),
        ),
        BlocProvider(
          create: (context) => AuthBloc()..add(VerifyAuthEvent()),
        ),
      ],
      child: MusicApp(),
    ),
  );
}

class MusicApp extends StatelessWidget {
  MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthErrorState) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.toString()),
                ),
              );
          }
        },
        builder: (context, state) {
          if (state is AuthSuccessState) {
            return HomePage();
          } else if (state is UnAuthState ||
              state is AuthErrorState ||
              state is SignOutSuccessState) {
            return LoginPage();
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
