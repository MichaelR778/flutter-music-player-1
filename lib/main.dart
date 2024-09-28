import 'package:downloader/models/playlist_provider.dart';
import 'package:downloader/models/song_database.dart';
import 'package:downloader/pages/root.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  // init isar song db
  WidgetsFlutterBinding.ensureInitialized();
  await SongDatabase.initialize();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => SongDatabase()),
      ChangeNotifierProvider(create: (context) => PlaylistProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Downloader',
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          surface: Colors.grey.shade900,
          primary: const Color.fromARGB(255, 165, 165, 165),
          secondary: const Color.fromARGB(255, 50, 50, 50),
          tertiary: const Color.fromARGB(255, 25, 25, 25), // idk man
          inversePrimary: Colors.grey.shade300,
        ),
      ),
      // theme: ThemeData(
      //   colorScheme: ColorScheme.dark(
      //     surface: Colors.grey.shade900,
      //     primary: Colors.grey.shade600,
      //     secondary: Color.fromARGB(255, 57, 57, 57),
      //     tertiary: Colors.grey.shade800,
      //     inversePrimary: Colors.grey.shade300,
      //   ),
      // ),
      home: Root(),
    );
  }
}
