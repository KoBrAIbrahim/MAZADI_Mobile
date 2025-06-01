import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive/hive.dart';

class CategoryCarousel extends StatefulWidget {
  final ValueChanged<String> onCategoryChanged;

  const CategoryCarousel({super.key, required this.onCategoryChanged});

  @override
  State<CategoryCarousel> createState() => _CategoryCarouselState();
}

class _CategoryCarouselState extends State<CategoryCarousel> {
  late List<Map<String, String>> categories;

  final List<String> images = [
    'assets/icons/all.png',
    'assets/icons/electronics.png',
    'assets/icons/brand.png',
    'assets/icons/furniture.png',
    'assets/icons/home.png',
    'assets/icons/sports.png',
    'assets/icons/car2.png',
    'assets/icons/porcelain.png',
    'assets/icons/other.png',
  ];

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeCategories();
    _loadSavedCategoryIndex();
  }

  void _initializeCategories() {
    categories = [
      {'key': 'ALL', 'label': 'category_all'.tr()},
      {'key': 'ELECTRONICS', 'label': 'category_electronics'.tr()},
      {'key': 'FASHION', 'label': 'category_fashion'.tr()},
      {'key': 'FURNITURE', 'label': 'category_furniture'.tr()},
      {'key': 'HOME', 'label': 'category_home'.tr()},
      {'key': 'SPORTS', 'label': 'category_sports'.tr()},
      {'key': 'CARS', 'label': 'category_cars'.tr()},
      {'key': 'HANDMADE', 'label': 'category_handmade'.tr()},
      {'key': 'OTHER', 'label': 'category_other'.tr()},
    ];
  }

  void _loadSavedCategoryIndex() async {
    final box = Hive.box('settings');
    final savedIndex = box.get('selected_category_index', defaultValue: 0);
    setState(() => selectedIndex = savedIndex);

    if (categories.isNotEmpty) {
      final selectedKey = categories[savedIndex]['key']!;
      widget.onCategoryChanged(selectedKey);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      _initializeCategories(); // لإعادة الترجمة عند تغيير اللغة
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
          final label = categories[index]['label']!;
          final key = categories[index]['key']!;

          return Tooltip(
            message: label,
            waitDuration: const Duration(milliseconds: 400),
            child: GestureDetector(
              onTap: () async {
                setState(() => selectedIndex = index);

                final box = Hive.box('settings');
                box.put('selected_category_index', index);

                widget.onCategoryChanged(key);
              },
              child: Column(
                children: [
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
                  Text(
                    label,
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