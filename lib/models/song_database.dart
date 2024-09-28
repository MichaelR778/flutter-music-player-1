import 'dart:io';

import 'package:dio/dio.dart';
import 'package:downloader/models/playlist_provider.dart';
import 'package:downloader/models/song.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SongDatabase extends ChangeNotifier {
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
    required BuildContext context,
    required String songName,
    required String artistName,
    required String youtubeUrl,
    required String imageUrl,
  }) async {
    Song newSong = Song(songName: songName, artistName: artistName);

    // download album art image
    newSong.imagePath = await downloadImage(imageUrl);

    // download song
    newSong.audioPath = await downloadSong(youtubeUrl);

    // save song to db
    await isar.writeTxn(() => isar.songs.put(newSong));

    // update current playlist if curr playlist == this playlist
    await fetchSongs();
    Provider.of<PlaylistProvider>(context, listen: false).updateAdd(songs);
  }

  // READ - fetch songs from db
  Future<void> fetchSongs() async {
    List<Song> fetchedSongs = await isar.songs.where().findAll();
    songs.clear();
    songs.addAll(fetchedSongs);
    notifyListeners();
  }

  // DELETE - delete a song from db
  Future<void> deleteSong({
    required BuildContext context,
    required int id,
  }) async {
    // skip if deleted song is currently playing
    int deletedIndex =
        Provider.of<PlaylistProvider>(context, listen: false).skipDelete(id);

    // get song
    final song = await isar.songs.get(id);

    // delete image file and audio file
    await deleteFiles(song!.imagePath, song.audioPath);

    // delete song from db
    await isar.writeTxn(() => isar.songs.delete(id));

    // update curr playlist if curr playlist == this playlist
    await fetchSongs();
    Provider.of<PlaylistProvider>(context, listen: false)
        .updateDelete(deletedIndex, songs);
  }

  // download song
  Future<String> downloadSong(String url) async {
    var yt = YoutubeExplode();
    var videoId = VideoId(url);
    var manifest = await yt.videos.streamsClient.getManifest(videoId);
    var streamInfo = manifest.audioOnly.withHighestBitrate();

    // Get the actual stream
    var stream = yt.videos.streamsClient.get(streamInfo);

    // Open a file for writing.
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

  // download album art image
  Future<String> downloadImage(String url) async {
    try {
      final dir = await getExternalStorageDirectory();
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String imagePath = '${dir!.path}/image_$timestamp.jpg';

      Dio dio = Dio();
      await dio.download(url, imagePath);
      print('Download succeed, image path: $imagePath');
      return imagePath;
    } catch (e) {
      print('error: $e');
      // default image if error while download
      // double check for UI to display assetimage instaed if download failed
      return '';
    }
  }

  // delete local image and audio file
  Future<void> deleteFiles(String imagePath, String audioPath) async {
    try {
      // Create a file object with the given path
      var imageFile = File(imagePath);

      // Check if the file exists before deleting it
      if (await imageFile.exists()) {
        await imageFile.delete();
        print('File deleted successfully: $imagePath');
      } else {
        print('File not found: $imagePath');
      }

      // Create a file object with the given path
      var audioFile = File(audioPath);

      // Check if the file exists before deleting it
      if (await audioFile.exists()) {
        await audioFile.delete();
        print('File deleted successfully: $audioPath');
      } else {
        print('File not found: $audioPath');
      }
    } catch (e) {
      print('Failed to delete the file: $e');
    }
  }
}
