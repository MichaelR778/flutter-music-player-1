import 'package:downloader/models/song_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddSong extends StatefulWidget {
  const AddSong({super.key});

  @override
  State<AddSong> createState() => _AddSongState();
}

class _AddSongState extends State<AddSong> {
  @override
  Widget build(BuildContext context) {
    final formGlobalKey = GlobalKey<FormState>();
    String songName = '';
    String artistName = '';
    String youtubeUrl = '';
    String imageUrl = '';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('S O N G'),
        centerTitle: true,
      ),
      body: Form(
        key: formGlobalKey,
        child: Container(
          padding: EdgeInsets.all(40),
          height: 450,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // song name
              TextFormField(
                decoration: const InputDecoration(
                  label: Text('Song name'),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please input a Song name';
                  }
                  return null;
                },
                onSaved: (value) {
                  songName = value!;
                },
              ),

              // artist name
              TextFormField(
                decoration: const InputDecoration(
                  label: Text('Artist name'),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please input an Artist name';
                  }
                  return null;
                },
                onSaved: (value) {
                  artistName = value!;
                },
              ),

              // youtube url input
              TextFormField(
                decoration: const InputDecoration(
                  label: Text('Youtube url'),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please input a Youtube url';
                  }
                  return null;
                },
                onSaved: (value) {
                  youtubeUrl = value!;
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
                    Provider.of<SongDatabase>(context, listen: false).addSong(
                        context: context,
                        songName: songName,
                        artistName: artistName,
                        youtubeUrl: youtubeUrl,
                        imageUrl: imageUrl);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Downloading...')));
                  }
                },
                child: const Text('Add song'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
