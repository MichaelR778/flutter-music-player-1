import 'dart:io';
import 'package:downloader/models/image_download.dart';
import 'package:downloader/models/playlist_database.dart';
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
      [SongSchema, PlaylistSchema],
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
    Provider.of<PlaylistProvider>(context, listen: false).updateAdd(songs, -1);
  }

  // READ - fetch songs from db
  Future<void> fetchSongs() async {
    List<Song> fetchedSongs = await isar.songs.where().findAll();
    songs.clear();
    songs.addAll(fetchedSongs);
    notifyListeners();
  }

  // fetch song by id
  Future<Song?> fetchSongById(int id) async {
    final Song? song = await isar.songs.get(id);
    return song;
  }

  // fetch song by ids
  // Future<List<Song>> fetchSongByIds(List<int> songIds) async {
  //   if (songIds.isEmpty) {
  //     return [];
  //   }
  //   List<Song> fetchedSongs = await isar.songs
  //       .filter()
  //       .anyOf(songIds, (q, int id) => q.idEqualTo(id))
  //       .findAll();
  //   return fetchedSongs;
  // }

  // DELETE - delete a song from db
  Future<void> deleteSong({
    required BuildContext context,
    required int id,
  }) async {
    // skip if deleted song is currently playing
    int deletedIndex =
        await Provider.of<PlaylistProvider>(context, listen: false)
            .skipDelete(context, id);

    // get song
    final song = await isar.songs.get(id);

    // delete image file and audio file
    await deleteFile(song!.imagePath);
    await deleteFile(song.audioPath);

    // delete song from db
    await isar.writeTxn(() => isar.songs.delete(id));

    // cascade delete song in playlists
    Provider.of<PlaylistDatabase>(context, listen: false)
        .cascadeDelete(context, song);

    // update curr playlist if curr playlist == this playlist
    await fetchSongs();
    if (deletedIndex != -1) {
      Provider.of<PlaylistProvider>(context, listen: false)
          .updateDelete(deletedIndex, songs, -1);
    }
  }

  // download song
  // TODO: try catch, return default path (?)
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
}
