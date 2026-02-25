import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  // Test ad unit IDs - Replace with your actual ad unit IDs for production
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      // Use test ad unit ID for Android
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      // Use test ad unit ID for iOS
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    throw UnsupportedError('Unsupported platform');
  }

  InterstitialAd? _interstitialAd;
  bool _isAdLoading = false;

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
}
