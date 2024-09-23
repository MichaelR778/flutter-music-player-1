import 'package:downloader/models/playlist_provider.dart';
import 'package:downloader/models/song_database.dart';
import 'package:downloader/pages/home_page.dart';
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
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          surface: Colors.grey.shade900,
          primary: Colors.grey.shade600,
          secondary: const Color.fromARGB(255, 51, 51, 51),
          inversePrimary: Colors.grey.shade300,
        ),
      ),
      home: HomePage(),
    );
  }
}
