import '../models/depth_wallpaper_model.dart';
import '../sources/mock_depth_wallpapers.dart';
import '../../../../core/services/online_wallpaper_api_service.dart';

abstract class WallpaperRepository {
  Future<List<DepthWallpaperModel>> getLocalWallpapers();
  Future<List<DepthWallpaperModel>> fetchOnlineWallpapers(String query, {int page = 1});
}

class WallpaperRepositoryImpl implements WallpaperRepository {
  @override
  Future<List<DepthWallpaperModel>> getLocalWallpapers() async {
    // Simulating instant fast reactive loading
    return MockDepthWallpapers.wallpapers;
  }

  @override
  Future<List<DepthWallpaperModel>> fetchOnlineWallpapers(String query, {int page = 1}) async {
    return await OnlineWallpaperApiService.fetchOnlineWallpapers(query: query, page: page);
  }
}
