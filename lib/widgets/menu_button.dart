// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final String Name;
  final Color TextColor;
  final VoidCallback Tapped;
  const MenuButton({
    super.key,
    required this.Name,
    required this.TextColor,
    required this.Tapped,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: Tapped,
      child: Text(Name, style: TextStyle(color: TextColor)),
    );
  }
}
