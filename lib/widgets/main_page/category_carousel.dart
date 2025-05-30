import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CategoryCarousel extends StatefulWidget {
  const CategoryCarousel({super.key});

  @override
  State<CategoryCarousel> createState() => _CategoryCarouselState();
}

class _CategoryCarouselState extends State<CategoryCarousel> {
  List<String> categories = [];

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
  void initState() {
    super.initState();
    _initializeCategories();
  }

  void _initializeCategories() {
    categories = [
      'category_all'.tr(),
      'category_electronics'.tr(),
      'category_cars'.tr(),
      'category_real_estate'.tr(),
      'category_furniture'.tr(),
      'category_clothes'.tr(),
      'category_others'.tr(),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      _initializeCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;

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
            message: categories[index],
            waitDuration: const Duration(milliseconds: 400),
            child: GestureDetector(
              onTap: () {
                setState(() => selectedIndex = index);
              },
              child: Column(
                children: [
                  // الخط العلوي
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // الدائرة
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? primaryColor : cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? primaryColor.withOpacity(0.3)
                              : Colors.black26,
                          blurRadius: isSelected ? 8 : 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: cardColor,
                      backgroundImage: AssetImage(images[index]),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // النص
                  Text(
                    categories[index],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? primaryColor : textColor,
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
