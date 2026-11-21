import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/wallpaper.dart';

class Downloader {
  static const dirPath = '/storage/emulated/0/Pictures/Wallhaven';
  final Dio _dio = Dio();

  Future<bool> ensurePermission() async {
    if (await Permission.manageExternalStorage.isGranted) return true;
    // opens the system "All files access" page for this app
    final st = await Permission.manageExternalStorage.request();
    return st.isGranted;
  }

  /// Returns the saved file, or null if permission was denied.
  Future<File?> download(Wallpaper w,
      {void Function(double)? onProgress}) async {
    if (!await ensurePermission()) return null;

    final dir = Directory(dirPath);
    if (!await dir.exists()) await dir.create(recursive: true);

    final ext = w.path.split('.').last;
    final file = File('$dirPath/wallhaven-${w.id}.$ext');
    if (await file.exists()) return file; // already saved

    final tmp = '${file.path}.part';
    await _dio.download(
      w.path,
      tmp,
      onReceiveProgress: (r, t) {
        if (t > 0) onProgress?.call(r / t);
      },
    );
    await File(tmp).rename(file.path);
    return file;
  }
}

final downloaderProvider = Provider<Downloader>((_) => Downloader());
