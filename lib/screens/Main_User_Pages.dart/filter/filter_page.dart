import 'package:flutter/material.dart';
import 'package:application/constants/app_colors.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  String? selectedSort;

  final List<String> sortOptions = ['All', 'Price', 'Date', 'Rating'];

  void applyFilter() {
    Navigator.of(context).pop(selectedSort);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final cardBackground = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: screenHeight * 0.35, // 35% من ارتفاع الشاشة
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom + 20),
          child: Container(
            decoration: BoxDecoration(
              color: cardBackground,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.025,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: screenWidth * 0.1,
                    height: 4,
                    margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Sort by',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                      sortOptions.map((option) {
                        final isSelected = selectedSort == option;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedSort = option;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.045,
                              vertical: screenHeight * 0.015,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppColors.primary.withOpacity(0.1)
                                      : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(
                                8,
                              ), // ← زاوية مستطيل ناعم
                              border: Border.all(
                                color:
                                    isSelected
                                        ? AppColors.primary
                                        : Colors.grey.shade400,
                                width: 1.0,
                              ),
                            ),

                            child: Text(
                              option,
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? AppColors.primary
                                        : Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: screenWidth * 0.035,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
                SizedBox(height: screenHeight * 0.02),
                SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.07,
                  child: ElevatedButton(
                    onPressed: applyFilter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: AppColors.primary.withOpacity(0.3),
                    ),
                    child: Text(
                      'Apply Sort',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
