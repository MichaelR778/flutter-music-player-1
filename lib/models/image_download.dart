import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

// download album art image
Future<String> downloadImage(String url) async {
  final dir = await getExternalStorageDirectory();
  String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  String imagePath = '${dir!.path}/image_$timestamp.jpg';

  Dio dio = Dio();
  await dio.download(url, imagePath);
  print('Download succeed, image path: $imagePath');
  return imagePath;
}

// delete local image and audio file
Future<void> deleteFile(String filePath) async {
  // Create a file object with the given path
  var file = File(filePath);

  // delete file
  await file.delete();
}
