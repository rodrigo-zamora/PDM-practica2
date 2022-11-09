// ignore_for_file: depend_on_referenced_packages, avoid_print, no_leading_underscores_for_local_identifiers, unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc() : super(FavoritesInitial()) {
    on<AddFavoriteEvent>(_onFavoriteAdd);
    on<FavoriteRemoveEvent>(_onFavoriteRemove);
    on<FavoritesLoadEvent>(_onFavoritesLoad);
  }

  _onFavoriteAdd(FavoritesEvent event, emit) async {
    print("Adding music to favorites");
    print("------------------------");

    var _music = event.props[0];
    print("\tMusic to add: $_music");

    print("\tGetting favorites from local storage");
    Directory root = await getTemporaryDirectory();
    String _path = "${root.path}/favorites.json";
    print("\t\tPath: $_path");

    print("\tChecking if file exists");
    File _file = File(_path);
    bool _exists = await _file.exists();
    print("\t\tExists: $_exists");

    if (!_exists) {
      print("\t\tCreating file...");
      await _file.create();
      await _file.writeAsString(jsonEncode([]));
    }

    print("\tChecking if file is empty");
    String _content = await _file.readAsString();

    if (_content.isEmpty) {
      print("\t\tWriting empty JSON object to file...");
      await _file.writeAsString(jsonEncode([]), flush: true);
    }

    /*
      Check if the music is already in the favorites list
     */
    print("\tChecking if music is already in favorites");
    List<dynamic> _favorites = jsonDecode(_content);
    print(_favorites.runtimeType);
    _music = Map<String, dynamic>.from(_music as Map<String, dynamic>);
    print(_music.runtimeType);
    print("\n\n");
    print("\n\n");
    print("Favorites: $_favorites\n");
    print("Music: $_music\n\n");

    bool _isInFavorites = false;
    for (var _favorite in _favorites) {
      if (_favorite == _music) {
        print("\t\tMusic is already in favorites");
        _isInFavorites = true;
      }
    }
    print("\t\tIs already in favorites: $_isInFavorites");

    if (!_isInFavorites) {
      try {
        print("\tAdding new song to favorites");
        _favorites.add(_music);
        print("\t\tFavorites: ${_favorites.length}");

        print("\tSaving favorites");
        await _file.writeAsString(jsonEncode(_favorites));
        print("\t\tSaved");

        emit(FavoritesUpdatedState(favorites: _favorites));
      } catch (e) {
        print("\t\tError: $e");
        emit(FavoritesErrorState(errorMessage: "Error al guardar favoritos"));
      }
    } else {
      print("\t\tMusic is already in favorites");
      emit(
          FavoritesErrorState(errorMessage: "La canción ya está en favoritos"));
    }
  }

  _onFavoriteRemove(
      FavoriteRemoveEvent event, Emitter<FavoritesState> emit) async {
    print("Removing music from favorites");
    print("-----------------------------");

    emit(FavoritesRemovingState());

    print("\tSong to remove: ${event.musicInfo['title']}");

    print("\tGetting favorites from local storage");
    Directory root = await getTemporaryDirectory();
    String _path = "${root.path}/favorites.json";
    print("\t\tPath: $_path");

    try {
      List<dynamic> _favorites = jsonDecode(await File(_path).readAsString());
      print("\t\tFavorites: ${_favorites.length}");

      print("\tRemoving song from favorites");
      _favorites.removeWhere(
          (element) => element['title'] == event.musicInfo['title']);
      print("\t\tFavorites: ${_favorites.length}");

      print("\tSaving favorites");
      await File(_path).writeAsString(jsonEncode(_favorites));
      print("\t\tSaved");

      emit(FavoritesRemovedState());
      emit(FavoritesUpdatedState(favorites: _favorites));
    } catch (e) {
      print("\t\tError: $e");
      emit(FavoritesErrorState(errorMessage: "Error al eliminar favoritos"));
    }
  }

  _onFavoritesLoad(
      FavoritesLoadEvent event, Emitter<FavoritesState> emit) async {
    print("Loading favorites");
    print("-----------------");

    emit(FavoritesLoadingState());

    print("\tGetting favorites from local storage");
    Directory root = await getTemporaryDirectory();
    String _path = "${root.path}/favorites.json";
    print("\t\tPath: $_path");

    print("\tChecking if file exists");
    File _file = File(_path);
    bool _exists = await _file.exists();
    print("\t\tExists: $_exists");

    if (!_exists) {
      print("\t\tCreating file...");
      await _file.create();
      await _file.writeAsString(jsonEncode([]));
    }

    print("\tChecking if file is empty");
    String _content = await _file.readAsString();

    if (_content.isEmpty) {
      print("\t\tWriting empty JSON object to file...");
      await _file.writeAsString(jsonEncode([]), flush: true);
    }

    List<dynamic> _favorites = jsonDecode(_content);
    print("\t\tFavorites: ${_favorites.length}");

    emit(FavoritesLoadedState(favorites: _favorites));
  }
}
