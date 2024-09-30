import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:downloader/models/song.dart';
import 'package:flutter/material.dart';
// import 'package:image_downloader/image_downloader.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class OldSongDatabase extends ChangeNotifier {
  static late Isar isar;

  // init
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [SongSchema],
      directory: dir.path,
    );
  }

  // list of songs
  final List<Song> songs = [];

  // CREATE - save song to db
  Future<void> addSong({
    required String songName,
    required String artistName,
    required String youtubeUrl,
    required String imageUrl,
  }) async {
    Song newSong = Song(songName: songName, artistName: artistName);
    // download image
    // String? imageId = await downloadImage(imageUrl);
    // if (imageId == null) {
    //   print('image download failed');
    //   return;
    // }
    // newSong.imagePath = await ImageDownloader.findPath(imageId);
    newSong.imagePath = imageUrl;

    // download song
    newSong.audioPath = await downloadSong(youtubeUrl);

    // update song to db
    await isar.writeTxn(() => isar.songs.put(newSong));
    await fetchSongs();
  }

  // READ - fetch songs from db
  Future<void> fetchSongs() async {
    List<Song> fetchedSongs = await isar.songs.where().findAll();
    songs.clear();
    songs.addAll(fetchedSongs);
    notifyListeners();
  }

  // DELETE - delete a song from db
  Future<void> deleteSong(int id) async {
    final song = await isar.songs.get(id);
    await deleteAudio(song!.audioPath);
    await isar.writeTxn(() => isar.songs.delete(id));
    await fetchSongs();
  }

  // download image
  // Future<String?> downloadImage(String url) async {
  //   // note: use try catch (?)

  //   // Image URL
  //   var imageUrl = "https://yourimageurl.com/sample.jpg";

  //   // Download image
  //   var imageId = await ImageDownloader.downloadImage(imageUrl);

  //   return imageId;
  // }

  // download song
  Future<String> downloadSong(String url) async {
    var yt = YoutubeExplode();
    var videoId = VideoId(url);
    var manifest = await yt.videos.streamsClient.getManifest(videoId);
    var streamInfo = manifest.audioOnly.withHighestBitrate();

    // Get the actual stream
    var stream = yt.videos.streamsClient.get(streamInfo);

    // Open a file for writing.
    // final dir = await getApplicationDocumentsDirectory();
    final dir = await getExternalStorageDirectory();
    String timestamp = DateTime.now()
        .millisecondsSinceEpoch
        .toString(); // timestamp for unique filename
    String audioPath = '${dir!.path}/${videoId}_$timestamp.mp3';
    var file = File(audioPath);
    var fileStream = file.openWrite();

    // Pipe all the content of the stream into the file.
    await stream.pipe(fileStream);

    // Close the file.
    await fileStream.flush();
    await fileStream.close();

    // Dispose the YoutubeExplode object
    yt.close();
    return audioPath;
  }

  // delete local audio file
  Future<void> deleteAudio(String audioPath) async {
    try {
      // Create a file object with the given path
      var file = File(audioPath);

      // Check if the file exists before deleting it
      if (await file.exists()) {
        await file.delete();
        print('File deleted successfully: $audioPath');
      } else {
        print('File not found: $audioPath');
      }
    } catch (e) {
      print('Failed to delete the file: $e');
    }
  }

  // SONG MANAGER
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
  SongDatabase() {
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

  // dispose audio player

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
  Future<void> setPlaylist(List<Song> newPlaylist) async {
    _playlist.clear();
    _playlist.addAll(newPlaylist);
  }

  set currentSongIndex(int? newIndex) {
    // update index
    _currentSongIndex = newIndex;

    // play song
    play();

    // update UI
    notifyListeners();
  }
}
