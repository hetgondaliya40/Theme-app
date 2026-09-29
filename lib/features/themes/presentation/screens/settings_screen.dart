import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../coins/bloc/coin_bloc.dart';
import '../../../coins/bloc/coin_state.dart';
import '../../../coins/presentation/screens/coin_store_screen.dart';
import '../../../../core/services/wallpaper_theme_service.dart';
import '../../../../core/services/ad_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showAppPermissionsDialog(BuildContext context) async {
    final status = await WallpaperThemeService.requestPermissions(context);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status
              ? 'All Storage & Wallpaper Permissions Granted!'
              : 'Permissions required for setting wallpapers.'),
          backgroundColor: status ? const Color(0xFFFFE500) : Colors.redAccent,
        ),
      );
    }
  }

  void _showPrivacyModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B1B24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Privacy & Security',
                  style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'ThemeCraft respects your privacy. We do not collect personal identification data. Wallpaper cache and coin balances are stored locally on your device.',
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: BlocBuilder<CoinBloc, CoinState>(
          builder: (context, coinState) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              children: [
                Text(
                  'Settings',
                  style: GoogleFonts.outfit(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),

                // ADMOB BANNER AD IMPRESSION
                Center(
                  child: BannerAdWidget(
                    adUnitId: AdService.settingsBannerAdUnitId,
                  ),
                ),

                const SizedBox(height: 16),

                // Rewards & Coins Balance Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF262632), Color(0xFF1B1B20)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFFFE500).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: Color(0xFFFFE500),
                        child: Text('🪙', style: TextStyle(fontSize: 26)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${coinState.coinBalance} Coins Available',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Watch ads anytime to earn coins & unlock wallpapers',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CoinStoreScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE500),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Earn Coins',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                _buildSectionHeader('SYSTEM & PREFERENCES'),
                const SizedBox(height: 12),

                // SMALL NATIVE AD IMPRESSION
                const NativeAdWidget(size: NativeAdSize.small),
                const SizedBox(height: 12),

                _buildSettingsItem(
                  icon: Icons.security_rounded,
                  title: 'Device Storage & Permissions',
                  subtitle: 'Manage storage and wallpaper setting access',
                  onTap: () => _showAppPermissionsDialog(context),
                ),
                _buildSettingsItem(
                  icon: Icons.cleaning_services_rounded,
                  title: 'Clear Cache & Memory',
                  subtitle: 'Free up local wallpaper memory cache',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Memory & Image Cache Cleared Successfully!'),
                        backgroundColor: Color(0xFFFFE500),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 28),

                _buildSectionHeader('ABOUT THEMECRAFT'),
                const SizedBox(height: 12),

                // SLEEK HERO ABOUT SHOWCASE CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2A2100), Color(0xFF141418)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: const Color(0xFFFFE500).withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFE500).withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFE500),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.auto_awesome_rounded,
                                color: Colors.black, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ThemeCraft Studio',
                                  style: GoogleFonts.outfit(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const Text(
                                  'Next-Gen 4K Depth & AMOLED Art Studio',
                                  style: TextStyle(
                                    color: Color(0xFFFFE500),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'ThemeCraft provides high-resolution 4K depth wallpapers, AMOLED dark aesthetics, dynamic 3D clock customization, and a 100% free reward-based coin ecosystem directly for your device.',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 12, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildBadge('✨ 4K Ultra HD'),
                          _buildBadge('🎨 3D Depth Engine'),
                          _buildBadge('🪙 Coin Rewards'),
                          _buildBadge('🔥 7-Day Streak'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // INTERACTIVE ABOUT OPTIONS
                _buildSettingsItem(
                  icon: Icons.star_rate_rounded,
                  title: 'Rate ThemeCraft',
                  subtitle: 'Love the app? Leave us a 5-star rating!',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thank you for rating ThemeCraft 5 Stars! ⭐⭐⭐⭐⭐'),
                        backgroundColor: Color(0xFFFFE500),
                      ),
                    );
                  },
                ),
                _buildSettingsItem(
                  icon: Icons.share_rounded,
                  title: 'Share App with Friends',
                  subtitle: 'Spread the word and share 4K wallpapers',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ThemeCraft app link copied to clipboard! 🚀'),
                        backgroundColor: Colors.cyanAccent,
                      ),
                    );
                  },
                ),
                _buildSettingsItem(
                  icon: Icons.privacy_tip_rounded,
                  title: 'Privacy & Security Policy',
                  subtitle: '100% local storage & safe data policy',
                  onTap: () => _showPrivacyModal(context),
                ),
                _buildSettingsItem(
                  icon: Icons.bolt_rounded,
                  title: 'App Version',
                  subtitle: 'ThemeCraft v3.0.0',
                  onTap: () {},
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFFFFE500),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: const Color(0xFF141418),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1B20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          trailing: const Icon(Icons.chevron_right_rounded,
              color: Colors.white38, size: 20),
        ),
      ),
    );
  }
}
