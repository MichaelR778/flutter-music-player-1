import 'dart:io';

import 'package:downloader/models/song.dart';
import 'package:flutter/material.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final void Function()? play;
  final void Function()? delete;
  final String deleteText;

  const SongTile({
    super.key,
    required this.song,
    required this.play,
    required this.delete,
    required this.deleteText,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: play,
      // splashColor: Theme.of(context).colorScheme.secondary,
      child: Row(
        children: [
          Expanded(
            child: ListTile(
              leading: Image.file(File(song.imagePath)),
              title: Text(song.songName),
              subtitle: Text(song.artistName),
              subtitleTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          PopupMenuButton(
            color: Theme.of(context).colorScheme.secondary,
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).colorScheme.primary,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: delete,
                child: Text(deleteText),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
