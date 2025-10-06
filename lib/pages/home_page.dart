import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pixelhu/pages/about_page.dart';
import 'package:pixelhu/widgets/menu_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MenuButton(
              Name: "New Project",
              TextColor: Colors.purple,
              Tapped: () {},
            ),
            MenuButton(
              Name: "My Gallary",
              TextColor: const Color.fromARGB(255, 103, 39, 176),
              Tapped: () {},
            ),
            MenuButton(
              Name: "About Us",
              TextColor: const Color.fromARGB(255, 55, 39, 176),
              Tapped: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutPage()),
                );
              },
            ),
            MenuButton(
              Name: "Exit",
              TextColor: const Color.fromARGB(255, 39, 117, 176),
              Tapped: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Center(child: Text("Bye Bye!")),
                    backgroundColor: Colors.black,
                    elevation: 5,
                    duration: Duration(seconds: 2),
                  ),
                );

                Future.delayed(const Duration(seconds: 3), () {
                  exit(0);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
