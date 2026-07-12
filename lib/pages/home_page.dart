import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pixelhu/pages/about_page.dart';
import 'package:pixelhu/pages/gallery_page.dart';
import 'package:pixelhu/pages/grid_size_page.dart';
import 'package:pixelhu/services/admob_service.dart';
import 'package:pixelhu/widgets/menu_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    final bannerAd = AdMobService().createBannerAd();
    if (bannerAd != null) {
      _bannerAd = bannerAd;
      bannerAd.load().then((_) {
        setState(() {
          _isBannerAdReady = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PixelHu',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create beautiful pixel art',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Banner Ad (between description and buttons)
              if (_isBannerAdReady && _bannerAd != null)
                Container(
                  alignment: Alignment.center,
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  child: AdWidget(ad: _bannerAd!),
                ),

              // Menu buttons
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MenuButton(
                      name: "New Project",
                      icon: Icons.add_rounded,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GridSizePage(),
                          ),
                        );
                      },
                    ),
                    MenuButton(
                      name: "My Gallery",
                      icon: Icons.photo_library_rounded,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GalleryPage(),
                          ),
                        );
                      },
                    ),
                    MenuButton(
                      name: "About Us",
                      icon: Icons.info_rounded,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AboutPage(),
                          ),
                        );
                      },
                    ),
                    MenuButton(
                      name: "Exit",
                      icon: Icons.exit_to_app_rounded,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text("Exit App"),
                            content: const Text(
                              "Are you sure you want to exit PixelHu?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  exit(0);
                                },
                                child: const Text(
                                  "Exit",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Footer
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Made with ❤️ for pixel artists',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
