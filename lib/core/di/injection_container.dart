import '../../features/wallpapers/data/repositories/wallpaper_repository.dart';
import '../services/ad_service.dart';

class InjectionContainer {
  static late final WallpaperRepository wallpaperRepository;

  static Future<void> init() async {
    wallpaperRepository = WallpaperRepositoryImpl();
    await AdService.instance.init();
  }
}
