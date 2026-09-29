import '../../features/wallpapers/data/repositories/wallpaper_repository.dart';

class InjectionContainer {
  static late final WallpaperRepository wallpaperRepository;

  static void init() {
    wallpaperRepository = WallpaperRepositoryImpl();
  }
}
