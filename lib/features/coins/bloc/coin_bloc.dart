import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'coin_event.dart';
import 'coin_state.dart';

class CoinBloc extends Bloc<CoinEvent, CoinState> {
  CoinBloc() : super(const CoinState()) {
    on<LoadCoinsEvent>(_onLoadCoins);
    on<EarnCoinFromAdEvent>(_onEarnCoinFromAd);
    on<UnlockWallpaperEvent>(_onUnlockWallpaper);
    on<ClaimDailyStreakEvent>(_onClaimDailyStreak);
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    return "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  String _getYesterdayDateString() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return "${yesterday.year.toString().padLeft(4, '0')}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";
  }

  Future<void> _onLoadCoins(
    LoadCoinsEvent event,
    Emitter<CoinState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final coins = prefs.getInt('user_coin_balance') ?? 10;
      final unlockedList = prefs.getStringList('unlocked_wallpaper_ids') ?? [];
      final lastClaimDate = prefs.getString('last_streak_claim_date');
      final savedStreakDay = prefs.getInt('streak_day') ?? 1;

      final todayStr = _getTodayDateString();
      final yesterdayStr = _getYesterdayDateString();

      bool isClaimedToday = false;
      int currentStreak = savedStreakDay;

      if (lastClaimDate == todayStr) {
        isClaimedToday = true;
        currentStreak = savedStreakDay;
      } else if (lastClaimDate == yesterdayStr) {
        isClaimedToday = false;
        if (savedStreakDay >= 7) {
          currentStreak = 1;
        } else {
          currentStreak = savedStreakDay + 1;
        }
      } else {
        isClaimedToday = false;
        currentStreak = 1;
      }

      emit(state.copyWith(
        coinBalance: coins,
        unlockedWallpaperIds: Set<String>.from(unlockedList),
        streakDay: currentStreak,
        isStreakClaimedToday: isClaimedToday,
        lastStreakClaimDate: lastClaimDate,
      ));
    } catch (_) {}
  }

  Future<void> _onEarnCoinFromAd(
    EarnCoinFromAdEvent event,
    Emitter<CoinState> emit,
  ) async {
    final newBalance = state.coinBalance + event.coins;
    emit(state.copyWith(coinBalance: newBalance));

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_coin_balance', newBalance);
    } catch (_) {}
  }

  Future<void> _onUnlockWallpaper(
    UnlockWallpaperEvent event,
    Emitter<CoinState> emit,
  ) async {
    if (state.coinBalance >= event.cost) {
      final newBalance = state.coinBalance - event.cost;
      final newUnlocked = Set<String>.from(state.unlockedWallpaperIds)
        ..add(event.wallpaperId);

      emit(state.copyWith(
        coinBalance: newBalance,
        unlockedWallpaperIds: newUnlocked,
      ));

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_coin_balance', newBalance);
        await prefs.setStringList('unlocked_wallpaper_ids', newUnlocked.toList());
      } catch (_) {}
    }
  }

  Future<void> _onClaimDailyStreak(
    ClaimDailyStreakEvent event,
    Emitter<CoinState> emit,
  ) async {
    if (state.isStreakClaimedToday) return;

    final rewardCoins = state.streakDay;
    final newBalance = state.coinBalance + rewardCoins;
    final todayStr = _getTodayDateString();

    emit(state.copyWith(
      coinBalance: newBalance,
      isStreakClaimedToday: true,
      lastStreakClaimDate: todayStr,
    ));

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_coin_balance', newBalance);
      await prefs.setInt('streak_day', state.streakDay);
      await prefs.setString('last_streak_claim_date', todayStr);
    } catch (_) {}
  }
}
