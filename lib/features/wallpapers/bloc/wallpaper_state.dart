import 'package:equatable/equatable.dart';
import '../data/models/depth_wallpaper_model.dart';
import '../data/models/depth_clock_config.dart';

class WallpaperState extends Equatable {
  final List<DepthWallpaperModel> allWallpapers;
  final List<DepthWallpaperModel> apiWallpapers;
  final List<DepthWallpaperModel> customWallpapers;
  final Set<String> favoriteIds;
  final String selectedCategory;
  final String searchQuery;
  final DepthWallpaperModel? activeWallpaper;
  final DepthClockConfig activeClockConfig;
  final bool isLoadingOnline;
  final bool isInitialLoading;
  final String? errorMessage;
  final int coinBalance;
  final Set<String> unlockedWallpaperIds;
  final int streakDay;
  final bool isStreakClaimedToday;
  final String? lastStreakClaimDate;
  final int currentPage;
  final bool isFetchingMore;

  const WallpaperState({
    this.allWallpapers = const [],
    this.apiWallpapers = const [],
    this.customWallpapers = const [],
    this.favoriteIds = const {},
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.activeWallpaper,
    this.activeClockConfig = const DepthClockConfig(),
    this.isLoadingOnline = false,
    this.isInitialLoading = false,
    this.errorMessage,
    this.coinBalance = 10,
    this.unlockedWallpaperIds = const {},
    this.streakDay = 1,
    this.isStreakClaimedToday = false,
    this.lastStreakClaimDate,
    this.currentPage = 1,
    this.isFetchingMore = false,
  });

  List<DepthWallpaperModel> get combinedWallpapers => [
        ...customWallpapers,
        ...apiWallpapers,
        ...allWallpapers,
      ];

  List<DepthWallpaperModel> get filteredWallpapers {
    return combinedWallpapers.where((wp) {
      final matchesCategory = selectedCategory == 'All' ||
          wp.category.toLowerCase().contains(selectedCategory.toLowerCase()) ||
          wp.tags.any(
              (t) => t.toLowerCase().contains(selectedCategory.toLowerCase()));

      final matchesQuery = searchQuery.isEmpty ||
          wp.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          wp.author.toLowerCase().contains(searchQuery.toLowerCase()) ||
          wp.tags.any(
              (t) => t.toLowerCase().contains(searchQuery.toLowerCase()));

      return matchesCategory && matchesQuery;
    }).toList();
  }

  List<DepthWallpaperModel> get favoriteWallpapers {
    return combinedWallpapers.where((w) => favoriteIds.contains(w.id)).toList();
  }

  bool isFavorite(String id) => favoriteIds.contains(id);

  bool isWallpaperUnlocked(String id, {bool? isPremiumDefault}) {
    return unlockedWallpaperIds.contains(id);
  }

  WallpaperState copyWith({
    List<DepthWallpaperModel>? allWallpapers,
    List<DepthWallpaperModel>? apiWallpapers,
    List<DepthWallpaperModel>? customWallpapers,
    Set<String>? favoriteIds,
    String? selectedCategory,
    String? searchQuery,
    DepthWallpaperModel? activeWallpaper,
    DepthClockConfig? activeClockConfig,
    bool? isLoadingOnline,
    bool? isInitialLoading,
    String? errorMessage,
    int? coinBalance,
    Set<String>? unlockedWallpaperIds,
    int? streakDay,
    bool? isStreakClaimedToday,
    String? lastStreakClaimDate,
    int? currentPage,
    bool? isFetchingMore,
  }) {
    return WallpaperState(
      allWallpapers: allWallpapers ?? this.allWallpapers,
      apiWallpapers: apiWallpapers ?? this.apiWallpapers,
      customWallpapers: customWallpapers ?? this.customWallpapers,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      activeWallpaper: activeWallpaper ?? this.activeWallpaper,
      activeClockConfig: activeClockConfig ?? this.activeClockConfig,
      isLoadingOnline: isLoadingOnline ?? this.isLoadingOnline,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      errorMessage: errorMessage,
      coinBalance: coinBalance ?? this.coinBalance,
      unlockedWallpaperIds: unlockedWallpaperIds ?? this.unlockedWallpaperIds,
      streakDay: streakDay ?? this.streakDay,
      isStreakClaimedToday: isStreakClaimedToday ?? this.isStreakClaimedToday,
      lastStreakClaimDate: lastStreakClaimDate ?? this.lastStreakClaimDate,
      currentPage: currentPage ?? this.currentPage,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }

  @override
  List<Object?> get props => [
        allWallpapers,
        apiWallpapers,
        customWallpapers,
        favoriteIds,
        selectedCategory,
        searchQuery,
        activeWallpaper,
        activeClockConfig,
        isLoadingOnline,
        isInitialLoading,
        errorMessage,
        coinBalance,
        unlockedWallpaperIds,
        streakDay,
        isStreakClaimedToday,
        lastStreakClaimDate,
        currentPage,
        isFetchingMore,
      ];
}
