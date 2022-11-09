// ignore_for_file: prefer_const_constructors_in_immutables, prefer_typing_uninitialized_variables, must_be_immutable, override_on_non_overriding_member

part of 'favorites_bloc.dart';

@immutable
abstract class FavoritesEvent {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class AddFavoriteEvent extends FavoritesEvent {
  AddFavoriteEvent({required this.musicInfo});

  final dynamic musicInfo;

  @override
  List<Object?> get props => [musicInfo];
}

class FavoriteRemoveEvent extends FavoritesEvent {
  final dynamic musicInfo;

  FavoriteRemoveEvent({required this.musicInfo});

  @override
  List<Object?> get props => [musicInfo];
}

class FavoritesLoadEvent extends FavoritesEvent {
  FavoritesLoadEvent();
}
