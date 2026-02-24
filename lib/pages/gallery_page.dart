import 'package:flutter/material.dart';
import '../models/artwork.dart';
import '../services/artwork_service.dart';
import '../pages/pixel_draw_page.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final ArtworkService _artworkService = ArtworkService();
  List<Artwork> _artworks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArtworks();
  }

  Future<void> _loadArtworks() async {
    try {
      final artworks = await _artworkService.loadArtworks();
      setState(() {
        _artworks = artworks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading artworks: $e');
    }
  }

  Color _getColorFromInt(int colorValue) {
    return Color(colorValue);
  }

  Color _getThumbnailColor(Artwork artwork) {
    if (artwork.pixels.isEmpty) {
      return const Color(0xFFFFFFFF);
    }

    List<Color> colors = artwork.pixels
        .take(5)
        .map((value) => _getColorFromInt(value))
        .toList();

    Color bgColor = _getColorFromInt(artwork.backgroundColorValue);
    bool allSameAsBg = colors.every((color) => color.value == bgColor.value);

    if (allSameAsBg) {
      return const Color(0xFFE0E0E0);
    }

    return colors.firstWhere(
      (color) => color.value != bgColor.value,
      orElse: () => colors.first,
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  void _confirmDeleteArtwork(Artwork artwork) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Artwork"),
          content: const Text(
            "Are you sure you want to delete this artwork? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await _artworkService.deleteArtwork(artwork.id);

                setState(() {
                  _artworks.removeWhere((element) => element.id == artwork.id);
                });

                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Artwork deleted successfully!"),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF007AFF)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Gallery',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF007AFF)),
            onPressed: _loadArtworks,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _artworks.isEmpty
            ? _buildEmptyState()
            : RefreshIndicator(
                onRefresh: _loadArtworks,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                    itemCount: _artworks.length,
                    itemBuilder: (context, index) {
                      final artwork = _artworks[index];
                      return _buildArtworkCard(artwork, index);
                    },
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'No artworks yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first pixel art masterpiece!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Create Art',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtworkCard(Artwork artwork, int index) {
    _getThumbnailColor(artwork);

    return GestureDetector(
      onTap: () => _viewArtwork(artwork),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                width: double.infinity,
                color: _getColorFromInt(artwork.backgroundColorValue),
                child: artwork.pixels.isNotEmpty
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          int gridSize = artwork.gridSize;
                          double cellSize = constraints.maxWidth / gridSize;
                          double height = cellSize * gridSize;

                          return SizedBox(
                            width: constraints.maxWidth,
                            height: height,
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: artwork.pixels.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: gridSize,
                                    childAspectRatio: 1,
                                  ),
                              itemBuilder: (context, index) {
                                Color pixelColor = _getColorFromInt(
                                  artwork.pixels[index],
                                );
                                return Container(
                                  decoration: BoxDecoration(
                                    color: pixelColor,
                                    border: Border.all(
                                      color: Colors.black12,
                                      width: 0.5,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artwork.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${artwork.gridSize}x${artwork.gridSize} • ${_formatDate(artwork.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewArtwork(Artwork artwork) {
    Color thumbnailColor = _getThumbnailColor(artwork);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      artwork.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${artwork.gridSize}x${artwork.gridSize}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Created on ${_formatDate(artwork.createdAt)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Center(
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                thumbnailColor,
                                thumbnailColor.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _exportArtworkAsPng(artwork);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF007AFF)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Export',
                              style: TextStyle(
                                color: const Color(0xFF007AFF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _confirmDeleteArtwork(artwork);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PixelDrawPage(
                                    gridSize: artwork.gridSize,
                                    artworkToEdit: artwork,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF007AFF),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Edit',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _exportArtworkAsPng(Artwork artwork) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                Expanded(
                  child: const Text(
                    "Exporting artwork...",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      );

      await Future.delayed(const Duration(milliseconds: 100));

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      final double canvasSize = 500.0;
      final double cellSize = canvasSize / artwork.gridSize;

      final Paint bgPaint = Paint()
        ..color = _getColorFromInt(artwork.backgroundColorValue);
      canvas.drawRect(Rect.fromLTWH(0, 0, canvasSize, canvasSize), bgPaint);

      for (int i = 0; i < artwork.pixels.length; i++) {
        int row = i ~/ artwork.gridSize;
        int col = i % artwork.gridSize;

        final Color pixelColor = _getColorFromInt(artwork.pixels[i]);
        if (pixelColor.alpha > 0) {
          final Paint paint = Paint()..color = pixelColor;
          final Rect rect = Rect.fromLTWH(
            col * cellSize,
            row * cellSize,
            cellSize,
            cellSize,
          );
          canvas.drawRect(rect, paint);
        }
      }

      final Paint gridPaint = Paint()
        ..color = Colors.black12
        ..strokeWidth = 0.5;

      for (int i = 0; i <= artwork.gridSize; i++) {
        canvas.drawLine(
          Offset(i * cellSize, 0),
          Offset(i * cellSize, canvasSize),
          gridPaint,
        );
        canvas.drawLine(
          Offset(0, i * cellSize),
          Offset(canvasSize, i * cellSize),
          gridPaint,
        );
      }

      final ui.Picture picture = recorder.endRecording();
      final ui.Image image = await picture.toImage(
        canvasSize.toInt(),
        canvasSize.toInt(),
      );

      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        throw Exception("Failed to convert image to PNG");
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Save to gallery using gal package
      await Gal.putImageBytes(
        pngBytes,
        name:
            'pixel_art_${artwork.title}_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Artwork exported as PNG successfully! Check your gallery.",
          ),
          backgroundColor: Color(0xFF007AFF),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error exporting artwork: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
