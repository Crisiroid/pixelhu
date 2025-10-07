import 'package:flutter/material.dart';
import 'package:pixelhu/pages/pixel_draw_page.dart';

class GridSizePage extends StatefulWidget {
  const GridSizePage({super.key});

  @override
  State<GridSizePage> createState() => _GridSizePageState();
}

class _GridSizePageState extends State<GridSizePage> {
  int gridSize = 16;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Select Grid Size'),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Choose your canvas size:',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 20),
          Slider(
            value: gridSize.toDouble(),
            min: 8,
            max: 64,
            divisions: 7,
            activeColor: Colors.purple,
            label: '$gridSize x $gridSize',
            onChanged: (value) {
              setState(() {
                gridSize = value.toInt();
              });
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PixelDrawPage(gridSize: gridSize),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: Text('Start ($gridSize x $gridSize)'),
          ),
        ],
      ),
    );
  }
}
