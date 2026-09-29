import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  String _statusMessage = 'Initializing ThemeCraft...';
  double _progressValue = 0.1;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _runPreFlightInitialization();
  }

  Future<void> _runPreFlightInitialization() async {
    // Step 1: Initialize app resources
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _statusMessage = 'Loading 450+ 4K Wallpapers & BLoC Engine...';
      _progressValue = 0.4;
    });

    // Step 2: One-time launch permission request
    await Future.delayed(const Duration(milliseconds: 600));
    final prefs = await SharedPreferences.getInstance();
    final bool hasPromptedOnce =
        prefs.getBool('has_prompted_launch_permissions') ?? false;

    if (!hasPromptedOnce) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Requesting Storage & Wallpaper Permissions...';
          _progressValue = 0.7;
        });
      }

      await [
        Permission.photos,
        Permission.storage,
      ].request();

      await prefs.setBool('has_prompted_launch_permissions', true);
    }

    if (!mounted) return;
    setState(() {
      _statusMessage = 'Ready! Launching ThemeCraft...';
      _progressValue = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainNavigationShell()),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Gradient Glow
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    Color(0x33FFE500),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo Shell
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF141418),
                      border: Border.all(
                        color: const Color(0xFFFFE500),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFE500).withValues(alpha: 0.4),
                          blurRadius: 32,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset(
                        'assets/icon/app_logo.png',
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                          Icons.wallpaper_rounded,
                          color: Color(0xFFFFE500),
                          size: 54,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Title Text
                Text(
                  'ThemeCraft',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '3D Depth Wallpapers & Live Clock',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFFE500),
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 48),

                // Progress Bar Container
                SizedBox(
                  width: 220,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _progressValue,
                          minHeight: 4,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFFFE500),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _statusMessage,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
