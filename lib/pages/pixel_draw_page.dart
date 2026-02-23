import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/artwork.dart';
import '../services/artwork_service.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/rendering.dart';

class PixelDrawPage extends StatefulWidget {
  final int gridSize;
  final Artwork? artworkToEdit;
  const PixelDrawPage({super.key, required this.gridSize, this.artworkToEdit});

  @override
  State<PixelDrawPage> createState() => _PixelDrawPageState();
}

class _PixelDrawPageState extends State<PixelDrawPage> {
  late List<Color> pixels;
  Color currentColor = const Color(0xFF007AFF);
  bool isErasing = false;
  List<Color> recentColors = [];
  double _zoom = 1.0;
  bool _showGridLines = true;

  Color backgroundColor = Colors.white;

  final ArtworkService _artworkService = ArtworkService();

  final GlobalKey gridKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    if (widget.artworkToEdit != null) {
      Artwork artwork = widget.artworkToEdit!;
      backgroundColor = Color(artwork.backgroundColorValue);
      pixels = artwork.pixels.map((colorValue) => Color(colorValue)).toList();

      if (pixels.length < widget.gridSize * widget.gridSize) {
        while (pixels.length < widget.gridSize * widget.gridSize) {
          pixels.add(backgroundColor);
        }
      } else if (pixels.length > widget.gridSize * widget.gridSize) {
        pixels = pixels.sublist(0, widget.gridSize * widget.gridSize);
      }
    } else {
      pixels = List.generate(
        widget.gridSize * widget.gridSize,
        (_) => backgroundColor,
      );
    }
  }

  void _addToRecentColors(Color color) {
    setState(() {
      recentColors.remove(color);
      recentColors.insert(0, color);
      if (recentColors.length > 6) {
        recentColors = recentColors.sublist(0, 6);
      }
    });
  }

  Future<Color?> _showColorPicker(Color startColor, String title) async {
    Color tempColor = startColor;

    return await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(title, style: TextStyle(color: Colors.grey.shade900)),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: ColorPicker(
                pickerColor: tempColor,
                onColorChanged: (color) {
                  setState(() {
                    tempColor = color;
                  });
                },
                labelTypes: const [],
                pickerAreaHeightPercent: 0.8,
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, tempColor),
            child: Text(
              'Select',
              style: const TextStyle(color: Color(0xFF007AFF)),
            ),
          ),
        ],
      ),
    );
  }

  void _pickBrushColor() async {
    final picked = await _showColorPicker(currentColor, 'Pick Brush Color');
    if (picked != null) {
      setState(() {
        currentColor = picked;
        _addToRecentColors(picked);
      });
    }
  }

  void _pickBackgroundColor() async {
    final picked = await _showColorPicker(
      backgroundColor,
      'Pick Background Color',
    );
    if (picked != null) {
      setState(() {
        backgroundColor = picked;
        for (int i = 0; i < pixels.length; i++) {
          if (pixels[i] == Colors.white || pixels[i] == backgroundColor) {
            pixels[i] = backgroundColor;
          }
        }
      });
    }
  }

  void _zoomIn() {
    setState(() {
      _zoom = (_zoom + 0.2).clamp(0.5, 3.0);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoom = (_zoom - 0.2).clamp(0.5, 3.0);
    });
  }

  void _toggleEraser() {
    setState(() {
      isErasing = !isErasing;
    });
  }

  void _toggleGridLines() {
    setState(() {
      _showGridLines = !_showGridLines;
    });
  }

  Future<void> _saveArtwork() async {
    try {
      List<int> pixelValues = pixels.map((color) => color.value).toList();

      String? title = await _promptForTitle(
        context,
        widget.artworkToEdit?.title ??
            "Artwork ${DateTime.now().day}${DateTime.now().month}${DateTime.now().year}",
      );
      if (title == null || title.trim().isEmpty) {
        return;
      }

      Artwork artwork;
      if (widget.artworkToEdit != null) {
        artwork = Artwork(
          id: widget.artworkToEdit!.id,
          title: title,
          createdAt: widget.artworkToEdit!.createdAt,
          gridSize: widget.gridSize,
          pixels: pixelValues,
          backgroundColorValue: backgroundColor.value,
        );
      } else {
        int nextId = await _artworkService.getNextId();
        artwork = Artwork(
          id: nextId,
          title: title,
          createdAt: DateTime.now(),
          gridSize: widget.gridSize,
          pixels: pixelValues,
          backgroundColorValue: backgroundColor.value,
        );
      }

      await _artworkService.addArtwork(artwork);

      Navigator.of(context).pop();
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Artwork saved successfully!"),
          backgroundColor: const Color(0xFF007AFF),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving artwork: \$e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _promptForTitle(
    BuildContext context,
    String initialTitle,
  ) async {
    TextEditingController controller = TextEditingController(
      text: initialTitle,
    );

    return showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Save Artwork"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Enter artwork name",
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  DateTime _lastDrawTime = DateTime.now();

  void _handleDraw(int index) {
    final now = DateTime.now();
    if (now.difference(_lastDrawTime).inMilliseconds > 16) {
      setState(() {
        pixels[index] = isErasing ? backgroundColor : currentColor;
        _lastDrawTime = now;
      });
      _addToRecentColors(isErasing ? backgroundColor : currentColor);
    }
  }

  Future<void> _exportArtworkAsPng() async {
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
                Text("Exporting artwork as PNG..."),
              ],
            ),
          );
        },
      );

      await Future.delayed(const Duration(milliseconds: 100));

      RenderRepaintBoundary boundary =
          gridKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      Directory appDir = await getApplicationDocumentsDirectory();
      String fileName =
          'pixel_art_${DateTime.now().millisecondsSinceEpoch}.png';
      String filePath = path.join(appDir.path, fileName);

      await File(filePath).writeAsBytes(pngBytes);

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Artwork exported as PNG successfully! File saved to: \$fileName",
          ),
          backgroundColor: const Color(0xFF007AFF),
        ),
      );
    } catch (e) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error exporting artwork: \$e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gridCount = widget.gridSize;
    final pixelSize = (MediaQuery.of(context).size.width - 40) / gridCount;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF007AFF)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Pixel Editor',
          style: TextStyle(color: Colors.grey.shade800),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isErasing ? Icons.brush : Icons.highlight_off_outlined,
              color: isErasing ? const Color(0xFF007AFF) : Colors.grey,
            ),
            tooltip: isErasing ? "Switch to Brush" : "Switch to Eraser",
            onPressed: _toggleEraser,
          ),
          IconButton(
            icon: const Icon(Icons.save, color: Color(0xFF007AFF)),
            tooltip: "Save Artwork",
            onPressed: _saveArtwork,
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
            onSelected: (String result) {
              if (result == 'brush') {
                _pickBrushColor();
              } else if (result == 'background') {
                _pickBackgroundColor();
              } else if (result == 'export') {
                _exportArtworkAsPng();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'brush',
                child: ListTile(
                  leading: Icon(Icons.color_lens, color: Color(0xFF007AFF)),
                  title: Text('Change Brush Color'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'background',
                child: ListTile(
                  leading: Icon(
                    Icons.format_color_fill,
                    color: Color(0xFF007AFF),
                  ),
                  title: Text('Change Background'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.image, color: Color(0xFF007AFF)),
                  title: Text('Export as PNG'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
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
              child: Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 5.0,
                  scaleEnabled: true,
                  panEnabled: true,
                  child: Transform.scale(
                    scale: _zoom,
                    child: SizedBox(
                      width: pixelSize * gridCount,
                      height: pixelSize * gridCount,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridCount,
                        ),
                        itemCount: pixels.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              _handleDraw(index);
                            },
                            onPanUpdate: (_) {
                              _handleDraw(index);
                            },
                            child: Container(
                              color: pixels[index],
                              margin: const EdgeInsets.all(0.5),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (recentColors.isNotEmpty)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                children: [
                  Text(
                    "Recent Colors",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: recentColors.length,
                      itemBuilder: (context, index) {
                        final color = recentColors[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              currentColor = color;
                              isErasing = false;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: color == currentColor
                                    ? const Color(0xFF007AFF)
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "zoom_in",
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF007AFF),
            onPressed: _zoomIn,
            child: const Icon(Icons.zoom_in),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: "zoom_out",
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF007AFF),
            onPressed: _zoomOut,
            child: const Icon(Icons.zoom_out),
          ),
        ],
      ),
    );
  }
}
