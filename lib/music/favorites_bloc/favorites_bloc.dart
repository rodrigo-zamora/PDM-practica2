import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';

import '../../repositories/auth/user_auth_repository.dart';

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

    Map _music = event.props[0] as Map;
    print("\tMusic to add: $_music");

    print("\tGetting favorites from Firestore");
    String useruid = UserAuthRepository.userInstance?.currentUser?.uid ?? "";
    if (useruid == "") {
      print("\t\tUser not authenticated");
      return;
    }

    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: useruid)
        .get();

    final List<DocumentSnapshot> documents = result.docs;

    if (documents.length == 0) {
      print("\t\tUser not found");
      emit(FavoritesErrorState(errorMessage: "Usuario no encontrado"));
      return;
    } else {
      print("\t\tUser found with ${documents[0]['liked'].length} favorites");

      List<dynamic> favorites = documents[0]['liked'];

      // Check if the music is already in the favorites
      print("\tChecking if music is already in favorites");
      bool alreadyInFavorites = false;

      for (var favorite in favorites) {
        if (mapEquals(favorite, _music)) {
          alreadyInFavorites = true;
          break;
        }
      }
      print("\t\tMusic is already in favorites: $alreadyInFavorites");

      if (!alreadyInFavorites) {
        print("\tAdding music to favorites");
        favorites.add(_music);
        print("\t\tFavorites: $favorites");
        print("\t\tUpdating Firestore");
        await FirebaseFirestore.instance
            .collection('users')
            .doc(useruid)
            .update({'liked': favorites});
        print("\t\tFirestore updated");
      } else {
        print("\tMusic already in favorites");
      }

      emit(FavoritesUpdatedState(favorites: favorites));
    }
  }

  _onFavoriteRemove(
      FavoriteRemoveEvent event, Emitter<FavoritesState> emit) async {
    print("Removing music from favorites");
    print("-----------------------------");

    emit(FavoritesRemovingState());

    Map _music = event.props[0] as Map;
    print("\tSong to remove: $_music");

    print("\tGetting favorites from Firestore");
    String useruid = UserAuthRepository.userInstance?.currentUser?.uid ?? "";
    if (useruid == "") {
      print("\t\tUser not authenticated");
      return;
    }

    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: useruid)
        .get();

    final List<DocumentSnapshot> documents = result.docs;

    if (documents.length == 0) {
      print("\t\tUser not found");
      emit(FavoritesErrorState(errorMessage: "Usuario no encontrado"));
      return;
    } else {
      print("\t\tUser found with ${documents[0]['liked'].length} favorites");

      List<dynamic> favorites = documents[0]['liked'];

      // Check if the music is already in the favorites
      print("\tChecking if music is already in favorites");
      bool alreadyInFavorites = false;

      for (var favorite in favorites) {
        if (mapEquals(favorite, _music)) {
          alreadyInFavorites = true;
          break;
        }
      }
      print("\t\tMusic is already in favorites: $alreadyInFavorites");

      if (alreadyInFavorites) {
        print("\tRemoving music from favorites");
        favorites.removeWhere((element) => mapEquals(element, _music));
        print("\t\tFavorites: $favorites");
        print("\t\tUpdating Firestore");
        await FirebaseFirestore.instance
            .collection('users')
            .doc(useruid)
            .update({'liked': favorites});
        print("\t\tFirestore updated");
      } else {
        print("\tMusic not in favorites");
      }

      emit(FavoritesUpdatedState(favorites: favorites));
    }
  }

  _onFavoritesLoad(
      FavoritesLoadEvent event, Emitter<FavoritesState> emit) async {
    print("Loading favorites");
    print("-----------------");

    emit(FavoritesLoadingState());

    print("\tGetting favorites from Firestore");
    String useruid = UserAuthRepository.userInstance?.currentUser?.uid ?? "";
    if (useruid == "") {
      print("\t\tUser not authenticated");
      return;
    }

    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: useruid)
        .get();

    final List<DocumentSnapshot> documents = result.docs;

    if (documents.length == 0) {
      print("\t\tUser not found");
      emit(FavoritesErrorState(errorMessage: "Usuario no encontrado"));
      return;
    } else {
      List<dynamic> favorites = documents[0]['liked'];
      print("\t\tUser found with ${favorites.length} favorites");
      emit(FavoritesUpdatedState(favorites: favorites));
    }
  }
}
