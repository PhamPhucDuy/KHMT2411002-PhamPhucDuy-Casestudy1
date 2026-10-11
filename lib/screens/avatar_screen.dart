import 'dart:io';
import 'package:flutter/material.dart';

/// Chữ cái đầu của tên (lấy từ từ cuối cùng), dùng khi chưa có ảnh đại diện.
String nameInitial(String name) {
  final parts =
  name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  return parts.isEmpty ? '' : parts.last[0].toUpperCase();
}

/// Ảnh đại diện: hiện ảnh từ file nếu có, nếu không hiện chữ cái đầu / icon.
class UserAvatar extends StatelessWidget {
  final double radius;
  final String? imagePath;
  final String initial;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const UserAvatar({
    super.key,
    this.radius = 20,
    this.imagePath,
    this.initial = '',
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final fg = foregroundColor ?? const Color(0xFF1565C0);
    final path = imagePath;
    final file = (path != null && path.isNotEmpty) ? File(path) : null;
    final hasImage = file != null && file.existsSync();

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? const Color(0xFFE3F2FD),
      backgroundImage: hasImage ? FileImage(file) : null,
      child: hasImage
          ? null
          : (initial.isEmpty
          ? Icon(Icons.person, size: radius * 1.1, color: fg)
          : Text(initial,
          style: TextStyle(
              fontSize: radius * 0.9,
              fontWeight: FontWeight.bold,
              color: fg))),
    );
  }
}
