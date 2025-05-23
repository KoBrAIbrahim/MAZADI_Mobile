import 'package:flutter/material.dart';

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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "مرحباً، أحمد",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "عرض الملف الشخصي",
                          style: TextStyle(color: Colors.teal, fontSize: 14),
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
                    title: "الصفحة الرئيسية",
                    isActive: selectedItem == "home",
                    onTap: () {
                      Navigator.pop(context);
                      // يمكنك هنا التنقل إلى الصفحة الرئيسية
                    },
                  ),

                  _buildDrawerItem(
                    icon: Icons.gavel_outlined,
                    title: "المزادات",
                    isActive: selectedItem == "auctions",
                    onTap: () {
                      Navigator.pop(context);
                      // أو التوجيه لصفحة المزادات
                    },
                  ),

                  _buildDrawerItem(
                    icon: Icons.favorite_border_outlined,
                    title: "المزادات المفضلة",
                    isActive: selectedItem == "interested",
                    onTap: () {},
                  ),
                  _buildDrawerItem(
                    icon: Icons.sell_outlined,
                    title: "منشوارتي",
                    isActive: selectedItem == "my auction",
                    onTap: () {},
                  ),
                  _buildDrawerItem(
                    icon: Icons.sell_outlined,
                    title: "مزاداتي",
                    isActive: selectedItem == "my auction",
                    onTap: () {},
                  ),
                  const Divider(),
                 _buildDrawerItem(
                    icon: Icons.settings_outlined,
                    title: "الإعدادات",
                    isActive: selectedItem == "settings",
                    onTap: () {},
                  ),
                  _buildDrawerItem(
                    icon: Icons.support_agent_outlined,
                    title: "الدعم الفني",
                    isActive: selectedItem == "support",
                    onTap: () {},
                  ),
                  _buildDrawerItem(
                    icon: Icons.info_outline,
                    title: "حول التطبيق",
                    isActive: selectedItem == "about us",
                    onTap: () {},
                  ),
                  const Divider(),
                  
                  _buildDrawerItem(
                    icon: Icons.logout,
                    title: "تسجيل الخروج",
                    onTap: () {},
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "تحتاج مساعدة؟",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "تواصل مع فريق الدعم",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
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
