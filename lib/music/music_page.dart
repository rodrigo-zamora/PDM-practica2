// ignore_for_file: avoid_print, no_leading_underscores_for_local_identifiers, unused_element, prefer_const_constructors, unused_local_variable, unnecessary_import, prefer_const_literals_to_create_immutables, sort_child_properties_last, depend_on_referenced_packages, must_be_immutable, avoid_unnecessary_containers, deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:music_app/music/favorites_bloc/favorites_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'music_bloc/music_bloc.dart';
import 'package:intl/intl.dart';

class MusicPage extends StatelessWidget {
  const MusicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildMusicPage();
  }

  BlocConsumer<MusicBloc, MusicState> _buildMusicPage() {
    return BlocConsumer<MusicBloc, MusicState>(
      listener: (context, MusicState state) {
        if (state is MusicLoadedState) {
          print(state.props[0]);
        }
      },
      builder: (context, MusicState state) {
        return Scaffold(
            appBar: AppBar(
              title: Text('Detalles de la canción'),
              actions: [
                IconButton(
                  onPressed: () {
                    BlocProvider.of<FavoritesBloc>(context)
                        .add(AddFavoriteEvent(musicInfo: state.musicInfo));
                  },
                  icon: _favorite(),
                ),
              ],
            ),
            body: Column(children: [
              Column(children: [
                Image(
                  image: NetworkImage(
                    state.musicInfo['artwork'],
                  ),
                  width: double.infinity,
                ),
                Text(
                  state.musicInfo['title'],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  state.musicInfo['artist'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  state.musicInfo['album'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  DateFormat('dd / MMMM / yyyy')
                      .format(DateTime.parse(state.musicInfo['release_date'])),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                Text(
                  "Abrir con:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        _launchInBrowser(Uri.parse(state.musicInfo['spotify']));
                      },
                      icon: FaIcon(
                        FontAwesomeIcons.spotify,
                        size: 32,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _launchInBrowser(
                            Uri.parse(state.musicInfo['song_link']));
                      },
                      icon: FaIcon(
                        FontAwesomeIcons.podcast,
                        size: 32,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _launchInBrowser(
                            Uri.parse(state.musicInfo['apple_music']));
                      },
                      icon: FaIcon(
                        FontAwesomeIcons.apple,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ])
            ]));
      },
    );
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  BlocConsumer<FavoritesBloc, FavoritesState> _favorite() {
    return BlocConsumer<FavoritesBloc, FavoritesState>(
      listener: (context, state) {
        if (state is FavoritesUpdatedState) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text("Canción añadida a favoritos"),
              ),
            );
        } else if (state is FavoritesErrorState) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
              ),
            );
        }
      },
      builder: (context, state) {
        if (state is FavoritesUpdatedState) {
          return Icon(Icons.favorite);
        } else {
          return Icon(Icons.favorite_border);
        }
      },
    );
  }
}
