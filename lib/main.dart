// ignore_for_file: prefer_const_constructors, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:music_app/music/favorites_bloc/favorites_bloc.dart';
import 'package:music_app/music/music_bloc/music_bloc.dart';
import 'package:music_app/music/favorites_page.dart';
import 'package:music_app/music/home_page.dart';
import 'package:music_app/music/music_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MusicBloc(),
        ),
        BlocProvider(
          create: (context) => FavoritesBloc(),
        ),
      ],
      child: MyApp(),
    ));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      routes: {
        '/': (context) => HomePage(),
        '/music': (context) => MusicPage(),
        '/favorites': (context) => FavoritesPage(),
      },
    );
  }
}
