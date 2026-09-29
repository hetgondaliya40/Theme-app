import 'package:equatable/equatable.dart';
import '../data/models/depth_wallpaper_model.dart';
import '../data/models/depth_clock_config.dart';

abstract class WallpaperEvent extends Equatable {
  const WallpaperEvent();

  @override
  List<Object?> get props => [];
}

class LoadWallpapersEvent extends WallpaperEvent {
  final String category;
  const LoadWallpapersEvent({this.category = 'All'});

  @override
  List<Object?> get props => [category];
}

class FilterByCategoryEvent extends WallpaperEvent {
  final String category;
  const FilterByCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class SearchWallpapersEvent extends WallpaperEvent {
  final String query;
  const SearchWallpapersEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ToggleFavoriteEvent extends WallpaperEvent {
  final String wallpaperId;
  const ToggleFavoriteEvent(this.wallpaperId);

  @override
  List<Object?> get props => [wallpaperId];
}

class SelectActiveWallpaperEvent extends WallpaperEvent {
  final DepthWallpaperModel wallpaper;
  const SelectActiveWallpaperEvent(this.wallpaper);

  @override
  List<Object?> get props => [wallpaper];
}

class UpdateClockConfigEvent extends WallpaperEvent {
  final DepthClockConfig config;
  const UpdateClockConfigEvent(this.config);

  @override
  List<Object?> get props => [config];
}

class AddCustomWallpaperEvent extends WallpaperEvent {
  final DepthWallpaperModel wallpaper;
  const AddCustomWallpaperEvent(this.wallpaper);

  @override
  List<Object?> get props => [wallpaper];
}

class LoadCoinsEvent extends WallpaperEvent {
  const LoadCoinsEvent();
}

class EarnCoinFromAdEvent extends WallpaperEvent {
  final int coins;
  const EarnCoinFromAdEvent({this.coins = 10});

  @override
  List<Object?> get props => [coins];
}

class UnlockWallpaperEvent extends WallpaperEvent {
  final String wallpaperId;
  final int cost;
  const UnlockWallpaperEvent(this.wallpaperId, {this.cost = 10});

  @override
  List<Object?> get props => [wallpaperId, cost];
}

class ClaimDailyStreakEvent extends WallpaperEvent {
  const ClaimDailyStreakEvent();
}

class LoadNextPageWallpapersEvent extends WallpaperEvent {
  const LoadNextPageWallpapersEvent();
}
