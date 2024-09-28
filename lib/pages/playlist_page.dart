import 'package:downloader/components/bottom_tile.dart';
import 'package:flutter/material.dart';

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                  child: Image.network(
                      'https://upload.wikimedia.org/wikipedia/en/a/a0/Halzion_cover_art.jpg?20200713143519'),
                ),

                // playlist details
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Playlist x',
                        style: TextStyle(fontSize: 28),
                      ),
                      Text(
                        'xx songs',
                        style: TextStyle(
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.favorite_outline),
                          const SizedBox(width: 18),
                          Icon(
                            Icons.more_vert,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          Expanded(child: Container()),
                          IconButton.filled(
                            onPressed: () {},
                            icon: const Icon(Icons.play_arrow),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
