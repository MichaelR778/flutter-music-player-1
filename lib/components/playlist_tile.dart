import 'dart:io';

import 'package:downloader/models/playlist_database.dart';
import 'package:downloader/models/song.dart';
import 'package:downloader/pages/playlist_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistTile extends StatelessWidget {
  final int playlistId;

  const PlaylistTile({
    super.key,
    required this.playlistId,
  });

  @override
  Widget build(BuildContext context) {
    Playlist playlist;
    try {
      playlist = context
          .watch<PlaylistDatabase>()
          .playlists
          .firstWhere((playlist) => playlist.id == playlistId);
    } catch (e) {
      return Container();
    }

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Provider.of<PlaylistDatabase>(context, listen: false)
                .currPlaylistId = playlistId;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaylistPage(playlistId: playlistId),
              ),
            );
          },
          child: SizedBox(
            width: 150,
            height: 150,
            child: Image.file(File(playlist.imagePath)),
          ),
        ),
        Text(playlist.playlistName),
      ],
    );
  }
}
