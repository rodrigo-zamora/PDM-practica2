// ignore_for_file: prefer_const_constructors_in_immutables

part of 'favorites_bloc.dart';

@immutable
abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];

  get favorites => null;
}

class FavoritesInitial extends FavoritesState {}

class FavoritesErrorState extends FavoritesState {
  final String errorMessage;

  FavoritesErrorState({required this.errorMessage});
}

class FavoritesUpdatedState extends FavoritesState {
  @override
  final List<dynamic> favorites;

  FavoritesUpdatedState({required this.favorites});

  @override
  List<Object?> get props => [favorites];
}

class FavoritesLoadingState extends FavoritesState {
  FavoritesLoadingState();
}

class FavoritesLoadedState extends FavoritesState {
  @override
  final List<dynamic> favorites;

  FavoritesLoadedState({required this.favorites});

  @override
  List<Object?> get props => [favorites];
}

class FavoritesRemovingState extends FavoritesState {
  FavoritesRemovingState();
}

class FavoritesRemovedState extends FavoritesState {
  FavoritesRemovedState();
}
