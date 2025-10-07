import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class PixelDrawPage extends StatefulWidget {
  final int gridSize;
  const PixelDrawPage({super.key, required this.gridSize});

  @override
  State<PixelDrawPage> createState() => _PixelDrawPageState();
}

class _PixelDrawPageState extends State<PixelDrawPage> {
  late List<Color> pixels;
  Color currentColor = Colors.black;
  bool isErasing = false;
  List<Color> recentColors = [];
  double _zoom = 1.0;

  // New: Background color
  Color backgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();
    pixels = List.generate(
      widget.gridSize * widget.gridSize,
      (_) => backgroundColor,
    );
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
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: startColor,
            onColorChanged: (color) => tempColor = color,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, tempColor),
            child: const Text(
              'Select',
              style: TextStyle(color: Colors.purpleAccent),
            ),
          ),
        ],
      ),
    );
    return tempColor;
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

  @override
  Widget build(BuildContext context) {
    final gridCount = widget.gridSize;
    final pixelSize = MediaQuery.of(context).size.width / gridCount;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens, color: Colors.black),
            tooltip: "Pick Brush Color",
            onPressed: _pickBrushColor,
          ),
          IconButton(
            icon: const Icon(Icons.format_color_fill, color: Colors.black),
            tooltip: "Pick Background Color",
            onPressed: _pickBackgroundColor,
          ),
          IconButton(
            icon: Icon(
              isErasing ? Icons.brush : Icons.remove_circle_outline,
              color: Colors.black,
            ),
            tooltip: isErasing ? "Switch to Brush" : "Switch to Eraser",
            onPressed: () => setState(() => isErasing = !isErasing),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in, color: Colors.black),
            tooltip: "Zoom In",
            onPressed: _zoomIn,
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out, color: Colors.black),
            tooltip: "Zoom Out",
            onPressed: _zoomOut,
          ),
        ],
      ),
      body: Column(
        children: [
          // Drawing Grid
          Expanded(
            child: Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
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
                          onPanUpdate: (_) {
                            setState(() {
                              pixels[index] = isErasing
                                  ? backgroundColor
                                  : currentColor;
                            });
                          },
                          onTap: () {
                            setState(() {
                              pixels[index] = isErasing
                                  ? backgroundColor
                                  : currentColor;
                            });
                          },
                          child: Container(
                            color: pixels[index],
                            margin: const EdgeInsets.all(0.2),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Recent Colors Section
          if (recentColors.isNotEmpty)
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  const Text(
                    "Recent Colors",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
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
                                    ? Colors.purpleAccent
                                    : Colors.white24,
                                width: 2,
                              ),
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
    );
  }
}
