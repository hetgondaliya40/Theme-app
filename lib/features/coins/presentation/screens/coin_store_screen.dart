import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../wallpapers/bloc/wallpaper_bloc.dart';
import '../../../wallpapers/bloc/wallpaper_event.dart';
import '../../../wallpapers/bloc/wallpaper_state.dart';
import '../widgets/watch_ad_dialog.dart';

class CoinStoreScreen extends StatelessWidget {
  const CoinStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090D),
      body: SafeArea(
        child: BlocBuilder<WallpaperBloc, WallpaperState>(
          builder: (context, state) {
            return Column(
              children: [
                // Top Header Row
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 24),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Coin Rewards Store',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Balance Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF262632), Color(0xFF1B1B20)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color:
                                const Color(0xFFFFE500).withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFE500)
                                  .withValues(alpha: 0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'YOUR COIN BALANCE',
                              style: TextStyle(
                                color: Color(0xFFFFE500),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('🪙', style: TextStyle(fontSize: 38)),
                                const SizedBox(width: 10),
                                Text(
                                  '${state.coinBalance}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Use 10 Coins to unlock any 4K HD Wallpaper & set to device!',
                              style: TextStyle(
                                  color: Colors.white60, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 350.ms).scale(
                            begin: const Offset(0.95, 0.95),
                            end: const Offset(1, 1),
                          ),

                      const SizedBox(height: 28),

                      // SECTION 1: 7-DAY STREAK CARD
                      _buildDailyStreakSection(context, state),

                      const SizedBox(height: 28),

                      // SECTION 2: GOOGLE REWARDED VIDEO ADS (+10 COINS)
                      Text(
                        'EARN FREE COINS VIA ADS',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFFFE500),
                          letterSpacing: 1.2,
                        ),
                      ),

                      const SizedBox(height: 14),

                      _buildRewardOptionCard(
                        context,
                        icon: Icons.play_circle_fill_rounded,
                        accentColor: const Color(0xFFFFE500),
                        title: 'Watch Google Rewarded Video Ad',
                        subtitle:
                            'Tap to view a short ad & earn +10 Coins instantly',
                        rewardBadge: '+10 COINS',
                        onTap: () {
                          WatchAdDialog.show(context);
                        },
                      ),

                      const SizedBox(height: 28),

                      Text(
                        'HOW IT WORKS',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white54,
                          letterSpacing: 1.2,
                        ),
                      ),

                      const SizedBox(height: 12),

                      _buildInfoBullet(
                          '1. Open app daily to build your 7-day streak & claim up to 7 free coins on Day 7!'),
                      _buildInfoBullet(
                          '2. Watch Google Rewarded Ads anytime to earn +10 Coins per ad watched.'),
                      _buildInfoBullet(
                          '3. Spend 10 Coins to unlock full-resolution 4K wallpapers permanently!'),

                      const SizedBox(height: 24),
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

  Widget _buildDailyStreakSection(BuildContext context, WallpaperState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF14141A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFF9900).withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9900).withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(
                    '7-Day Daily Streak',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9900).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFF9900)),
                ),
                child: Text(
                  'DAY ${state.streakDay} OF 7',
                  style: const TextStyle(
                    color: Color(0xFFFF9900),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Open app daily to build your streak & claim up to 7 bonus coins on Day 7!',
            style: TextStyle(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: 16),

          // 7-DAY GRID ROW
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(7, (index) {
                final dayNum = index + 1;
                final isCurrentDay = dayNum == state.streakDay;
                final isPassedDay = dayNum < state.streakDay;
                final isClaimed = isPassedDay || (isCurrentDay && state.isStreakClaimedToday);

                Color boxBorderColor = Colors.white10;
                Color boxBgColor = const Color(0xFF1E1E26);
                if (isCurrentDay && !state.isStreakClaimedToday) {
                  boxBorderColor = const Color(0xFFFFE500);
                  boxBgColor = const Color(0xFFFFE500).withValues(alpha: 0.15);
                } else if (isClaimed) {
                  boxBorderColor = Colors.greenAccent.withValues(alpha: 0.6);
                  boxBgColor = Colors.greenAccent.withValues(alpha: 0.1);
                }

                return Container(
                  width: 68,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  decoration: BoxDecoration(
                    color: boxBgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: boxBorderColor,
                      width: isCurrentDay && !state.isStreakClaimedToday ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        dayNum == 7 ? 'Day 7 🔥' : 'Day $dayNum',
                        style: TextStyle(
                          color: isCurrentDay
                              ? const Color(0xFFFFE500)
                              : Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '🪙 $dayNum',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (isClaimed)
                        const Icon(Icons.check_circle_rounded,
                            color: Colors.greenAccent, size: 16)
                      else if (isCurrentDay)
                        const Text(
                          'TODAY',
                          style: TextStyle(
                            color: Color(0xFFFFE500),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      else
                        const Icon(Icons.lock_rounded,
                            color: Colors.white24, size: 14),
                    ],
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 16),

          // CLAIM BUTTON
          if (!state.isStreakClaimedToday)
            ElevatedButton.icon(
              onPressed: () {
                context
                    .read<WallpaperBloc>()
                    .add(const ClaimDailyStreakEvent());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Claimed Day ${state.streakDay} Streak Reward (+${state.streakDay} Coins)! 🪙'),
                    backgroundColor: const Color(0xFFFF9900),
                  ),
                );
              },
                icon: const Text('🔥', style: TextStyle(fontSize: 16)),
                label: Text(
                  'CLAIM DAY ${state.streakDay} STREAK REWARD (+${state.streakDay} COINS 🪙)',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9900),
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              )
          else
            Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.greenAccent, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'CLAIMED TODAY (DAY ${state.streakDay} STREAK ACTIVE 🔥)',
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRewardOptionCard(
    BuildContext context, {
    required IconData icon,
    required Color accentColor,
    required String title,
    required String subtitle,
    required String rewardBadge,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF141418),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: accentColor.withValues(alpha: 0.4)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: accentColor.withValues(alpha: 0.2),
          child: Icon(icon, color: accentColor, size: 26),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            rewardBadge,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(color: Color(0xFFFFE500), fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
