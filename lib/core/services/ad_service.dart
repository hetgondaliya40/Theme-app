import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_fonts/google_fonts.dart';

enum NativeAdSize { small, medium, large }

/// Centralized Google Mobile Ads Manager with Preloading Cache & Native Ad Sizes
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  /// SINGLE CENTRAL BOOLEAN CONFIGURATION FOR ALL ADS
  /// Set [showTestAd] = true to display Google Test Ads across all features.
  /// Set [showTestAd] = false to display Real Production Ads loaded from assets/ad_unit_ids.json.
  static bool showTestAd = true;

  static Map<String, String> _realAdUnitIds = {};
  bool _isInitialized = false;

  // Preloaded Cache Slots
  InterstitialAd? _preloadedInterstitialAd;
  RewardedAd? _preloadedRewardedAd;
  AppOpenAd? _preloadedAppOpenAd;

  bool _isPreloadingInterstitial = false;
  bool _isPreloadingRewarded = false;
  bool _isPreloadingAppOpen = false;

  // OFFICIAL GOOGLE TEST AD UNIT IDS (ANDROID & IOS)
  static const String _testAppOpenAndroid = 'ca-app-pub-3940256099942544/9257395921';
  static const String _testAppOpenIOS = 'ca-app-pub-3940256099942544/5575463023';

  static const String _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIOS = 'ca-app-pub-3940256099942544/2934735716';

  static const String _testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIOS = 'ca-app-pub-3940256099942544/4486956720';

  static const String _testRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedIOS = 'ca-app-pub-3940256099942544/1712485313';

  static const String _testNativeAndroid = 'ca-app-pub-3940256099942544/2241692871';
  static const String _testNativeIOS = 'ca-app-pub-3940256099942544/3986624511';

  static String get appOpenAdUnitId {
    if (showTestAd) {
      return Platform.isAndroid ? _testAppOpenAndroid : _testAppOpenIOS;
    }
    return _realAdUnitIds['App open'] ?? (Platform.isAndroid ? _testAppOpenAndroid : _testAppOpenIOS);
  }

  static String get galleryBannerAdUnitId {
    if (showTestAd) {
      return Platform.isAndroid ? _testBannerAndroid : _testBannerIOS;
    }
    return _realAdUnitIds['Banner Gallery'] ?? (Platform.isAndroid ? _testBannerAndroid : _testBannerIOS);
  }

  static String get wallpapersBannerAdUnitId {
    if (showTestAd) {
      return Platform.isAndroid ? _testBannerAndroid : _testBannerIOS;
    }
    return _realAdUnitIds['Banner Wallpapers'] ?? (Platform.isAndroid ? _testBannerAndroid : _testBannerIOS);
  }

  static String get settingsBannerAdUnitId {
    if (showTestAd) {
      return Platform.isAndroid ? _testBannerAndroid : _testBannerIOS;
    }
    return _realAdUnitIds['Banner Settings'] ?? (Platform.isAndroid ? _testBannerAndroid : _testBannerIOS);
  }

  static String get coinStoreBannerAdUnitId {
    if (showTestAd) {
      return Platform.isAndroid ? _testBannerAndroid : _testBannerIOS;
    }
    return _realAdUnitIds['Banner Coin Store'] ?? (Platform.isAndroid ? _testBannerAndroid : _testBannerIOS);
  }

  static String get detailInterstitialAdUnitId {
    if (showTestAd) {
      return Platform.isAndroid ? _testInterstitialAndroid : _testInterstitialIOS;
    }
    return _realAdUnitIds['Interstitial Detail'] ?? (Platform.isAndroid ? _testInterstitialAndroid : _testInterstitialIOS);
  }

  static String get applyInterstitialAdUnitId {
    if (showTestAd) {
      return Platform.isAndroid ? _testInterstitialAndroid : _testInterstitialIOS;
    }
    return _realAdUnitIds['Interstitial Apply'] ?? (Platform.isAndroid ? _testInterstitialAndroid : _testInterstitialIOS);
  }

  static String get watchAdRewardedAdUnitId {
    if (showTestAd) {
      return Platform.isAndroid ? _testRewardedAndroid : _testRewardedIOS;
    }
    return _realAdUnitIds['Rewarded Coins'] ?? (Platform.isAndroid ? _testRewardedAndroid : _testRewardedIOS);
  }

  static String get smallNativeAdUnitId {
    if (showTestAd) {
      return Platform.isAndroid ? _testNativeAndroid : _testNativeIOS;
    }
    return _realAdUnitIds['Native Small'] ?? (Platform.isAndroid ? _testNativeAndroid : _testNativeIOS);
  }

  static String get mediumNativeAdUnitId {
    if (showTestAd) {
      return Platform.isAndroid ? _testNativeAndroid : _testNativeIOS;
    }
    return _realAdUnitIds['Native Medium'] ?? (Platform.isAndroid ? _testNativeAndroid : _testNativeIOS);
  }

  static String get largeNativeAdUnitId {
    if (showTestAd) {
      return Platform.isAndroid ? _testNativeAndroid : _testNativeIOS;
    }
    return _realAdUnitIds['Native Large'] ?? (Platform.isAndroid ? _testNativeAndroid : _testNativeIOS);
  }

  /// Initialize SDK, load ad_unit_ids.json, configure test device & pre-cache ads
  Future<void> init() async {
    if (_isInitialized) return;
    await MobileAds.instance.initialize();

    try {
      final jsonString = await rootBundle.loadString('assets/ad_unit_ids.json');
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      _realAdUnitIds = decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      debugPrint('AdService: Failed to load assets/ad_unit_ids.json: $e');
    }

    if (showTestAd) {
      final configuration = RequestConfiguration(
        testDeviceIds: [
          '4BC910E4DFECC2E55D145CE0E1119FF2',
          '10BF7R0GUZ005YM',
          '0575770E7D1A01983025DCD5B2AF9FD6',
        ],
      );
      await MobileAds.instance.updateRequestConfiguration(configuration);
    }

    _isInitialized = true;

    // Warm up ad cache pool asynchronously in background
    preloadAppOpenAd();
    preloadInterstitialAd();
    preloadRewardedAd();
  }

  // --- APP OPEN AD PRELOAD & DISPLAY ---
  void preloadAppOpenAd() {
    if (_preloadedAppOpenAd != null || _isPreloadingAppOpen) return;
    _isPreloadingAppOpen = true;

    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _preloadedAppOpenAd = ad;
          _isPreloadingAppOpen = false;
        },
        onAdFailedToLoad: (error) {
          _preloadedAppOpenAd = null;
          _isPreloadingAppOpen = false;
        },
      ),
    );
  }

  void showAppOpenAdIfAvailable() {
    if (_preloadedAppOpenAd != null) {
      final ad = _preloadedAppOpenAd;
      _preloadedAppOpenAd = null;
      ad!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          preloadAppOpenAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          preloadAppOpenAd();
        },
      );
      ad.show();
    } else {
      preloadAppOpenAd();
    }
  }

  // --- INTERSTITIAL AD PRELOAD & DISPLAY ---
  void preloadInterstitialAd({String? adUnitId}) {
    if (_preloadedInterstitialAd != null || _isPreloadingInterstitial) return;
    _isPreloadingInterstitial = true;

    InterstitialAd.load(
      adUnitId: adUnitId ?? detailInterstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _preloadedInterstitialAd = ad;
          _isPreloadingInterstitial = false;
        },
        onAdFailedToLoad: (error) {
          _preloadedInterstitialAd = null;
          _isPreloadingInterstitial = false;
        },
      ),
    );
  }

  void showInterstitialAd({required VoidCallback onAdClosed, String? adUnitId}) {
    if (_preloadedInterstitialAd != null) {
      final ad = _preloadedInterstitialAd!;
      _preloadedInterstitialAd = null;

      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (adInstance) {
          adInstance.dispose();
          preloadInterstitialAd(adUnitId: adUnitId);
          onAdClosed();
        },
        onAdFailedToShowFullScreenContent: (adInstance, error) {
          adInstance.dispose();
          preloadInterstitialAd(adUnitId: adUnitId);
          onAdClosed();
        },
      );
      ad.show();
    } else {
      // Fallback: Load and show on demand
      InterstitialAd.load(
        adUnitId: adUnitId ?? detailInterstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (adInstance) {
                adInstance.dispose();
                preloadInterstitialAd(adUnitId: adUnitId);
                onAdClosed();
              },
              onAdFailedToShowFullScreenContent: (adInstance, error) {
                adInstance.dispose();
                preloadInterstitialAd(adUnitId: adUnitId);
                onAdClosed();
              },
            );
            ad.show();
          },
          onAdFailedToLoad: (error) {
            preloadInterstitialAd(adUnitId: adUnitId);
            onAdClosed();
          },
        ),
      );
    }
  }

  // --- REWARDED AD PRELOAD & DISPLAY ---
  void preloadRewardedAd({String? adUnitId}) {
    if (_preloadedRewardedAd != null || _isPreloadingRewarded) return;
    _isPreloadingRewarded = true;

    RewardedAd.load(
      adUnitId: adUnitId ?? watchAdRewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _preloadedRewardedAd = ad;
          _isPreloadingRewarded = false;
        },
        onAdFailedToLoad: (error) {
          _preloadedRewardedAd = null;
          _isPreloadingRewarded = false;
        },
      ),
    );
  }

  void showRewardedAd({
    required Function(RewardItem reward) onUserEarnedReward,
    required VoidCallback onAdClosed,
    String? adUnitId,
  }) {
    if (_preloadedRewardedAd != null) {
      final ad = _preloadedRewardedAd!;
      _preloadedRewardedAd = null;

      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (adInstance) {
          adInstance.dispose();
          preloadRewardedAd(adUnitId: adUnitId);
          onAdClosed();
        },
        onAdFailedToShowFullScreenContent: (adInstance, error) {
          adInstance.dispose();
          preloadRewardedAd(adUnitId: adUnitId);
          onAdClosed();
        },
      );

      ad.show(
        onUserEarnedReward: (adInstance, reward) {
          onUserEarnedReward(reward);
        },
      );
    } else {
      // Fallback: On demand load and show
      RewardedAd.load(
        adUnitId: adUnitId ?? watchAdRewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (adInstance) {
                adInstance.dispose();
                preloadRewardedAd(adUnitId: adUnitId);
                onAdClosed();
              },
              onAdFailedToShowFullScreenContent: (adInstance, error) {
                adInstance.dispose();
                preloadRewardedAd(adUnitId: adUnitId);
                onAdClosed();
              },
            );
            ad.show(
              onUserEarnedReward: (adInstance, reward) {
                onUserEarnedReward(reward);
              },
            );
          },
          onAdFailedToLoad: (error) {
            preloadRewardedAd(adUnitId: adUnitId);
            onAdClosed();
          },
        ),
      );
    }
  }
}

