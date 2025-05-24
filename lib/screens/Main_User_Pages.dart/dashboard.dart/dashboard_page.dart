import 'package:application/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

class AuctionDrawer extends StatelessWidget {
  final String selectedItem;

  const AuctionDrawer({super.key, required this.selectedItem});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.teal.shade50,
                    child: const Icon(
                      Icons.person,
                      color: Colors.teal,
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
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
                            style: const TextStyle(
                              color: Colors.teal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    icon: Icons.home_outlined,
                    title: 'drawer_home'.tr(),
                    isActive: selectedItem == "home",
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/home_page', extra: posts);
                    },
                  ),
                  _buildDrawerItem(
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
                    icon: Icons.favorite_border_outlined,
                    title: 'drawer_favorites'.tr(),
                    isActive: selectedItem == "favorites",
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/interested', extra: posts);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.sell_outlined,
                    title: 'drawer_my_posts'.tr(),
                    isActive: selectedItem == "my_posts",
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/my_posts', extra: posts);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.sell_outlined,
                    title: 'drawer_my_auctions'.tr(),
                    isActive: selectedItem == "my_auctions",
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/winners', extra: posts_1);
                    },
                  ),
                  const Divider(),
                  _buildDrawerItem(
                    icon: Icons.settings_outlined,
                    title: 'drawer_settings'.tr(),
                    isActive: selectedItem == "settings",
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/settings');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.support_agent_outlined,
                    title: 'drawer_support'.tr(),
                    isActive: selectedItem == "support",
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/support');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.info_outline,
                    title: 'drawer_about'.tr(),
                    isActive: selectedItem == "about",
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/about_us');
                    },
                  ),
                  const Divider(),
                  _buildDrawerItem(
                    icon: Icons.logout,
                    title: 'drawer_logout'.tr(),
                    onTap: () {
                      context.go('/login');
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.headset_mic, color: Colors.teal),
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'drawer_help_sub'.tr(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.teal,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: isActive ? Colors.teal : Colors.grey.shade700),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.teal : Colors.black,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
      tileColor: isActive ? Colors.teal.withOpacity(0.1) : null,
    );
  }
}
