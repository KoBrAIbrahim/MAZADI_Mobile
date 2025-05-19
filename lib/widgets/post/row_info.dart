import 'package:flutter/material.dart';

Widget infoRow(IconData icon, String text, Color color) {
  return Row(
    children: [
      Icon(icon, size: 18, color: color),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    ],
  );
}
