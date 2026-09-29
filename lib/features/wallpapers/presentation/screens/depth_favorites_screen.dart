import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/wallpaper_bloc.dart';
import '../../bloc/wallpaper_event.dart';
import '../../bloc/wallpaper_state.dart';
import '../widgets/depth_card.dart';
import 'depth_detail_screen.dart';

class DepthFavoritesScreen extends StatelessWidget {
  const DepthFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Favorite Wallpapers',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: BlocBuilder<WallpaperBloc, WallpaperState>(
        builder: (context, state) {
          final favs = state.favoriteWallpapers;

          if (favs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border_rounded,
                      size: 64, color: Colors.white38),
                  const SizedBox(height: 16),
                  const Text('No Favorites Yet',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap the heart icon on any 3D wallpaper to add it to your favorites.',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.52,
            ),
            itemCount: favs.length,
            itemBuilder: (context, index) {
              final item = favs[index];
              return DepthCard(
                item: item,
                animationIndex: index,
                isFavorite: true,
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
                      builder: (context) => DepthDetailScreen(wallpaper: item),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
