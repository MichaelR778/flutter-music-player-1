// import 'dart:io';
import 'package:downloader/components/bottom_tile.dart';
import 'package:downloader/components/song_tile.dart';
import 'package:downloader/models/playlist_provider.dart';
import 'package:downloader/models/song.dart';
import 'package:downloader/models/song_database.dart';
import 'package:downloader/pages/add_song.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    Provider.of<SongDatabase>(context, listen: false).fetchSongs();
    super.initState();
  }

  void play(List<Song> songs, int index) {
    final playlistProvider =
        Provider.of<PlaylistProvider>(context, listen: false);
    playlistProvider.updatePlaylist(songs);
    playlistProvider.currentSongIndex = index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'H O M E',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: ((context) => const AddSong()),
              ),
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<SongDatabase>(builder: (context, songDatabase, child) {
        List<Song> songs = songDatabase.songs;
        return ListView(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: songs.length,
              itemBuilder: (context, index) {
                return SongTile(
                  song: songs[index],
                  play: () => play(songs, index),
                  delete: () {
                    songDatabase.deleteSong(
                        context: context, id: songs[index].id);
                  },
                  deleteText: 'delete',
                );
              },
            ),
            const SizedBox(height: 125),
          ],
        );
      }),
      floatingActionButton: BottomTile(bottomMargin: 58),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
