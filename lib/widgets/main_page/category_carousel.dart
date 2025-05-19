import 'package:flutter/material.dart';

class CategoryCarousel extends StatefulWidget {
  const CategoryCarousel({super.key});

  @override
  State<CategoryCarousel> createState() => _CategoryCarouselState();
}

class _CategoryCarouselState extends State<CategoryCarousel> {
  final List<String> categories = [
    'الكل',
    'الكترونيات',
    'سيارات',
    'عقارات',
    'أثاث',
    'ملابس',
    'اخرى',
  ];

  final List<String> images = [
    'assets/icons/all.png',
    'assets/icons/electronics.png',
    'assets/icons/car2.png',
    'assets/icons/home.png',
    'assets/icons/furniture.png',
    'assets/icons/clothes.png',
    'assets/icons/other.png',
  ];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;

          return Tooltip(
            message: categories[index], // ⬅️ النص اللي يظهر عند الضغط المطوّل
            waitDuration: const Duration(milliseconds: 400),
            child: GestureDetector(
              onTap: () {
                setState(() => selectedIndex = index);
              },
              child: Column(
                children: [
                  // ✅ خط علوي صغير ملوّن عند التحديد
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.teal : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // ✅ أيقونة دائرية مع ظل خفيف
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.teal : Colors.white,
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        else
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage(images[index]),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // ✅ النص
                  Text(
                    categories[index],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.teal : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
