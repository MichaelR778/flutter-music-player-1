import 'dart:io';

import 'package:downloader/components/bottom_tile.dart';
import 'package:downloader/components/song_tile.dart';
import 'package:downloader/models/playlist_database.dart';
import 'package:downloader/models/playlist_provider.dart';
import 'package:downloader/models/song.dart';
import 'package:downloader/pages/playlist_addsong.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistPage extends StatefulWidget {
  final int playlistId;

  const PlaylistPage({super.key, required this.playlistId});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  void play(int playlistId, List<Song> songs, int index) {
    final playlistProvider =
        Provider.of<PlaylistProvider>(context, listen: false);
    playlistProvider.updatePlaylist(songs, playlistId);
    playlistProvider.currentSongIndex = index;
  }

  @override
  void initState() {
    super.initState();
    Provider.of<PlaylistDatabase>(context, listen: false)
        .getSongFromPlaylist(widget.playlistId);
  }

  @override
  Widget build(BuildContext context) {
    final playlistDatabase = context.watch<PlaylistDatabase>();
    final Playlist playlist = playlistDatabase.playlists
        .firstWhere((playlist) => playlist.id == widget.playlistId);
    final List<Song> songs = playlistDatabase.songs;

    return Stack(
      children: [
        Scaffold(
          body: SafeArea(
            child: ListView(
              children: [
                // playlist image
                const SizedBox(height: 75),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Image.file(File(playlist.imagePath)),
                ),

                // playlist details
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playlist.playlistName,
                        style: TextStyle(fontSize: 28),
                      ),
                      Text(
                        '${songs.length} songs',
                        style: TextStyle(
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.favorite_outline),
                          const SizedBox(width: 18),
                          PopupMenuButton(
                            color: Theme.of(context).colorScheme.secondary,
                            icon: Icon(
                              Icons.more_vert,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PlaylistAddsong(
                                          playlistId: playlist.id),
                                    ),
                                  );
                                },
                                child: const Text('Add song to playlist'),
                              ),
                              PopupMenuItem(
                                onTap: () {
                                  Navigator.pop(context);
                                  Provider.of<PlaylistDatabase>(context,
                                          listen: false)
                                      .deletePlaylist(
                                    context: context,
                                    id: playlist.id,
                                  );
                                },
                                child: const Text('Delete playlist'),
                              ),
                            ],
                          ),
                          Expanded(child: Container()),
                          IconButton.filled(
                            onPressed: () {
                              if (!songs.isEmpty) {
                                play(playlist.id, songs, 0);
                              }
                            },
                            icon: const Icon(Icons.play_arrow),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    return SongTile(
                      song: songs[index],
                      play: () => play(playlist.id, songs, index),
                      delete: () {
                        Provider.of<PlaylistDatabase>(context, listen: false)
                            .deleteSongFromPlaylist(
                          context: context,
                          playlistId: playlist.id,
                          song: songs[index],
                        );
                      },
                      deleteText: 'Delete from playlist',
                    );
                  },
                ),

                const SizedBox(height: 75),
              ],
            ),
          ),
          floatingActionButton: BottomTile(bottomMargin: 7),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        ),

        // back button
        SafeArea(
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
      ],
    );
  }
}
