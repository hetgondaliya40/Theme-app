import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/depth_wallpaper_model.dart';
import '../../bloc/wallpaper_bloc.dart';
import '../../bloc/wallpaper_event.dart';
import '../../bloc/wallpaper_state.dart';
import '../widgets/depth_card.dart';
import '../widgets/wallpaper_shimmer.dart';
import '../../../coins/presentation/widgets/coin_badge_widget.dart';
import 'depth_detail_screen.dart';

class WallpapersScreen extends StatefulWidget {
  const WallpapersScreen({super.key});

  @override
  State<WallpapersScreen> createState() => _WallpapersScreenState();
}

class _WallpapersScreenState extends State<WallpapersScreen> {
  int _selectedSubTab = 1; // 0: Liked/Fav, 1: Recent (Default), 2: Trending
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;

  final List<String> _categories = [
    'All',
    'Cyberpunk',
    'AMOLED',
    'Anime',
    'Supercars',
    'Space',
    'Nature',
    'Gaming',
    'Abstract',
    'Minimal',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8) {
      context.read<WallpaperBloc>().add(const LoadNextPageWallpapersEvent());
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<DepthWallpaperModel> _getProcessedWallpapers(WallpaperState state) {
    List<DepthWallpaperModel> baseList;

    switch (_selectedSubTab) {
      case 0: // Liked & Favorite Wallpapers
        baseList = state.favoriteWallpapers;
        break;
      case 1: // Recent Wallpapers (Default)
        baseList = state.filteredWallpapers;
        break;
      case 2: // Trending (Highest Downloads & Popularity)
        baseList = List.from(state.filteredWallpapers)
          ..sort((a, b) => b.downloads.compareTo(a.downloads));
        break;
      default:
        baseList = state.filteredWallpapers;
    }

    return baseList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: BlocBuilder<WallpaperBloc, WallpaperState>(
          builder: (context, state) {
            final displayedWallpapers = _getProcessedWallpapers(state);

            return Column(
              children: [
                const SizedBox(height: 12),

                // Top Header Row: "Wallpapers" Title & Coin Badge Widget
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Wallpapers',
                              style: GoogleFonts.outfit(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              '${state.combinedWallpapers.length} Ultra HD 4K Real Artworks',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFFFE500),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const CoinBadgeWidget(),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 14),

                // Real-time Search Input Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1B20),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      onChanged: (query) {
                        _debounceTimer?.cancel();
                        _debounceTimer = Timer(const Duration(milliseconds: 400), () {
                          if (mounted) {
                            context
                                .read<WallpaperBloc>()
                                .add(SearchWallpapersEvent(query));
                          }
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search 4K wallpapers by title or category...',
                        hintStyle: const TextStyle(
                            color: Colors.white38, fontSize: 12),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: Colors.white54, size: 20),
                        suffixIcon: state.searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded,
                                    color: Colors.white54, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  context
                                      .read<WallpaperBloc>()
                                      .add(const SearchWallpapersEvent(''));
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Sub Navigation Tabs: Liked, Recent, Trending (Featured removed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.white10, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSubTab(0,
                          icon: Icons.favorite_rounded, label: 'Liked'),
                      _buildSubTab(1,
                          icon: Icons.access_time_filled_rounded,
                          label: 'Recent'),
                      _buildSubTab(2,
                          icon: Icons.local_fire_department_rounded,
                          label: 'Trending'),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Category Chips Selector Row
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = state.selectedCategory == cat;

                      return GestureDetector(
                        onTap: () {
                          context
                              .read<WallpaperBloc>()
                              .add(FilterByCategoryEvent(cat));
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFFE500)
                                : const Color(0xFF141418),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFFE500)
                                  : Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white70,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 14),

                // 2-Column Responsive Wallpapers Grid
                Expanded(
                  child: state.isLoadingOnline && displayedWallpapers.isEmpty
                      ? GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.52,
                          ),
                          itemCount: 6,
                          itemBuilder: (context, index) =>
                              const WallpaperShimmer(),
                        )
                      : displayedWallpapers.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _selectedSubTab == 0
                                        ? Icons.favorite_border_rounded
                                        : Icons.image_not_supported_rounded,
                                    color: Colors.white38,
                                    size: 56,
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    _selectedSubTab == 0
                                        ? 'No Liked Wallpapers Yet'
                                        : 'No Wallpapers Found',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _selectedSubTab == 0
                                        ? 'Tap the heart icon on any wallpaper to save it here!'
                                        : 'Try searching another category or query.',
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 18),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() => _selectedSubTab = 1);
                                      context.read<WallpaperBloc>().add(
                                          const FilterByCategoryEvent('All'));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFE500),
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text(
                                      'Explore Recent Wallpapers',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              children: [
                                Expanded(
                                  child: GridView.builder(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 16,
                                      crossAxisSpacing: 16,
                                      childAspectRatio: 0.52,
                                    ),
                                    itemCount: displayedWallpapers.length,
                                    itemBuilder: (context, index) {
                                      final item = displayedWallpapers[index];
                                      return DepthCard(
                                        item: item,
                                        animationIndex: index,
                                        isFavorite: state.isFavorite(item.id),
                                        isUnlocked:
                                            state.isWallpaperUnlocked(item.id),
                                        onFavoriteTap: () {
                                          context.read<WallpaperBloc>().add(
                                              ToggleFavoriteEvent(item.id));
                                        },
                                        onTap: () {
                                          context.read<WallpaperBloc>().add(
                                              SelectActiveWallpaperEvent(item));
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DepthDetailScreen(wallpaper: item),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                                if (state.isFetchingMore)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12.0),
                                    child: Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFFFFE500),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSubTab(int index, {required IconData icon, required String label}) {
    final isSelected = _selectedSubTab == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedSubTab = index),
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected
                      ? const Color(0xFFFFE500)
                      : Colors.white54,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFFFFE500)
                        : Colors.white60,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2.5,
            width: 65,
            color: isSelected ? const Color(0xFFFFE500) : Colors.transparent,
          ),
        ],
      ),
    );
  }
}
