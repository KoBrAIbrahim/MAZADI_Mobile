import 'package:application/screens/Main_User_Pages.dart/filter/filter_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isRTL = context.locale.languageCode == 'ar';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: theme.cardColor, // ← ديناميكي حسب الثيم
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey.shade300,
                  width: 1.2,
                ),
              ),
              child: Stack(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(left: 4),
                            hintText: "search.hint".tr(),
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ClipRRect(
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
                            const Positioned(
                              right: 13,
                              top: 11,
                              child: Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 26,
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
          ),

          const SizedBox(width: 6),

          IconButton(
            icon: Image.asset(
              'assets/icons/filter.png',
              width: MediaQuery.of(context).size.width * 0.17,
              height: MediaQuery.of(context).size.height * 0.068,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: theme.scaffoldBackgroundColor, // ← دعم الوضع الليلي
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => const FractionallySizedBox(
                  heightFactor: 0.30,
                  widthFactor: 1.0,
                  child: FilterPage(),
                ),
              );
            },
            splashRadius: 10,
            tooltip: 'search.filter'.tr(),
          ),
        ],
      ),
    );
  }
}



// 🔁 الفاتح (السفلي) – من أسفل يمين ↗ إلى أعلى يسار
class BottomShapePainterFlipped extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color.fromARGB(255, 129, 236, 204);

    final path = Path();

    path.moveTo(size.width, size.height); // الزاوية السفلية اليمنى
    path.lineTo(size.width * 0.5, size.height); // منتصف الحافة السفلية
    path.lineTo(0, 0); // الزاوية العلوية اليسرى
    path.lineTo(size.width, 0); // الزاوية العلوية اليمنى
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 🔁 الغامق (العلوي) – من منتصف الأعلى ↘ إلى أسفل يسار
class TopShapePainterFlipped extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF8BD6D0).withOpacity(0.6);

    final path = Path();

    path.moveTo(size.width / 2, 0); // منتصف الحافة العلوية
    path.lineTo(0, size.height); // الزاوية السفلية اليسرى
    path.lineTo(size.width, size.height); // الزاوية السفلية اليمنى
    path.lineTo(size.width, 0); // الزاوية العلوية اليمنى
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
