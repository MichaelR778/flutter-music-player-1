import 'package:isar/isar.dart';

// this line is needed to generate file
// then run: flutter pub run build_runner build
part 'playlist.g.dart';

@collection
class Playlist {
  Id id = Isar.autoIncrement;
  final String playlistName;
  final List<int> songIds = [];

  Playlist({required this.playlistName});
}
