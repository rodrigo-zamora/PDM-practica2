part of 'music_bloc.dart';

@immutable
abstract class MusicEvent {
  const MusicEvent();
}

class RecordMusicEvent extends MusicEvent {}