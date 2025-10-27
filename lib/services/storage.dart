import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StorageService {
  static Future<String> appDir() async =>
      (await getApplicationDocumentsDirectory()).path;

  static Future<File> copyImageToAppDir(String sourcePath) async {
    final dir = await appDir();
    final photosDir = Directory(p.join(dir, 'photos'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    final filename = p.basename(sourcePath);
    final target = File(p.join(photosDir.path, filename));
    return File(sourcePath).copy(target.path);
  }
}
