import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // logo
          DrawerHeader(
            child: Center(
              child: Icon(
                Icons.music_note,
                size: 40,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),

          // home tile
          Padding(
            padding: const EdgeInsets.only(left: 25, top: 25),
            child: ListTile(
              title: const Text('H O M E'),
              leading: const Icon(Icons.home),
              onTap: () => Navigator.pop(context),
            ),
          ),

          // settings tile
          Padding(
            padding: const EdgeInsets.only(left: 25, top: 0),
            child: ListTile(
              title: const Text('P L A Y L I S T S'),
              leading: const Icon(Icons.library_music),
              onTap: () {
                // pop drawer
                Navigator.pop(context);

                // navigate to playlist page
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => PlaylistPage(),
                //   ),
                // );
              },
            ),
          ),
        ],
      ),
    );
  }
}
