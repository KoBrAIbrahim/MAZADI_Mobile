import 'package:application/screens/Main_User_Pages.dart/Posts/add_post.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AddNewPostBar extends StatelessWidget {
  const AddNewPostBar({super.key});

  void _openModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 4 / 5,
          widthFactor: 1.0,
          child: const AddPostPage(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade300, width: 1.2),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                const SizedBox(width: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 90),
                    child: GestureDetector(
                      onTap: () => _openModal(context),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'add_new_post'.tr(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                child: SizedBox(
                  width: 80,
                  height: 40,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 120,
                          height: double.infinity,
                          child: CustomPaint(
                            painter: BottomShapePainterFlipped(),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 150,
                          height: double.infinity,
                          child: CustomPaint(painter: TopShapePainterFlipped()),
                        ),
                      ),
                      Positioned(
                        right: 11,
                        top: 6,
                        child: GestureDetector(
                          onTap: () => _openModal(context),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomShapePainterFlipped extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color.fromARGB(255, 129, 236, 204);
    final path =
        Path()
          ..moveTo(size.width, size.height)
          ..lineTo(size.width * 0.5, size.height)
          ..lineTo(0, 0)
          ..lineTo(size.width, 0)
          ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TopShapePainterFlipped extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF8BD6D0).withOpacity(0.6);
    final path =
        Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(0, size.height)
          ..lineTo(size.width, size.height)
          ..lineTo(size.width, 0)
          ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
