import 'package:application/constants/app_colors.dart';
import 'package:application/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

class AuctionDrawer extends StatelessWidget {
  final String selectedItem;

  const AuctionDrawer({super.key, required this.selectedItem});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      backgroundColor: AppColors.drawerBackground(context),
      child: SafeArea(
        child: Column(
          children: [
            _buildUserHeader(context),
            Divider(color: AppColors.divider(context)),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.home_outlined,
                    title: 'drawer_home'.tr(),
                    isActive: selectedItem == "home",
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/home_page', extra: posts);
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.gavel_outlined,
                    title: 'drawer_auctions'.tr(),
                    isActive: selectedItem == "auctions",
                    onTap: () {
                      Navigator.pop(context);
                      context.go(
                        '/main_auction',
                        extra: {
                          'auction': auctions,
                          'posts': posts,
                          'bids': bids,
                        },
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.favorite_border_outlined,
                    title: 'drawer_favorites'.tr(),
                    isActive: selectedItem == "favorites",
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/interested', extra: posts);
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.sell_outlined,
                    title: 'drawer_my_posts'.tr(),
                    isActive: selectedItem == "my_posts",
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/my_posts', extra: posts);
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.sell_outlined,
                    title: 'drawer_my_auctions'.tr(),
                    isActive: selectedItem == "my_auctions",
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/winners', extra: posts_1);
                    },
                  ),
                  Divider(color: AppColors.divider(context)),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.settings_outlined,
                    title: 'drawer_settings'.tr(),
                    isActive: selectedItem == "settings",
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/settings');
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.support_agent_outlined,
                    title: 'drawer_support'.tr(),
                    isActive: selectedItem == "support",
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/support');
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.info_outline,
                    title: 'drawer_about'.tr(),
                    isActive: selectedItem == "about",
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/about_us');
                    },
                  ),
                  Divider(color: AppColors.divider(context)),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.logout,
                    title: 'drawer_logout'.tr(),
                    onTap: () {
                      context.go('/login');
                    },
                  ),
                ],
              ),
            ),
            _buildHelpSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.lightBackground(context),
            child: Icon(
              Icons.person,
              color: AppColors.primaryLightDark(context),
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${'welcome'.tr()}, أحمد',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/profile', extra: testUser);
                  },
                  child: Text(
                    'drawer_profile'.tr(),
                    style: TextStyle(
                      color: AppColors.primaryLightDark(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightBackground(context),
        borderRadius: BorderRadius.circular(12),
        border:
            isDark
                ? Border.all(
                  color: AppColors.primaryLightDark(context).withOpacity(0.3),
                  width: 1,
                )
                : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.cardBackground(context),
              borderRadius: BorderRadius.circular(8),
              boxShadow:
                  isDark
                      ? null
                      : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
            ),
            child: Icon(
              Icons.headset_mic,
              color: AppColors.primaryLightDark(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                context.go('/support');
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'drawer_help_title'.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'drawer_help_sub'.tr(),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.primaryLightDark(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isActive ? AppColors.lightBackground(context) : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color:
              isActive
                  ? AppColors.primaryLightDark(context)
                  : AppColors.inactiveIcon(context),
        ),
        title: Text(
          title,
          style: TextStyle(
            color:
                isActive
                    ? AppColors.primaryLightDark(context)
                    : AppColors.textPrimary(context),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
