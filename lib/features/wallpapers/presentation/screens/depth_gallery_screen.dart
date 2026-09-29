import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/depth_wallpaper_model.dart';
import '../../bloc/wallpaper_bloc.dart';
import '../../bloc/wallpaper_event.dart';
import '../../bloc/wallpaper_state.dart';
import '../widgets/depth_card.dart';
import '../../../coins/presentation/widgets/coin_badge_widget.dart';
import 'depth_detail_screen.dart';

class DepthGalleryScreen extends StatelessWidget {
  const DepthGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: BlocBuilder<WallpaperBloc, WallpaperState>(
          builder: (context, state) {
            final allWallpapers = state.combinedWallpapers;

            return ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                const SizedBox(height: 16),

                // Top Header: "Collection" + Coin Badge Widget (Replaces Go Premium)
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
                              'Collection',
                              style: GoogleFonts.outfit(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              '${allWallpapers.length} Curated HD Wallpapers',
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
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

                const SizedBox(height: 28),

                // 15 CURATED UNIQUE CATEGORIES (450+ HD WALLPAPERS)
                ...[
                  'Cyberpunk',
                  'AMOLED',
                  'Nature',
                  'Anime',
                  'Supercars',
                  'Abstract',
                  'Space',
                  'Minimal',
                  'Gaming',
                  'Fantasy',
                  'Architecture',
                  'Wildlife',
                  'Cinematic',
                  'Neon',
                  'Vintage',
                ].map((catName) {
                  final catItems = allWallpapers
                      .where((w) =>
                          w.category
                              .toLowerCase()
                              .contains(catName.toLowerCase()) ||
                          w.tags.any((t) =>
                              t.toLowerCase().contains(catName.toLowerCase())))
                      .toList();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: _buildCategorySection(
                      context,
                      title: catName,
                      items: catItems.isEmpty
                          ? allWallpapers.take(12).toList()
                          : catItems,
                      state: state,
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context, {
    required String title,
    required List<DepthWallpaperModel> items,
    required WallpaperState state,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _showCategoryGridModal(context,
                      categoryTitle: title, items: items, state: state);
                },
                child: const Row(
                  children: [
                    Text(
                      'View All ',
                      style: TextStyle(
                        color: Color(0xFFFFE500),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFFFFE500),
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Horizontal Scrolling Cards List
        SizedBox(
          height: 310,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                width: 175,
                margin: const EdgeInsets.only(right: 14),
                child: DepthCard(
                  item: item,
                  animationIndex: index,
                  isFavorite: state.isFavorite(item.id),
                  isUnlocked: state.isWallpaperUnlocked(item.id),
                  onFavoriteTap: () {
                    context
                        .read<WallpaperBloc>()
                        .add(ToggleFavoriteEvent(item.id));
                  },
                  onTap: () {
                    context
                        .read<WallpaperBloc>()
                        .add(SelectActiveWallpaperEvent(item));
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DepthDetailScreen(wallpaper: item),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showCategoryGridModal(
    BuildContext context, {
    required String categoryTitle,
    required List<DepthWallpaperModel> items,
    required WallpaperState state,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0C0C10),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (modalContext) {
        return BlocProvider.value(
          value: context.read<WallpaperBloc>(),
          child: BlocBuilder<WallpaperBloc, WallpaperState>(
            builder: (ctx, currentState) {
              return Container(
                height: MediaQuery.of(ctx).size.height * 0.85,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            categoryTitle,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.white70),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Showing ${items.length} HD live wallpapers in $categoryTitle',
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 16),

                    // Grid of Category Items
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.52,
                        ),
                        itemCount: items.length,
                        itemBuilder: (gridCtx, index) {
                          final item = items[index];
                          return DepthCard(
                            item: item,
                            animationIndex: index,
                            isFavorite: currentState.isFavorite(item.id),
                            isUnlocked: currentState.isWallpaperUnlocked(item.id),
                            onFavoriteTap: () {
                              gridCtx
                                  .read<WallpaperBloc>()
                                  .add(ToggleFavoriteEvent(item.id));
                            },
                            onTap: () {
                              Navigator.pop(modalContext);
                              gridCtx
                                  .read<WallpaperBloc>()
                                  .add(SelectActiveWallpaperEvent(item));
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
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
