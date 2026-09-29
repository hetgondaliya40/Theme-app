import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/wallpapers/bloc/wallpaper_bloc.dart';
import 'features/wallpapers/bloc/wallpaper_event.dart';
import 'features/coins/bloc/coin_bloc.dart';
import 'features/coins/bloc/coin_event.dart';
import 'features/themes/bloc/theme_bloc.dart';
import 'features/themes/bloc/theme_state.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/wallpapers/presentation/screens/depth_gallery_screen.dart';
import 'features/wallpapers/presentation/screens/wallpapers_screen.dart';
import 'features/themes/presentation/screens/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await InjectionContainer.init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<WallpaperBloc>(
          create: (_) => WallpaperBloc(repository: InjectionContainer.wallpaperRepository)
            ..add(const LoadWallpapersEvent()),
        ),
        BlocProvider<CoinBloc>(
          create: (_) => CoinBloc()..add(const LoadCoinsEvent()),
        ),
        BlocProvider<ThemeBloc>(
          create: (_) => ThemeBloc(),
        ),
      ],
      child: const DepthCraftApp(),
    ),
  );
}

class DepthCraftApp extends StatelessWidget {
  const DepthCraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp(
          title: 'ThemeCraft - 4K Depth Wallpapers',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: const SplashScreen(),
        );
      },
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DepthGalleryScreen(),
    WallpapersScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Screens Stack
          IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),

          // Signature Floating Capsule Navigation Bar
          Positioned(
            bottom: 20,
            left: 36,
            right: 36,
            child: Container(
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFF1B1B20).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.7),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFloatingNavItem(0, Icons.grid_view_rounded),
                  _buildFloatingNavItem(1, Icons.image_rounded),
                  _buildFloatingNavItem(2, Icons.tune_rounded),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavItem(int index, IconData icon) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFE500) : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Icon(
          icon,
          size: 24,
          color: isSelected ? Colors.black : Colors.white54,
        ),
      ),
    );
  }
}
