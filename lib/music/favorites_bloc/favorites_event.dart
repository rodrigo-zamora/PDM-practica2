part of 'favorites_bloc.dart';

@immutable
abstract class FavoritesEvent {
  const FavoritesEvent();

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
