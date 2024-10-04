import 'package:isar/isar.dart';

// this line is needed to generate file
// then run: flutter pub run build_runner build
part 'song.g.dart';

// song model
@collection
class Song {
  Id id = Isar.autoIncrement;
  final String songName;
  final String artistName;
  late String audioPath;
  late String imagePath;

  Song({required this.songName, required this.artistName});

  // Override the == operator to compare the values of the properties
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true; // Check if they are the same instance
    }
    if (other is! Song) {
      return false; // Check if the other object is not a Song instance
    }

    return other.id == id &&
        other.songName == songName &&
        other.artistName == artistName; // Compare individual properties
  }

  // Override hashCode to be consistent with the == operator
  @override
  int get hashCode => id.hashCode ^ songName.hashCode ^ artistName.hashCode;
}

// playlist model
@collection
class Playlist {
  Id id = Isar.autoIncrement;
  final String playlistName;
  List<int> songIds = [];
  late String imagePath;

  Playlist({required this.playlistName});
}
