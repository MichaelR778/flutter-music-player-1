import 'package:isar/isar.dart';

// this line is needed to generate file
// then run: flutter pub run build_runner build
part 'song.g.dart';

@collection
class Song {
  Id id = Isar.autoIncrement;
  final String songName;
  final String artistName;
  late String audioPath;
  // note: image path could be null so double check before generating UI
  late String? imagePath;

  Song({required this.songName, required this.artistName});
}
