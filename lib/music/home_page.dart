// ignore_for_file: avoid_print, no_leading_underscores_for_local_identifiers, unused_element, prefer_const_constructors, unused_local_variable, unnecessary_import, prefer_const_literals_to_create_immutables, sort_child_properties_last, depend_on_referenced_packages

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:music_app/music/music_bloc/music_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FindTrackApp'),
      ),
      body: Column(
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 48),
              child: SizedBox(
                height: 72,
                child: _recordMusic(),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              BlocProvider.of<MusicBloc>(context).add(RecordMusicEvent());
            },
            child: _showRecordButton(context),
          ),
          SizedBox(
            height: 48,
          ),
          Center(
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                onPressed: () {
                  _showFavorites(context);
                },
                icon: Icon(Icons.favorite_sharp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFavorites(BuildContext context) {
    Navigator.pushNamed(context, '/favorites');
  }

  Widget _getRecordImage() {
    return Container(
      constraints: BoxConstraints.tightFor(
        height: 200,
      ),
      child: Image.asset(
        "assets/music.png",
        height: 200,
      ),
    );
  }

  Widget _showRecordButton(BuildContext context) {
    if (BlocProvider.of<MusicBloc>(context).state is MusicLoadingState) {
      return Container(
        constraints: BoxConstraints.tightFor(
          height: 300,
        ),
        child: AvatarGlow(
          endRadius: 175.0,
          glowColor: Colors.purpleAccent,
          repeat: true,
          showTwoGlows: true,
          duration: Duration(milliseconds: 1000),
          child: _getRecordImage(),
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.only(
          top: 50,
          bottom: 50,
        ),
        child: _getRecordImage(),
      );
    }
  }

  Widget _recordingProgressText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 20,
      ),
    );
  }

  BlocConsumer<MusicBloc, MusicState> _recordMusic() {
    return BlocConsumer<MusicBloc, MusicState>(
      listener: (context, state) {
        setState(() {});
        if (state is MusicErrorState) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
              ),
            );
        } else if (state is MusicLoadedState) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamed(context, '/music');
          });
        }
      },
      builder: (context, state) {
        print("--------------------\nState: $state\n---------------------");
        switch (state.runtimeType) {
          case MusicLoadingState:
            return _recordingProgressText((state as MusicLoadingState).message);
          case MusicGettingInfoState:
            return Column(
              children: [
                _recordingProgressText("Obteniendo información"),
                SizedBox(
                  height: 10,
                ),
                CircularProgressIndicator(
                  color: Colors.purpleAccent,
                ),
              ],
            );
          default:
            return _recordingProgressText("Toque para escuchar");
        }
      },
    );
  }
}
