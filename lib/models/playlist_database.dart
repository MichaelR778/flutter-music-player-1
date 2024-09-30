import 'package:downloader/models/image_download.dart';
import 'package:downloader/models/playlist_provider.dart';
import 'package:downloader/models/song.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';

class PlaylistDatabase extends ChangeNotifier {
  late Isar isar;

  PlaylistDatabase({required this.isar});

  // list of playlists
  final List<Playlist> playlists = [];

  // list of songs
  int currPlaylistId = -1;
  final List<Song> _songs = [];
  List<Song> get songs => _songs;

  // Playlist database functionality
  // CREATE - create new playlist and save to database
  Future<void> createPlaylist({
    required String playlistName,
    required String imageUrl,
  }) async {
    Playlist newPlaylist = Playlist(playlistName: playlistName);

    // download image
    newPlaylist.imagePath = await downloadImage(imageUrl);

    // save song to db
    await isar.writeTxn(() => isar.playlists.put(newPlaylist));

    // update playlists list
    await fetchPlaylists();
  }

  // READ - fetch all playlists
  Future<void> fetchPlaylists() async {
    List<Playlist> fetchedPlaylists = await isar.playlists.where().findAll();
    playlists.clear();
    playlists.addAll(fetchedPlaylists);
    notifyListeners();
  }

  // DELETE - delete a playlist from db
  Future<void> deletePlaylist({
    required BuildContext context,
    required int id,
  }) async {
    // delete image
    final playlist = await isar.playlists.get(id);
    await deleteFile(playlist!.imagePath);

    // delete song from db
    await isar.writeTxn(() => isar.playlists.delete(id));

    // update playlists list
    await fetchPlaylists();
    // stop if currently playing
    Provider.of<PlaylistProvider>(context, listen: false).stop(id);
  }

  // fetch all songs in curr playlist
  // Future<void> fetchCurrPlaylistSongs(
  //   BuildContext context,
  //   Playlist playlist,
  // ) async {
  //   List<Song> fetchedSongs = await fetchPlaylistSongs(context, playlist);
  //   songs.clear();
  //   songs.addAll(fetchedSongs);
  //   notifyListeners();
  // }

  // Future<List<Song>> fetchPlaylistSongs(
  //   BuildContext context,
  //   Playlist playlist,
  // ) async {
  //   print(playlist.songIds);
  //   List<Song> songs = await Provider.of<SongDatabase>(context, listen: false)
  //       .fetchSongByIds(playlist.songIds);
  //   print(songs);
  //   return songs;
  // }

  // individual playlist functionality
  Future<void> addSongToPlaylist({
    required BuildContext context,
    required int playlistId,
    required Song song,
  }) async {
    // Fetch the playlist by its ID
    final playlist = await isar.playlists.get(playlistId);

    // Ensure the playlist exists
    if (playlist == null) {
      print("Playlist not found");
      return;
    }

    // Load the songs linked to the playlist
    // await playlist.songs.load();

    // Check if the song is already linked
    if (!playlist.songs.toList().contains(song)) {
      // If not, add the song to the playlist's links
      // playlist.songs.add(song);

      // Save the updated playlist
      await isar.writeTxn(() async {
        // await isar.playlists.put(playlist);
        playlist.songs.add(song);
        await playlist.songs.save();
      });
      print("Song added to the playlist successfully");

      // update playlist provider curr playlist if == this updated playlist
      List<Song> songs = playlist.songs.toList();
      Provider.of<PlaylistProvider>(context, listen: false)
          .updateAdd(songs, playlistId);

      // update playlists list
      await fetchPlaylists();
      _songs.clear();
      _songs.addAll(songs);
      notifyListeners();
    } else {
      print("Song is already in the playlist");
    }
  }

  // delete song from playlist
  Future<void> deleteSongFromPlaylist({
    required BuildContext context,
    required int playlistId,
    required Song song,
  }) async {
    // Fetch the playlist by its ID
    final playlist = await isar.playlists.get(playlistId);

    // Ensure the playlist exists
    if (playlist == null) {
      print("Playlist not found");
      return;
    }

    // Load the songs linked to the playlist
    // await playlist.songs.load();

    // Check if the song is linked to the playlist
    if (playlist.songs.toList().contains(song)) {
      // Remove the song from the playlist's links
      // playlist.songs.remove(song);

      // Save the updated playlist
      await isar.writeTxn(() async {
        // await isar.playlists.put(playlist);
        playlist.songs.remove(song);
        await playlist.songs.save();
      });
      print("Song removed from the playlist successfully");

      // skip if deleted song is currently playing
      int deletedIndex =
          await Provider.of<PlaylistProvider>(context, listen: false)
              .skipDelete(context, song.id);

      // update playlist provider curr playlist if == this updated playlist
      List<Song> songs = playlist.songs.toList();
      if (deletedIndex != -1) {
        Provider.of<PlaylistProvider>(context, listen: false)
            .updateDelete(deletedIndex, songs, playlistId);
      }

      // update playlists list
      await fetchPlaylists();
      _songs.clear();
      _songs.addAll(songs);
      notifyListeners();
    } else {
      print("Song is not in the playlist");
      print(playlist.songs);
    }
  }

  void cascadeDelete(BuildContext context, Song song) {
    for (var playlist in playlists) {
      if (playlist.songs.toList().contains(song)) {
        deleteSongFromPlaylist(
          context: context,
          playlistId: playlist.id,
          song: song,
        );
      }
    }
  }

  // get songs from playlist
  Future<void> getSongFromPlaylist(int playlistId) async {
    if (currPlaylistId == playlistId) {
      final playlist = await isar.playlists.get(playlistId);
      await playlist!.songs.load();
      List<Song> fetchedSongs = playlist.songs.toList();
      _songs.clear();
      _songs.addAll(fetchedSongs);
      notifyListeners();
    }
  }
}
