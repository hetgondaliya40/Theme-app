import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../features/wallpapers/data/models/depth_wallpaper_model.dart';
import '../../features/wallpapers/data/models/depth_clock_config.dart';

class OnlineWallpaperApiService {
  // Official Wallhaven.cc API Configuration
  static const String _wallhavenBaseUrl = 'https://wallhaven.cc/api/v1/search';
  static const String _apiKey = 'vE3YyDcAowgklbVXCV8kpX1JzJ2GpkFe';

  /// Fetch live 4K wallpapers directly from Wallhaven.cc API
  static Future<List<DepthWallpaperModel>> fetchOnlineWallpapers({
    String query = 'cyberpunk',
    int page = 1,
    String sorting = 'toplist',
  }) async {
    try {
      final cleanQuery = query.toLowerCase().replaceAll('wallpaper', '').trim();
      final searchTerm = cleanQuery.isEmpty ? '4k' : cleanQuery;

      final uri = Uri.parse(
          '$_wallhavenBaseUrl?apikey=$_apiKey&q=${Uri.encodeComponent(searchTerm)}&purity=100&sorting=$sorting&page=$page');

      debugPrint('Fetching Wallhaven API: $uri');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final bodyData = jsonDecode(response.body);
        final List results = bodyData['data'] ?? [];

        if (results.isNotEmpty) {
          final List<Color> palette = [
            const Color(0xFFFFE500),
            const Color(0xFF38BDF8),
            const Color(0xFFFB7185),
            const Color(0xFF2DD4BF),
            const Color(0xFFA855F7),
            const Color(0xFFE11D48),
            const Color(0xFF06B6D4),
          ];

          return results.asMap().entries.map<DepthWallpaperModel>((entry) {
            final index = entry.key;
            final item = entry.value;

            final String whId = item['id'] ?? 'wh_${DateTime.now().millisecondsSinceEpoch}_$index';
            final String fullPath = item['path'] ?? '';
            final String category = item['category'] ?? _capitalizeWords(searchTerm);
            final int views = item['views'] ?? 15400;
            final int favorites = item['favorites'] ?? 450;
            final Color accent = palette[index % palette.length];

            return DepthWallpaperModel(
              id: 'wh_$whId',
              title: '${_capitalizeWords(searchTerm)} #${index + 1}',
              category: _capitalizeWords(category),
              author: 'Wallhaven.cc',
              description: 'Official Wallhaven.cc 4K wallpaper (ID: $whId). High resolution artwork.',
              rating: 4.9,
              downloads: views > 0 ? views : favorites * 25,
              backgroundUrl: fullPath,
              foregroundCutoutUrl: fullPath,
              defaultClockConfig: DepthClockConfig(
                fontFamily: 'Outfit',
                fontSizePercent: 24.0,
                clockColor: Colors.white,
                shadowColor: const Color(0x99000000),
                verticalPositionPercent: 24.0,
                isBehindForeground: true,
                showClock: false,
                showDate: false,
              ),
              tags: [searchTerm, category, 'Wallhaven', '4K'],
              accentColor: accent,
            );
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('Wallhaven API Error or Timeout: $e');
    }

    // Fallback Curated Wallpapers if offline or network error
    return _getCuratedFallbackWallpapers(query);
  }

  static String _capitalizeWords(String input) {
    if (input.isEmpty) return 'Curated Wallpaper';
    return input.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  static List<DepthWallpaperModel> _getCuratedFallbackWallpapers(String query) {
    final List<Map<String, dynamic>> fallbackData = [
      {
        'id': 'api_fb_1',
        'title': 'Neon Horizon 4K',
        'category': 'Sci-Fi',
        'author': 'Alex Rivers',
        'bg': 'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?auto=format&fit=crop&w=1000&q=80',
        'color': const Color(0xFF2DD4BF),
      },
      {
        'id': 'api_fb_2',
        'title': 'Alpine Misty Forest',
        'category': 'Nature',
        'author': 'Elena Rostova',
        'bg': 'https://images.unsplash.com/photo-1501854140801-50d01698950b?auto=format&fit=crop&w=1000&q=80',
        'color': const Color(0xFF10B981),
      },
      {
        'id': 'api_fb_3',
        'title': 'Cyber Car Sunset',
        'category': 'Automotive',
        'author': 'Apex Studio',
        'bg': 'https://images.unsplash.com/photo-1550684848-fac1c5b4e853?auto=format&fit=crop&w=1000&q=80',
        'color': const Color(0xFFF43F5E),
      },
      {
        'id': 'api_fb_4',
        'title': 'Cosmic Galaxy Mist',
        'category': 'Space',
        'author': 'Starlight Art',
        'bg': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=1000&q=80',
        'color': const Color(0xFFA855F7),
      },
    ];

    return fallbackData.map((item) {
      return DepthWallpaperModel(
        id: item['id'],
        title: item['title'],
        category: item['category'],
        author: item['author'],
        description: 'High definition 4K live depth wallpaper with dynamic clock overlay.',
        rating: 4.9,
        downloads: 15400,
        backgroundUrl: item['bg'],
        foregroundCutoutUrl: item['bg'],
        defaultClockConfig: DepthClockConfig(
          fontFamily: 'Outfit',
          fontSizePercent: 24.0,
          clockColor: Colors.white,
          shadowColor: (item['color'] as Color).withValues(alpha: 0.8),
          verticalPositionPercent: 24.0,
          isBehindForeground: true,
        ),
        tags: [query, '4K', 'Curated'],
        accentColor: item['color'] as Color,
      );
    }).toList();
  }
}
