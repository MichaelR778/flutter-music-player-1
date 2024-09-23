// import 'dart:io';

import 'package:downloader/components/my_drawer.dart';
import 'package:downloader/models/playlist_provider.dart';
import 'package:downloader/models/song.dart';
import 'package:downloader/models/song_database.dart';
import 'package:downloader/pages/add_song.dart';
import 'package:downloader/pages/song_page.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: const Text('H O M E'),
        centerTitle: true,
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

      drawer: const MyDrawer(),

      body: Consumer<SongDatabase>(builder: (context, songDatabase, child) {
        List<Song> songs = songDatabase.songs;
        return ListView.builder(
          itemCount: songs.length,
          itemBuilder: (context, index) {
            return Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.zero),
              ),
              shadowColor: Theme.of(context).colorScheme.inversePrimary,
              child: ListTile(
                // leading: songs[index].imagePath != null
                //     ? Image.file(File(songs[index]
                //         .imagePath!))
                //     : const Text("No image downloaded yet."),
                leading: Image.network(songs[index].imagePath!),
                title: Text(songs[index].songName),
                subtitle: Text(songs[index].artistName),
                onTap: () {
                  Provider.of<PlaylistProvider>(context, listen: false)
                      .updatePlaylist(songs);
                  Provider.of<PlaylistProvider>(context, listen: false)
                      .currentSongIndex = index;
                },
                trailing: PopupMenuButton(
                  color: Theme.of(context).colorScheme.secondary,
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Delete'),
                      onTap: () {
                        songDatabase.deleteSong(
                            context: context, id: songs[index].id);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),

      // bottom song tile
      floatingActionButton: Consumer<PlaylistProvider>(
        builder: (context, value, child) {
          if (value.currentSongIndex != null) {
            final currSong = value.playList[value.currentSongIndex!];
            return Card(
              color: Theme.of(context).colorScheme.secondary,
              child: ListTile(
                leading: Image.network(currSong.imagePath!),
                title: Text(currSong.songName),
                subtitle: Text(currSong.artistName),
                trailing: GestureDetector(
                  onTap: value.pauseOrResume,
                  child: Icon(value.isPlaying ? Icons.pause : Icons.play_arrow),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SongPage()),
                  );
                },
              ),
            );
          } else {
            return Container();
          }
        },
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
