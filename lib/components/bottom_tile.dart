import 'dart:io';

import 'package:downloader/models/playlist_provider.dart';
import 'package:downloader/pages/song_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomTile extends StatelessWidget {
  final double bottomMargin;
  const BottomTile({super.key, required this.bottomMargin});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, value, child) {
        if (value.currentSongIndex != null) {
          final currSong = value.playList[value.currentSongIndex!];
          return Card(
            margin: EdgeInsets.only(bottom: bottomMargin, left: 8, right: 8),
            color: Theme.of(context).colorScheme.secondary,
            child: ListTile(
              leading: Image.file(File(currSong.imagePath)),
              title: Text(currSong.songName),
              subtitle: Text(currSong.artistName),
              subtitleTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
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
    );
  }
}
