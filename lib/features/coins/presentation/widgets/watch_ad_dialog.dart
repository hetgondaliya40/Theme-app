import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../bloc/coin_bloc.dart';
import '../../bloc/coin_event.dart';

class WatchAdDialog extends StatefulWidget {
  const WatchAdDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const WatchAdDialog(),
    );
  }

  @override
  State<WatchAdDialog> createState() => _WatchAdDialogState();
}

class _WatchAdDialogState extends State<WatchAdDialog> {
  int _secondsRemaining = 5;
  late Timer _timer;
  bool _adFinished = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _startAdTimer();
  }

  void _startAdTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer.cancel();
        setState(() {
          _secondsRemaining = 0;
          _adFinished = true;
        });

        // Grant 10 Coins to user balance via CoinBloc
        if (mounted) {
          context.read<CoinBloc>().add(const EarnCoinFromAdEvent(coins: 10));
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (5 - _secondsRemaining) / 5.0;

    return Dialog(
      backgroundColor: const Color(0xFF0F0F14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 350),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TOP ROW: GOOGLE ADS BRANDING & REWARD COUNTDOWN
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // "Ads by Google" badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4285F4).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF4285F4).withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.ads_click_rounded,
                          color: Color(0xFF4285F4), size: 14),
                      SizedBox(width: 5),
                      Text(
                        'Ads by Google',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Countdown Timer / Close Button
                if (_adFinished)
                  IconButton(
                    icon:
                        const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE500).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFFE500).withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined,
                            color: Color(0xFFFFE500), size: 13),
                        const SizedBox(width: 4),
                        Text(
                          'Reward in ${_secondsRemaining}s',
                          style: const TextStyle(
                            color: Color(0xFFFFE500),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // GOOGLE ADMOB REWARDED VIDEO PLAYER CONTAINER
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  colors: _adFinished
                      ? [
                          const Color(0xFF059669).withValues(alpha: 0.3),
                          const Color(0xFF10B981).withValues(alpha: 0.2),
                        ]
                      : [
                          const Color(0xFF1E293B),
                          const Color(0xFF0F172A),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: _adFinished
                      ? Colors.greenAccent
                      : const Color(0xFF4285F4).withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_adFinished ? Colors.greenAccent : const Color(0xFF4285F4))
                        .withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Mute / Unmute Button (Top Right of Video Player)
                  if (!_adFinished)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () => setState(() => _isMuted = !_isMuted),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Icon(
                            _isMuted
                                ? Icons.volume_off_rounded
                                : Icons.volume_up_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),

                  // Center Ad Content
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!_adFinished) ...[
                            // Playing Video Icon & App Promotion Showcase
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Color(0xFF4285F4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.play_arrow_rounded,
                                  color: Colors.white, size: 32),
                            ).animate().scale(
                                  duration: 600.ms,
                                  curve: Curves.easeInOut,
                                ),
                            const SizedBox(height: 12),
                            Text(
                              'Google AdMob Rewarded Video',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Sponsored by Google Ads • Watch full video to claim 🪙 10 Coins',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white60, fontSize: 11),
                            ),
                          ] else ...[
                            const Icon(Icons.check_circle_rounded,
                                    color: Colors.greenAccent, size: 64)
                                .animate()
                                .scale(
                                    duration: 450.ms, curve: Curves.elasticOut),
                            const SizedBox(height: 10),
                            Text(
                              '+10 COINS EARNED!',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFFFE500),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Google Rewarded Video Completed Successfully',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Bottom Progress Bar
                  if (!_adFinished)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(22)),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFFFE500),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ACTION BUTTON
            if (_adFinished)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Claimed +10 Coins from Google Ad! 🪙'),
                      backgroundColor: Color(0xFFFFE500),
                    ),
                  );
                },
                icon: const Text('🪙', style: TextStyle(fontSize: 18)),
                label: const Text(
                  'CLAIM +10 COINS',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFE500),
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ).animate().fadeIn()
            else
              Container(
                height: 50,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFFFE500),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Watching Google Ad (${_secondsRemaining}s remaining)',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
