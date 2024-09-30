import 'package:downloader/components/bottom_tile.dart';
import 'package:downloader/components/playlist_tile.dart';
import 'package:downloader/models/playlist_database.dart';
import 'package:downloader/models/song.dart';
import 'package:downloader/pages/add_playlist.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<PlaylistDatabase>(context, listen: false).fetchPlaylists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'P L A Y L I S T S',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddPlaylist(),
                ),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<PlaylistDatabase>(
          builder: (context, playlistDatabase, child) {
        List<Playlist> playlists = playlistDatabase.playlists;
        return ListView(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2),
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                return PlaylistTile(playlistId: playlists[index].id);
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
