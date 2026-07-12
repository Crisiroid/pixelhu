import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  // Set to false for production, true for testing
  static const bool useTestAds = true;

  // App IDs
  static String get appId {
    if (useTestAds) {
      return 'ca-app-pub-3940256099942544~3347511341';
    }
    if (Platform.isAndroid) {
      return 'pixelhuca-app-pub-1390593909444402~8075232456';
    } else if (Platform.isIOS) {
      return 'pixelhuca-app-pub-1390593909444402~8075232456';
    }
    throw UnsupportedError('Unsupported platform');
  }

  // Interstitial Ad Unit IDs
  static String get interstitialAdUnitId {
    if (useTestAds) {
      return 'ca-app-pub-3940256099942544/1033173712';
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-1390593909444402/1033173712';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-1390593909444402/1033173712';
    }
    throw UnsupportedError('Unsupported platform');
  }

  // Rewarded Ad Unit IDs (Save_Art_Ad)
  static String get rewardedAdUnitId {
    if (useTestAds) {
      return 'ca-app-pub-3940256099942544/5224354917';
    }
    if (Platform.isAndroid) {
      return 'pixelhuca-app-pub-1390593909444402/3328462377';
    } else if (Platform.isIOS) {
      return 'pixelhuca-app-pub-1390593909444402/3328462377';
    }
    throw UnsupportedError('Unsupported platform');
  }

  // Banner Ad Unit IDs (Home_Top_Ad)
  static String get bannerAdUnitId {
    if (useTestAds) {
      return 'ca-app-pub-3940256099942544/6300978111';
    }
    if (Platform.isAndroid) {
      return 'pixelhuca-app-pub-1390593909444402/3488244470';
    } else if (Platform.isIOS) {
      return 'pixelhuca-app-pub-1390593909444402/3488244470';
    }
    throw UnsupportedError('Unsupported platform');
  }

  // Native Ad Unit IDs (Gallary_Top_Ad)
  static String get nativeAdUnitId {
    if (useTestAds) {
      return 'ca-app-pub-3940256099942544/2247696110';
    }
    if (Platform.isAndroid) {
      return 'pixelhuca-app-pub-1390593909444402/6706310466';
    } else if (Platform.isIOS) {
      return 'pixelhuca-app-pub-1390593909444402/6706310466';
    }
    throw UnsupportedError('Unsupported platform');
  }

  InterstitialAd? _interstitialAd;
  bool _isAdLoading = false;

  // Rewarded Ad
  RewardedAd? _rewardedAd;
  bool _isRewardedLoading = false;

  // Banner Ad
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  // Native Ad
  NativeAd? _nativeAd;
  bool _isNativeLoaded = false;

  /// Initialize the Mobile Ads SDK
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  /// Load an interstitial ad
  Future<void> loadInterstitialAd() async {
    if (_isAdLoading || _interstitialAd != null) return;

    _isAdLoading = true;

    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isAdLoading = false;

          // Set up full screen content callbacks
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
              _interstitialAd = null;
              // Preload next ad
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent:
                (InterstitialAd ad, AdError error) {
                  ad.dispose();
                  _interstitialAd = null;
                },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isAdLoading = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  /// Show the loaded interstitial ad
  /// Returns true if ad was shown, false otherwise
  Future<bool> showInterstitialAd() async {
    if (_interstitialAd != null) {
      await _interstitialAd!.show();
      return true;
    }
    // If no ad is loaded, try to load one for next time
    loadInterstitialAd();
    return false;
  }

  /// Show interstitial ad with a callback after ad is dismissed
  /// If no ad is available, the callback is called immediately
  Future<void> showInterstitialAdWithCallback({
    required VoidCallback onAdDismissed,
  }) async {
    if (_interstitialAd != null) {
      // Set up callback for when ad is dismissed
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _interstitialAd = null;
          onAdDismissed();
          // Preload next ad
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          _interstitialAd = null;
          onAdDismissed();
        },
      );
      await _interstitialAd!.show();
    } else {
      // No ad available, execute callback immediately
      onAdDismissed();
      // Try to load next ad
      loadInterstitialAd();
    }
  }

  /// Dispose the current ad
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }

  // ==================== REWARDED AD METHODS ====================

  /// Load a rewarded ad
  Future<void> loadRewardedAd() async {
    if (_isRewardedLoading || _rewardedAd != null) return;

    _isRewardedLoading = true;

    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;

          // Set up full screen content callbacks
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (RewardedAd ad) {
              ad.dispose();
              _rewardedAd = null;
              // Preload next ad
              loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
              ad.dispose();
              _rewardedAd = null;
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isRewardedLoading = false;
          _rewardedAd = null;
        },
      ),
    );
  }

  /// Show a rewarded ad and return true if user earned the reward
  /// Returns false if ad failed to show or user didn't complete
  Future<bool> showRewardedAd() async {
    if (_rewardedAd != null) {
      bool earnedReward = false;

      // Set up reward callback
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          ad.dispose();
          _rewardedAd = null;
          // Preload next ad
          loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          ad.dispose();
          _rewardedAd = null;
          // Preload next ad
          loadRewardedAd();
        },
      );

      // Set reward callback
      _rewardedAd!.setImmersiveMode(true);
      await _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          earnedReward = true;
        },
      );

      return earnedReward;
    } else {
      // No ad available, try to load one for next time
      loadRewardedAd();
      // Return true to allow operation to proceed (graceful degradation)
      return true;
    }
  }

  // ==================== BANNER AD METHODS ====================

  /// Create and load a banner ad
  BannerAd? createBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerLoaded = false;
          ad.dispose();
        },
      ),
    )..load();

    return _bannerAd;
  }

  /// Get banner ad loaded status
  bool get isBannerLoaded => _isBannerLoaded;

  // ==================== NATIVE AD METHODS ====================

  /// Create and load a native ad
  NativeAd? createNativeAd() {
    _nativeAd = NativeAd(
      adUnitId: nativeAdUnitId,
      factoryId: 'adFactoryExample',
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: Colors.white,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: const Color(0xFF007AFF),
          style: NativeTemplateFontStyle.monospace,
          size: 14.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black87,
          backgroundColor: Colors.white,
          style: NativeTemplateFontStyle.normal,
          size: 14.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black54,
          backgroundColor: Colors.white,
          style: NativeTemplateFontStyle.normal,
          size: 12.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black54,
          backgroundColor: Colors.white,
          style: NativeTemplateFontStyle.normal,
          size: 12.0,
        ),
      ),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _isNativeLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          _isNativeLoaded = false;
          ad.dispose();
        },
      ),
    )..load();

    return _nativeAd;
  }

  /// Get native ad loaded status
  bool get isNativeLoaded => _isNativeLoaded;

  /// Dispose all ads
  void disposeAll() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _bannerAd?.dispose();
    _bannerAd = null;
    _nativeAd?.dispose();
    _nativeAd = null;
  }
}
