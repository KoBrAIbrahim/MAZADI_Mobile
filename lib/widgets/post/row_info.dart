import 'package:flutter/material.dart';

Widget infoRow(BuildContext context, IconData icon, String text, Color color) {
  return Row(
    children: [
      Icon(icon, size: 18, color: color),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyMedium?.color, // ✅ ديناميكي
          ),
        ),
      ),
    ],
  );
}
