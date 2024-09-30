import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

// download album art image
Future<String> downloadImage(String url) async {
  try {
    final dir = await getExternalStorageDirectory();
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String imagePath = '${dir!.path}/image_$timestamp.jpg';

    Dio dio = Dio();
    await dio.download(url, imagePath);
    print('Download succeed, image path: $imagePath');
    return imagePath;
  } catch (e) {
    print('error: $e');
    // default image if error while download
    // double check for UI to display assetimage instaed if download failed
    return '';
  }
}

// delete local image and audio file
Future<void> deleteFile(String filePath) async {
  try {
    // Create a file object with the given path
    var file = File(filePath);

    // Check if the file exists before deleting it
    if (await file.exists()) {
      await file.delete();
      print('File deleted successfully: $filePath');
    } else {
      print('File not found: $filePath');
    }
  } catch (e) {
    print('Failed to delete the file: $e');
  }
}