/// Reusable Banner Ad Widget
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
          debugPrint('Banner ad failed to load ($widget.adUnitId): $error');
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

/// Multi-Size Native Ad Widget (Small, Medium, Large)
class NativeAdWidget extends StatefulWidget {
  final NativeAdSize size;
  final String? adUnitId;

  const NativeAdWidget({
    super.key,
    this.size = NativeAdSize.medium,
    this.adUnitId,
  });

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  BannerAd? _fallbackBannerAd;
  bool _isNativeLoaded = false;
  bool _isBannerLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadNativeAd();
  }

  String get _resolvedAdUnitId {
    if (widget.adUnitId != null) return widget.adUnitId!;
    switch (widget.size) {
      case NativeAdSize.small:
        return AdService.smallNativeAdUnitId;
      case NativeAdSize.medium:
        return AdService.mediumNativeAdUnitId;
      case NativeAdSize.large:
        return AdService.largeNativeAdUnitId;
    }
  }

  double get _height {
    switch (widget.size) {
      case NativeAdSize.small:
        return 90;
      case NativeAdSize.medium:
        return 280;
      case NativeAdSize.large:
        return 380;
    }
  }

  void _loadNativeAd() {
    try {
      _nativeAd = NativeAd(
        adUnitId: _resolvedAdUnitId,
        request: const AdRequest(),
        nativeTemplateStyle: NativeTemplateStyle(
          templateType: widget.size == NativeAdSize.small
              ? TemplateType.small
              : TemplateType.medium,
          mainBackgroundColor: const Color(0xFF14141A),
          cornerRadius: 16.0,
        ),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            if (mounted) {
              setState(() {
                _isNativeLoaded = true;
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('Native ad failed to load ($_resolvedAdUnitId): $error');
            ad.dispose();
            _nativeAd = null;
            _loadFallbackBannerAd();
          },
        ),
      );
      _nativeAd?.load();
    } catch (_) {
      _loadFallbackBannerAd();
    }
  }

  void _loadFallbackBannerAd() {
    try {
      final adSize = widget.size == NativeAdSize.small
          ? AdSize.banner
          : AdSize.mediumRectangle;

      _fallbackBannerAd = BannerAd(
        adUnitId: AdService.wallpapersBannerAdUnitId,
        size: adSize,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (mounted) {
              setState(() {
                _isBannerLoaded = true;
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('Fallback banner ad failed to load: $error');
            ad.dispose();
            _fallbackBannerAd = null;
          },
        ),
      )..load();
    } catch (_) {}
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    _fallbackBannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isNativeLoaded && _nativeAd != null) {
      return Container(
        height: _height,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1B22),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFFE500).withValues(alpha: 0.3),
          ),
        ),
        child: AdWidget(ad: _nativeAd!),
      );
    }

    if (_isBannerLoaded && _fallbackBannerAd != null) {
      return Container(
        height: _height,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1B22),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFFE500).withValues(alpha: 0.3),
          ),
        ),
        child: AdWidget(ad: _fallbackBannerAd!),
      );
    }

    if (widget.size == NativeAdSize.small) {
      return Container(
        height: _height,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF14141A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFFE500).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE500),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'AD',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sponsor • ThemeCraft Pro',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Discover 4K Depth Wallpapers',
                    style: TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE500),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'GET',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Medium / Large Native Ad Fallback
    return Container(
      height: _height,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14141A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFE500).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE500),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'AD',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sponsor • ThemeCraft Pro',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.stars_rounded, color: Color(0xFFFFE500), size: 40),
          const SizedBox(height: 8),
          const Text(
            'Discover Exclusive 4K Wallpapers',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const Spacer(),
          Container(
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE500),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'INSTALL / EXPLORE',
              style: TextStyle(
                color: Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
