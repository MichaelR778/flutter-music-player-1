import 'package:audioplayers/audioplayers.dart';
import 'package:downloader/models/song.dart';
import 'package:flutter/material.dart';

class PlaylistProvider extends ChangeNotifier {
  // current playlist
  final List<Song> _playlist = [];

  // current playing song index
  int? _currentSongIndex;

  /*

  AUDIO PLAYER

  */

  // audio player
  final AudioPlayer _audioPlayer = AudioPlayer();

  // durations
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // constructor
  PlaylistProvider() {
    listenToDuration();
  }

  // initially not playing
  bool _isPlaying = false;

  // play the song
  void play() async {
    final String path = _playlist[currentSongIndex!].audioPath;
    await _audioPlayer.stop(); // stop any song if currently playing
    await _audioPlayer.play(DeviceFileSource(path)); // play new song
    _isPlaying = true;
    notifyListeners();
  }

  // pause curr song
  void pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  // resume playing
  void resume() async {
    await _audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  // pause or resume
  void pauseOrResume() async {
    if (_isPlaying) {
      pause();
    } else {
      resume();
    }
  }

  // seek to a spesific position in curr song
  void seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // play next song
  void playNextSong() {
    currentSongIndex = (_currentSongIndex! + 1) % _playlist.length;
  }

  // play prev song
  void playPreviousSong() async {
    // if not in the beginning of curr song, go back to beginning
    if (_currentDuration.inSeconds > 2) {
      seek(Duration.zero);
    } else {
      currentSongIndex = (_currentSongIndex! - 1) % _playlist.length;
    }
  }

  // listen to duration
  void listenToDuration() {
    // listen to total duration
    _audioPlayer.onDurationChanged.listen((newDuration) {
      _totalDuration = newDuration;
      notifyListeners();
    });

    // listen to curr duration
    _audioPlayer.onPositionChanged.listen((newPosition) {
      _currentDuration = newPosition;
      notifyListeners();
    });

    // listen for song completion
    _audioPlayer.onPlayerComplete.listen((event) {
      playNextSong();
    });
  }

  // update playlist
  void updatePlaylist(List<Song> newPlaylist) {
    _playlist.clear();
    _playlist.addAll(newPlaylist);
  }

  // update playlist if new song is added to curr playlist
  void updateAdd(List<Song> newPlaylist) {
    updatePlaylist(newPlaylist);
  }

  // skip song if the song to be deleted is currently playing
  int skipDelete(int id) {
    int deletedIndex = _playlist.indexWhere((song) => song.id == id);
    // play next song if deleted song is currently playing
    if (deletedIndex == currentSongIndex) {
      playNextSong();
    }
    return deletedIndex;
  }

  // update playlist when song to be deleted is in curr playlist
  void updateDelete(int deletedIndex, List<Song> newPlaylist) {
    // update playlist and update index if needed
    updatePlaylist(newPlaylist);
    if (deletedIndex < currentSongIndex!) {
      _currentSongIndex = (_currentSongIndex! - 1) % _playlist.length;
    }
  }

  /*

  GETTERS

  */

  List<Song> get playList => _playlist;
  int? get currentSongIndex => _currentSongIndex;
  bool get isPlaying => _isPlaying;
  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;

  /*

  SETTERS

  */

  set currentSongIndex(int? newIndex) {
    // update index
    _currentSongIndex = newIndex;

    // play song
    play();

    // update UI
    notifyListeners();
  }
}
