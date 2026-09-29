import 'package:equatable/equatable.dart';

class CoinState extends Equatable {
  final int coinBalance;
  final Set<String> unlockedWallpaperIds;
  final int streakDay;
  final bool isStreakClaimedToday;
  final String? lastStreakClaimDate;

  const CoinState({
    this.coinBalance = 10,
    this.unlockedWallpaperIds = const {},
    this.streakDay = 1,
    this.isStreakClaimedToday = false,
    this.lastStreakClaimDate,
  });

  bool isWallpaperUnlocked(String id) => unlockedWallpaperIds.contains(id);

  CoinState copyWith({
    int? coinBalance,
    Set<String>? unlockedWallpaperIds,
    int? streakDay,
    bool? isStreakClaimedToday,
    String? lastStreakClaimDate,
  }) {
    return CoinState(
      coinBalance: coinBalance ?? this.coinBalance,
      unlockedWallpaperIds: unlockedWallpaperIds ?? this.unlockedWallpaperIds,
      streakDay: streakDay ?? this.streakDay,
      isStreakClaimedToday: isStreakClaimedToday ?? this.isStreakClaimedToday,
      lastStreakClaimDate: lastStreakClaimDate ?? this.lastStreakClaimDate,
    );
  }

  @override
  List<Object?> get props => [
        coinBalance,
        unlockedWallpaperIds,
        streakDay,
        isStreakClaimedToday,
        lastStreakClaimDate,
      ];
}
