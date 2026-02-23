// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final String name;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final VoidCallback onTap;
  final double? width;

  const MenuButton({
    super.key,
    required this.name,
    this.backgroundColor = const Color(0xFFF2F2F7), // iOS light gray
    this.textColor = const Color(0xFF007AFF), // iOS blue
    this.icon,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: textColor, size: 24),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    name,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios, color: textColor, size: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
