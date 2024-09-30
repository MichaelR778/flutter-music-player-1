import 'dart:io';

import 'package:downloader/models/playlist_database.dart';
import 'package:downloader/models/song.dart';
import 'package:downloader/models/song_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistAddsong extends StatelessWidget {
  final int playlistId;

  const PlaylistAddsong({
    super.key,
    required this.playlistId,
  });

  @override
  Widget build(BuildContext context) {
    final playlistDatabase = context.watch<PlaylistDatabase>();
    final Playlist playlist = playlistDatabase.playlists
        .firstWhere((playlist) => playlist.id == playlistId);
    final List<Song> playlistSongs = playlistDatabase.songs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('S O N G'),
        centerTitle: true,
      ),
      body: Consumer<PlaylistDatabase>(
          builder: (context, playlistDatabase, child) {
        List<Song> songs = Provider.of<SongDatabase>(context)
            .songs
            .where((song) => !playlistSongs.contains(song))
            .toList();
        return ListView.builder(
          itemCount: songs.length,
          itemBuilder: (context, index) {
            Song song = songs[index];
            return ListTile(
              leading: Image.file(File(song.imagePath)),
              title: Text(song.songName),
              subtitle: Text(song.artistName),
              subtitleTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
              trailing: IconButton(
                onPressed: () {
                  playlistDatabase.addSongToPlaylist(
                    context: context,
                    playlistId: playlist.id,
                    song: song,
                  );
                },
                icon: const Icon(Icons.add),
              ),
            );
          },
        );
      }),
    );
  }
}
