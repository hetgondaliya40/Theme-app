import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/depth_wallpaper_model.dart';
import '../../bloc/wallpaper_bloc.dart';
import '../../bloc/wallpaper_event.dart';
import '../../bloc/wallpaper_state.dart';
import '../../../coins/bloc/coin_bloc.dart';
import '../../../coins/bloc/coin_event.dart';
import '../../../coins/bloc/coin_state.dart';
import '../widgets/depth_phone_simulator.dart';
import '../../../coins/presentation/widgets/watch_ad_dialog.dart';
import '../../../coins/presentation/widgets/coin_badge_widget.dart';
import '../../../../core/services/wallpaper_theme_service.dart';

class DepthDetailScreen extends StatefulWidget {
  final DepthWallpaperModel wallpaper;

  const DepthDetailScreen({super.key, required this.wallpaper});

  @override
  State<DepthDetailScreen> createState() => _DepthDetailScreenState();
}

class _DepthDetailScreenState extends State<DepthDetailScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isApplyingWallpaper = false;

  Future<void> _applyWallpaper(WallpaperTarget target, {GlobalKey? repaintKey}) async {
    setState(() => _isApplyingWallpaper = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
            ),
            SizedBox(width: 12),
            Text('Applying wallpaper to phone... Please wait!'),
          ],
        ),
        backgroundColor: Color(0xFFFFE500),
        duration: Duration(seconds: 4),
      ),
    );

    final success = await WallpaperThemeService.setRealPhoneWallpaper(
      context: context,
      imageUrl: widget.wallpaper.backgroundUrl,
      target: target,
      repaintKey: repaintKey,
    );

    if (mounted) {
      setState(() => _isApplyingWallpaper = false);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Wallpaper Applied Successfully to Phone!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _showRealWallpaperOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B1B24),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          widget.wallpaper.accentColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.wallpaper_rounded,
                        color: widget.wallpaper.accentColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Set Phone Wallpaper',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Choose clean lock screen to prevent clock overlap clash',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white12),
              const SizedBox(height: 8),

              // OPTION 1: LOCK SCREEN (CLEAN ARTWORK - NO DOUBLE CLOCK)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: const Color(0xFF262632),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.cyan.withValues(alpha: 0.6)),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.cyan,
                      child: Icon(Icons.lock_rounded, color: Colors.black),
                    ),
                    title: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Clean Lock Screen',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: const BoxDecoration(
                            color: Colors.cyan,
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                          ),
                          child: const Text(
                            'RECOMMENDED',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: const Text(
                      'Sets pure 3D artwork without built-in clock text so your phone\'s native lock screen clock displays cleanly without double clock clash!',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _applyWallpaper(WallpaperTarget.lockScreen);
                    },
                  ),
                ),
              ),

              // OPTION 2: HOME SCREEN (WITH 3D DEPTH CLOCK)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: const Color(0xFF262632),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                        color: widget.wallpaper.accentColor
                            .withValues(alpha: 0.5)),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: widget.wallpaper.accentColor,
                      child: const Icon(Icons.home_rounded, color: Colors.black),
                    ),
                    title: const Text('Home Screen (With 3D Clock)',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    subtitle: const Text(
                      'Applies high-res wallpaper with custom 3D depth clock and date widget on home screen.',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _applyWallpaper(WallpaperTarget.homeScreen, repaintKey: _repaintKey);
                    },
                  ),
                ),
              ),

              // OPTION 3: BOTH SCREENS (CLEAN LOCK + 3D HOME)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: const Color(0xFF262632),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.greenAccent,
                      child: Icon(Icons.phonelink_rounded, color: Colors.black),
                    ),
                    title: const Text('Both Screens (Clean Lock + 3D Home)',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    subtitle: const Text(
                      'Sets clean artwork on lock screen and 3D depth clock on home screen.',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _applyWallpaper(WallpaperTarget.bothScreens, repaintKey: _repaintKey);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _executeWithCoinCheck(
      BuildContext context, CoinState coinState, VoidCallback onUnlockedAction) {
    final isUnlocked = coinState.isWallpaperUnlocked(widget.wallpaper.id);

    if (isUnlocked) {
      onUnlockedAction();
    } else {
      if (coinState.coinBalance >= 10) {
        showDialog(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            backgroundColor: const Color(0xFF1B1B24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Row(
              children: [
                Text('🪙', style: TextStyle(fontSize: 24)),
                SizedBox(width: 8),
                Text('Use 10 Coins?',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
            content: Text(
              'Spend 10 Coins 🪙 to unlock "${widget.wallpaper.title}" permanently?',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  context
                      .read<CoinBloc>()
                      .add(UnlockWallpaperEvent(widget.wallpaper.id, cost: 10));

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Spent 🪙 10 Coins! Wallpaper Unlocked Permanently.'),
                      backgroundColor: Color(0xFFFFE500),
                    ),
                  );
                  onUnlockedAction();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFE500),
                  foregroundColor: Colors.black,
                ),
                child: const Text('Use 10 Coins & Unlock',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            backgroundColor: const Color(0xFF1B1B24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Row(
              children: [
                Text('🪙', style: TextStyle(fontSize: 24)),
                SizedBox(width: 8),
                Text('10 Coins Required',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
            content: const Text(
              'You need 10 Coins to unlock this 4K Wallpaper. Watch a short Google Rewarded Video Ad to earn +10 Coins instantly!',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  WatchAdDialog.show(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFE500),
                  foregroundColor: Colors.black,
                ),
                child: const Text('Watch Ad (+10 Coins)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WallpaperBloc, WallpaperState>(
      builder: (context, state) {
        final coinState = context.watch<CoinBloc>().state;
        final isFav = state.isFavorite(widget.wallpaper.id);
        final isUnlocked = coinState.isWallpaperUnlocked(widget.wallpaper.id);

        return Scaffold(
          backgroundColor: const Color(0xFF0C0C10),
          appBar: AppBar(
            title: Text(widget.wallpaper.title),
            backgroundColor: const Color(0xFF0C0C10),
            elevation: 0,
            actions: [
              const CoinBadgeWidget(),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFav ? Colors.redAccent : Colors.white,
                ),
                onPressed: () {
                  context
                      .read<WallpaperBloc>()
                      .add(ToggleFavoriteEvent(widget.wallpaper.id));
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Smartphone Interactive Simulator
                  Center(
                    child: DepthPhoneSimulator(
                      wallpaper: widget.wallpaper,
                      clockConfig: state.activeClockConfig,
                      scale: 1.0,
                      repaintKey: _repaintKey,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title & Category Metadata Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1B24),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            widget.wallpaper.accentColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.wallpaper.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: widget.wallpaper.accentColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.wallpaper.category,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Created by ${widget.wallpaper.author} • ${widget.wallpaper.downloads} downloads',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.wallpaper.description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons Column
                  Column(
                    children: [
                      // BUTTON 1: SET PURE WALLPAPER TO DEVICE
                      ElevatedButton.icon(
                        onPressed: _isApplyingWallpaper
                            ? null
                            : () {
                                _executeWithCoinCheck(context, coinState, () {
                                  _showRealWallpaperOptions(context);
                                });
                              },
                        icon: _isApplyingWallpaper
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.black),
                              )
                            : Icon(isUnlocked
                                ? Icons.wallpaper_rounded
                                : Icons.lock_open_rounded),
                        label: Text(
                          _isApplyingWallpaper
                              ? 'Applying Wallpaper...'
                              : (isUnlocked
                                  ? 'Set Pure Wallpaper to Device'
                                  : 'Unlock Wallpaper (🪙 10 Coins)'),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.wallpaper.accentColor,
                          foregroundColor: Colors.black,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // BUTTON 2: SAVE HD ARTWORK
                      ElevatedButton.icon(
                        onPressed: () {
                          _executeWithCoinCheck(context, coinState, () async {
                            final path =
                                await WallpaperThemeService.saveWallpaperToStorage(
                              context: context,
                              imageUrl: widget.wallpaper.backgroundUrl,
                              themeTitle: widget.wallpaper.title,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(path != null
                                      ? 'Saved artwork to: $path'
                                      : 'Permission required to save artwork.'),
                                ),
                              );
                            }
                          });
                        },
                        icon: const Icon(Icons.save_alt_rounded),
                        label: Text(
                          isUnlocked
                              ? 'Save HD Artwork'
                              : 'Unlock & Save Artwork (🪙 10 Coins)',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B1B24),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                                color: widget.wallpaper.accentColor
                                    .withValues(alpha: 0.5)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
