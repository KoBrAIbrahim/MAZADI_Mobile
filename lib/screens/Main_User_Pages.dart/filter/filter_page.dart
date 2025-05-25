import 'package:application/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> with TickerProviderStateMixin {
  String? selectedSort;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  final List<String> sortOptionsKeys = [
    'sort_all',
    'sort_price',
    'sort_date',
    'sort_rating',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void applyFilter() {
    Navigator.of(context).pop(selectedSort);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _slideAnimation.value) * 100),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: screenHeight * 0.35,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: mediaQuery.viewInsets.bottom + 20
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground(context),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColor(context),
                        blurRadius: isDarkMode ? 15 : 10,
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
                      _buildHandle(context, screenWidth),
                      _buildTitle(context, screenWidth, screenHeight),
                      _buildSortOptions(context, screenWidth, screenHeight),
                      _buildApplyButton(context, screenWidth, screenHeight),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandle(BuildContext context, double screenWidth) {
    return Center(
      child: Container(
        width: screenWidth * 0.1,
        height: 4,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: AppColors.handleColor(context),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenHeight * 0.02),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLightDark(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.tune,
              color: AppColors.primaryLightDark(context),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'sort_by'.tr(),
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOptions(BuildContext context, double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenHeight * 0.02),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: sortOptionsKeys.asMap().entries.map((entry) {
          final index = entry.key;
          final key = entry.value;
          final isSelected = selectedSort == key;
          
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 150 + (index * 50)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Opacity(
                  opacity: value,
                  child: _buildSortChip(
                    context,
                    key,
                    isSelected,
                    screenWidth,
                    screenHeight,
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSortChip(
    BuildContext context,
    String key,
    bool isSelected,
    double screenWidth,
    double screenHeight,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSort = key;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.045,
          vertical: screenHeight * 0.015,
        ),
        decoration: BoxDecoration(
          color: AppColors.chipBackground(context, isSelected),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.chipBorder(context, isSelected),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primaryLightDark(context).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(
                Icons.check_circle,
                size: 16,
                color: AppColors.primaryLightDark(context),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              key.tr(),
              style: TextStyle(
                color: AppColors.chipText(context, isSelected),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: screenWidth * 0.035,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplyButton(BuildContext context, double screenWidth, double screenHeight) {
    return SizedBox(
      width: double.infinity,
      height: screenHeight * 0.07,
      child: ElevatedButton(
        onPressed: selectedSort != null ? applyFilter : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLightDark(context),
          disabledBackgroundColor: AppColors.primaryLightDark(context).withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: selectedSort != null ? 6 : 0,
          shadowColor: AppColors.primaryLightDark(context).withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.done,
              color: Colors.white,
              size: screenWidth * 0.045,
            ),
            const SizedBox(width: 8),
            Text(
              'apply_sort'.tr(),
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}