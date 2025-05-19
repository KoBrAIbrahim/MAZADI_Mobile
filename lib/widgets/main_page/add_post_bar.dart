import 'package:application/screens/Main_User_Pages.dart/Posts/add_post.dart';
import 'package:application/widgets/main_page/search_bar.dart';
import 'package:flutter/material.dart';

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
          child: AddPostPage(), 
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
        child: Row(
          children: [
            const SizedBox(width: 20),
            Expanded(
              child: GestureDetector(
                onTap: () => _openModal(context),
                child: const Text(
                  "Add new Post",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: SizedBox(
                width: 80,
                height: double.infinity,
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
                        child: CustomPaint(
                          painter: TopShapePainterFlipped(),
                        ),
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
          ],
        ),
      ),
    );
  }
}
