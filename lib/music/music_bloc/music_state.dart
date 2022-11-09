// ignore_for_file: prefer_const_constructors_in_immutables, must_be_immutable

part of 'music_bloc.dart';

@immutable
abstract class MusicState extends Equatable {
  const MusicState();

  @override
  List<Object?> get props => [];

  get musicInfo => null;
  get favorites => null;

  get isFavorite => null;
}

class MusicInitial extends MusicState {}

class MusicErrorState extends MusicState {
  final String errorMessage;

  MusicErrorState({required this.errorMessage});
}

class MusicLoadingState extends MusicState {
  final String message;

  MusicLoadingState({required this.message});
}

class MusicLoadedState extends MusicState {
  @override
  final Map<String, dynamic> musicInfo;

  MusicLoadedState({required this.musicInfo});

  @override
  List<Object?> get props => [musicInfo];
}

class MusicGettingInfoState extends MusicState {
  final String message;

  MusicGettingInfoState({required this.message});
}
