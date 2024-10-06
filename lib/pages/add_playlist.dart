import 'package:downloader/models/playlist_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddPlaylist extends StatefulWidget {
  const AddPlaylist({super.key});

  @override
  State<AddPlaylist> createState() => _AddPlaylistState();
}

class _AddPlaylistState extends State<AddPlaylist> {
  @override
  Widget build(BuildContext context) {
    final formGlobalKey = GlobalKey<FormState>();
    String playlistName = '';
    String imageUrl = '';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('P L A Y L I S T'),
        centerTitle: true,
      ),
      body: Form(
        key: formGlobalKey,
        child: Container(
          padding: EdgeInsets.all(40),
          height: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // playlist name
              TextFormField(
                decoration: const InputDecoration(
                  label: Text('Playlist name'),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please input a Song name';
                  }
                  return null;
                },
                onSaved: (value) {
                  playlistName = value!;
                },
              ),

              // image url input
              TextFormField(
                decoration: const InputDecoration(
                  label: Text('Image url'),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please input an Image url';
                  }
                  return null;
                },
                onSaved: (value) {
                  imageUrl = value!;
                },
              ),

              // button
              FilledButton(
                onPressed: () async {
                  if (formGlobalKey.currentState!.validate()) {
                    formGlobalKey.currentState!.save();
                    Provider.of<PlaylistDatabase>(context, listen: false)
                        .createPlaylist(
                      context: context,
                      playlistName: playlistName,
                      imageUrl: imageUrl,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Create playlist'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
