// ignore_for_file: avoid_print, no_leading_underscores_for_local_identifiers, unused_element, prefer_const_constructors, unused_local_variable, unnecessary_import, prefer_const_literals_to_create_immutables, sort_child_properties_last, depend_on_referenced_packages, must_be_immutable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:music_app/music/favorites_bloc/favorites_bloc.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis favoritos'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _favoritesPage(),
          ),
        ],
      ),
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

  BlocConsumer<FavoritesBloc, FavoritesState> _favoritesPage() {
    return BlocConsumer<FavoritesBloc, FavoritesState>(
      listener: (context, state) {
        if (state is FavoritesRemovingState) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text('Eliminando de favoritos')),
            );
        } else if (state is FavoritesRemovedState) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text('Eliminado de favoritos')),
            );
        } else if (state is FavoritesErrorState) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text('Error al eliminar de favoritos')),
            );
        } else if (state is FavoritesInitial) {
          BlocProvider.of<FavoritesBloc>(context).add(FavoritesLoadEvent());
        }
      },
      builder: (context, state) {
        print("--------------------\nState: $state\n---------------------");
        if (state is FavoritesInitial) {
          BlocProvider.of<FavoritesBloc>(context).add(FavoritesLoadEvent());
        }
        if (state is FavoritesLoadedState || state is FavoritesUpdatedState) {
          return ListView.builder(
              itemCount: state.favorites.length,
              itemBuilder: (BuildContext ctxt, int index) {
                return Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Column(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                child: GestureDetector(
                                  onTap: () {
                                    _launchInBrowser(Uri.parse(
                                        (state.favorites[index]['song_link'])));
                                  },
                                  child: Image(
                                    image: NetworkImage(
                                      state.favorites[index]['artwork'],
                                    ),
                                    width: 250,
                                  ),
                                ),
                              )
                            ],
                          ),
                          Container(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: 400,
                              height: 65,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(148, 33, 92, 255),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    state.favorites[index]['title'],
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    state.favorites[index]['artist'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: ((context) {
                                      return AlertDialog(
                                        title: Text(
                                            '¿Estás seguro de eliminar este favorito?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              BlocProvider.of<FavoritesBloc>(
                                                      context)
                                                  .add(FavoriteRemoveEvent(
                                                      musicInfo: state
                                                          .favorites[index]));
                                              Navigator.pop(context);
                                            },
                                            child: Text('Eliminar'),
                                          ),
                                        ],
                                      );
                                    }));
                              },
                              icon: Icon(Icons.favorite),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              });
        } else if (state is FavoritesLoadingState) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.purpleAccent,
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
