import 'package:flutter/material.dart';

class LowerBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const LowerBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    List<BottomNavigationBarItem> navItems = [
      _buildImageBarItem('assets/icon_bar/home.png', 'Home', 0),
      _buildImageBarItem('assets/icon_bar/auction.png', 'Auction', 1),
      _buildImageBarItem('assets/icon_bar/save.png', 'Save', 2),
      _buildImageBarItem('assets/icon_bar/setting.png', 'Settings', 3),
      _buildImageBarItem('assets/icon_bar/profile.png', 'Profile', 4),
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.125,
      color: Colors.white,
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: currentIndex,
        onTap: onTap,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: navItems,
      ),
    );
  }

  BottomNavigationBarItem _buildImageBarItem(
    String imagePath,
    String label,
    int index,
  ) {
    final bool isSelected = index == currentIndex;

    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isSelected ? 50 : 40, // تكبير الدائرة عند التحديد
            height: isSelected ? 50 : 40,
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? Colors.teal.withOpacity(0.15)
                      : Colors.transparent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Image.asset(imagePath, width: 33, height: 33),
          ),
          const SizedBox(height: 4),
          // النقطة السفلية: Slide + Scale + Fade
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: isSelected ? 1.0 : 0.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 6 * (1 - value)), // انزلاق لأعلى
                child: Transform.scale(
                  scale: value, // تكبير
                  child: Opacity(
                    opacity: value, // تلاشي
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.teal,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      label: '',
    );
  }
}
