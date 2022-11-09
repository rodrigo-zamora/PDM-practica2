// ignore_for_file: depend_on_referenced_packages, no_leading_underscores_for_local_identifiers, unused_local_variable, body_might_complete_normally_nullable, avoid_print, unnecessary_null_comparison, prefer_const_constructors, unnecessary_new

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

part 'music_event.dart';
part 'music_state.dart';

class MusicBloc extends Bloc<MusicEvent, MusicState> {
  MusicBloc() : super(MusicInitial()) {
    on<RecordMusicEvent>(_onMusicRecord);
  }

  final _musicEndpoint = "https://api.audd.io/";

  void _onMusicRecord(MusicEvent event, Emitter emit) async {
    print("Start recording");

    Directory root = await getTemporaryDirectory();
    String _path = "${root.path}/music.m4a";
    print("\tPath: $_path");

    int _recordDuration = 6;
    int _current = 0;
    Timer? _timer;
    print("\tRecord duration: $_recordDuration");

    try {
      Record _audioRecorder = Record();
      bool _hasPermission = await _audioRecorder.hasPermission();
      print("\tChecking for permission...");
      print("\t\tHas permission: $_hasPermission");

      if (!_hasPermission) {
        emit(MusicErrorState(
            errorMessage: "Necesitas dar el permiso para grabar"));
        return;
      }

      print("\tStarting recording...");
      emit(MusicLoadingState(message: "Escuchando.."));

      await _audioRecorder.start(
        path: _path,
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        samplingRate: 44100,
      );

      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        _current++;
        print("\t\tTime recorded: $_current");
        if (_current >= _recordDuration) {
          _timer?.cancel();
          _timer = null;
          _current = 0;
          print("\t\tTimer cancelled");
        }
      });

      await Future.delayed(Duration(seconds: _recordDuration));
      print("\tStopping recording...");

      final path = await _audioRecorder.stop();
      _timer?.cancel();

      print("\tRecording stopped");
      print("Recording finished");

      emit(MusicGettingInfoState(message: "Buscando.."));

      print("Getting music info...");
      // Get music info and return it
      await dotenv.load(fileName: ".env");
      print("\tGetting token...");

      print("\t\tToken: ${dotenv.env['API_TOKEN']}");
      print("\tGetting file from path $path");

      print("Sending request...");
      emit(MusicGettingInfoState(message: "Buscando.."));
      try {
        
        final uri = Uri.parse(_musicEndpoint);
        var request = new http.MultipartRequest('POST', uri);
        final httpFile = http.MultipartFile.fromBytes(
          'file',
          File(path!).readAsBytesSync(),
          filename: 'music.m4a',
        );
        request.files.add(httpFile);
        request.fields['api_token'] = dotenv.env['API_TOKEN']!;
        request.fields['return'] = 'apple_music,spotify';
        request.fields['method'] = 'recognize';
        final response = await request.send();

        final responseString = await response.stream.bytesToString();
        final res = jsonDecode(responseString);
        print(res);
        if (res['status'] == 'success') {
          if (res['result'] != null) {
            var _musicInfo = res['result'];
            var _title = _musicInfo['title'];
            var _artist = _musicInfo['artist'];
            var _releaseDate = _musicInfo['release_date'];

            var _appleMusic = _musicInfo['apple_music'];
            var _spotify = _musicInfo['spotify'];

            var _album = _spotify['album']['name'];
            var _image = _spotify['album']['images'][1]['url'];
            var _songLink = _musicInfo['song_link'];

            emit(MusicLoadedState(musicInfo: {
              'title': _title,
              'artist': _artist,
              'album': _album,
              'apple_music': _appleMusic['url'],
              'spotify': _spotify['external_urls']['spotify'],
              'artwork': _image,
              'song_link': _songLink,
              'release_date': _releaseDate,
            }));
          } else {
            emit(MusicErrorState(errorMessage: "No se encontró la canción"));
          }
        } else {
          emit(MusicErrorState(
              errorMessage: "No se pudo obtener la información"));
        }
      } catch (e) {
        print(e.toString());
        emit(MusicErrorState(errorMessage: e.toString()));
      }
    } catch (e) {
      print("\t\tError: $e");
      emit(MusicErrorState(errorMessage: e.toString()));
    }
  }
}
