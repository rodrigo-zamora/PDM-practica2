import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:music_app/music/music_bloc/music_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_bloc/auth_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 64,
          ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
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
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    onPressed: () {
                      _logoutDialog(context);
                    },
                    icon: Icon(Icons.power_settings_new),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFavorites(BuildContext context) {
    Navigator.pushNamed(context, '/favorites');
  }

  void _logoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cerrar sesión'),
          content: Text(
              'Al cerrar sesión de su cuenta, será redirigido a la pantalla de Log In. ¿Quiere continuar?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                BlocProvider.of<AuthBloc>(context)
                    .add(SignOutEvent(buildcontext: context));
              },
              child: Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );
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
