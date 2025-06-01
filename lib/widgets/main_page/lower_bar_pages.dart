import 'package:application/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

class LowerBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const LowerBar({Key? key, required this.currentIndex, required this.onTap})
      : super(key: key);

  void _handleTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home_page');
        break;
      case 1:
        context.go('/main_auction');
        break;
      case 2:
        context.go('/interested');
        break;
      case 3:
        context.go('/my_posts');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface
,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _handleTap(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.unselectedWidgetColor,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: 'navbar.home'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.gavel_outlined),
            activeIcon: const Icon(Icons.gavel),
            label: 'navbar.auctions'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_outline),
            activeIcon: const Icon(Icons.favorite),
            label: 'navbar.favorites'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.sell_outlined),
            activeIcon: const Icon(Icons.sell),
            label: 'navbar.my_posts'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: 'navbar.my_account'.tr(),
          ),
        ],
      ),
    );
  }
}
