import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

enum WallpaperTarget { homeScreen, lockScreen, bothScreens }

class WallpaperThemeService {
  static const MethodChannel _channel = MethodChannel('com.themecraft/wallpaper');

  /// Request wallpaper and storage permissions on Android device
  static Future<bool> requestPermissions(BuildContext context) async {
    if (!Platform.isAndroid) return true;

    final status = await Permission.photos.request();
    final storageStatus = await Permission.storage.request();

    if (status.isGranted || storageStatus.isGranted || await Permission.manageExternalStorage.isGranted) {
      return true;
    }

    if (context.mounted) {
      final shouldOpenSettings = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.security_rounded, color: Colors.amber),
              SizedBox(width: 8),
              Text('Permission Required'),
            ],
          ),
          content: const Text(
            'ThemeCraft needs Device Storage and Wallpaper permissions to apply high-res wallpapers directly to your phone screen.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              child: const Text('Grant / Open Settings'),
            ),
          ],
        ),
      );

      if (shouldOpenSettings == true) {
        await openAppSettings();
      }
    }

    return false;
  }

  /// Download wallpaper or capture rendered 3D Depth Clock + Date screen bitmap and apply to real phone
  static Future<bool> setRealPhoneWallpaper({
    required BuildContext context,
    required String imageUrl,
    required WallpaperTarget target,
    GlobalKey? repaintKey,
  }) async {
    try {
      // 1. Request permissions
      final hasPermission = await requestPermissions(context);
      if (!hasPermission) return false;

      final tempDir = await getTemporaryDirectory();
      File tempFile;

      // 2. Render and capture composited widget with Date and Clock digits if key is provided
      if (repaintKey != null && repaintKey.currentContext != null) {
        try {
          final boundary = repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary?;
          if (boundary != null) {
            final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
            final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
            if (byteData != null) {
              tempFile = File('${tempDir.path}/composite_depth_clock_${DateTime.now().millisecondsSinceEpoch}.png');
              await tempFile.writeAsBytes(byteData.buffer.asUint8List());
            } else {
              tempFile = await _downloadFile(imageUrl, tempDir);
            }
          } else {
            tempFile = await _downloadFile(imageUrl, tempDir);
          }
        } catch (e) {
          debugPrint('Repaint boundary capture error fallback to download: $e');
          tempFile = await _downloadFile(imageUrl, tempDir);
        }
      } else {
        tempFile = await _downloadFile(imageUrl, tempDir);
      }

      // 3. Map WallpaperTarget to integer flag
      int locationFlag;
      switch (target) {
        case WallpaperTarget.homeScreen:
          locationFlag = 1;
          break;
        case WallpaperTarget.lockScreen:
          locationFlag = 2;
          break;
        case WallpaperTarget.bothScreens:
          locationFlag = 3;
          break;
      }

      // 4. Call native Android WallpaperManager via MethodChannel
      if (Platform.isAndroid) {
        final bool? result = await _channel.invokeMethod<bool>('setWallpaper', {
          'filePath': tempFile.path,
          'location': locationFlag,
        });
        return result ?? false;
      }

      return true;
    } catch (e) {
      debugPrint('Error setting wallpaper on device: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not set wallpaper on device: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return false;
    }
  }

  static Future<File> _downloadFile(String imageUrl, Directory tempDir) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to download wallpaper image (${response.statusCode})');
    }
    final file = File('${tempDir.path}/themecraft_wallpaper_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  /// Download and save wallpaper artwork directly to local app storage
  static Future<String?> saveWallpaperToStorage({
    required BuildContext context,
    required String imageUrl,
    required String themeTitle,
  }) async {
    try {
      final hasPermission = await requestPermissions(context);
      if (!hasPermission) return null;

      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) return null;

      final dir = await getApplicationDocumentsDirectory();
      final sanitizeTitle = themeTitle.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
      final savePath = '${dir.path}/${sanitizeTitle}_wallpaper.jpg';

      final file = File(savePath);
      await file.writeAsBytes(response.bodyBytes);

      return savePath;
    } catch (e) {
      debugPrint('Error saving wallpaper to storage: $e');
      return null;
    }
  }
}
