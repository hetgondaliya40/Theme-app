import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Centralized Google Mobile Ads Manager with separate placement Test Ad Unit IDs
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  bool _isInitialized = false;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  AppOpenAd? _appOpenAd;

  // OFFICIAL GOOGLE TEST AD UNIT IDS (ANDROID & IOS)
  static String get appOpenAdUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/9257395921';
    return 'ca-app-pub-3940256099942544/5575463023';
  }

  static String get galleryBannerAdUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/6300978111';
    return 'ca-app-pub-3940256099942544/2934735716';
  }

  static String get wallpapersBannerAdUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/6300978111';
    return 'ca-app-pub-3940256099942544/2934735716';
  }

  static String get settingsBannerAdUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/6300978111';
    return 'ca-app-pub-3940256099942544/2934735716';
  }

  static String get coinStoreBannerAdUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/6300978111';
    return 'ca-app-pub-3940256099942544/2934735716';
  }

  static String get detailInterstitialAdUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/1033173712';
    return 'ca-app-pub-3940256099942544/4486956720';
  }

  static String get applyWallpaperInterstitialAdUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/1033173712';
    return 'ca-app-pub-3940256099942544/4486956720';
  }

  static String get watchAdRewardedAdUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/5224354917';
    return 'ca-app-pub-3940256099942544/1712485313';
  }

  static String get feedNativeAdUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/2241692871';
    return 'ca-app-pub-3940256099942544/3986624511';
  }

  Future<void> init() async {
    if (_isInitialized) return;
    await MobileAds.instance.initialize();
    _isInitialized = true;
    loadInterstitialAd();
    loadAppOpenAd();
  }

  // --- APP OPEN AD ---
  void loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          _appOpenAd = null;
        },
      ),
    );
  }

  void showAppOpenAdIfAvailable() {
    if (_appOpenAd != null) {
      _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _appOpenAd = null;
          loadAppOpenAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _appOpenAd = null;
          loadAppOpenAd();
        },
      );
      _appOpenAd!.show();
    }
  }

  // --- INTERSTITIAL AD ---
  void loadInterstitialAd({String? adUnitId}) {
    InterstitialAd.load(
      adUnitId: adUnitId ?? detailInterstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  void showInterstitialAd({required VoidCallback onAdClosed, String? adUnitId}) {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          loadInterstitialAd(adUnitId: adUnitId);
          onAdClosed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          loadInterstitialAd(adUnitId: adUnitId);
          onAdClosed();
        },
      );
      _interstitialAd!.show();
    } else {
      loadInterstitialAd(adUnitId: adUnitId);
      onAdClosed();
    }
  }

  // --- REWARDED AD ---
  void showRewardedAd({
    required Function(RewardItem reward) onUserEarnedReward,
    required VoidCallback onAdClosed,
  }) {
    RewardedAd.load(
      adUnitId: watchAdRewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              onAdClosed();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _rewardedAd = null;
              onAdClosed();
            },
          );
          _rewardedAd!.show(
            onUserEarnedReward: (ad, reward) {
              onUserEarnedReward(reward);
            },
          );
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          onAdClosed();
        },
      ),
    );
  }
}

/// Reusable Banner Ad Widget for Placement anywhere in app UI
class BannerAdWidget extends StatefulWidget {
  final String adUnitId;

  const BannerAdWidget({
    super.key,
    required this.adUnitId,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded && _bannerAd != null) {
      return Container(
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }

    return const SizedBox.shrink();
  }
}
