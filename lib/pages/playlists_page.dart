import 'package:downloader/components/bottom_tile.dart';
import 'package:downloader/pages/playlist_page.dart';
import 'package:flutter/material.dart';

class PlaylistsPage extends StatelessWidget {
  const PlaylistsPage({super.key});

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
            onPressed: () {},
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2),
            itemCount: 10,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlaylistPage(),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: Image.network(
                          'https://upload.wikimedia.org/wikipedia/en/a/a0/Halzion_cover_art.jpg?20200713143519'),
                    ),
                  ),
                  Text('Playlist $index'),
                ],
              );
            },
          ),
          const SizedBox(height: 125),
        ],
      ),
      floatingActionButton: BottomTile(bottomMargin: 58),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
