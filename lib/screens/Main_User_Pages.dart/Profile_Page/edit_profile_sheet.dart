import 'package:application/screens/Main_User_Pages.dart/Profile_Page/change_pass_page/change_pass.dart';
import 'package:flutter/material.dart';
import 'package:application/constants/app_colors.dart';
import 'package:application/models/user.dart';
import 'package:easy_localization/easy_localization.dart';

class EditProfileSheet extends StatefulWidget {
  final User user;

  const EditProfileSheet({super.key, required this.user});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet>
    with TickerProviderStateMixin {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  String? selectedCity;
  String? selectedGender;
  bool _isLoading = false;

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final List<String> palestinianCities = [
    tr('cities.ramallah'),
    tr('cities.nablus'),
    tr('cities.hebron'),
    tr('cities.bethlehem'),
    tr('cities.jenin'),
    tr('cities.tulkarm'),
    tr('cities.qalqilya'),
    tr('cities.salfit'),
    tr('cities.jericho'),
    tr('cities.tubas'),
  ];

  final List<String> genders = [tr('gender.male'), tr('gender.female')];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: "${widget.user.firstName} ${widget.user.lastName}",
    );
    phoneController = TextEditingController(text: widget.user.phoneNumber);
    selectedCity = widget.user.city;
    selectedGender = widget.user.gender;

    // Initialize animations
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.3, end: 0.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Start animations
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Widget _buildAdvancedHeader() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isDesktop = screenSize.width > 1200;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isTablet ? 24 : 20,
        horizontal: isTablet ? 24 : 16,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLightDark(context).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            height: isTablet ? 6 : 5,
            width: isTablet ? 60 : 50,
            margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: AppColors.handleColor(context),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header Content
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 16 : 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                ),
                child: Icon(
                  Icons.edit_outlined,
                  color: Colors.white,
                  size: isTablet ? 28 : 24,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('profile.edit.title'),
                      style: TextStyle(
                        fontSize: isTablet ? 22 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: isTablet ? 6 : 4),
                    Text(
                      tr('profile.edit.subtitle'),
                      style: TextStyle(
                        fontSize: isTablet ? 15 : 13,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(isTablet ? 12 : 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(isTablet ? 14 : 10),
                ),
                child: Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: isTablet ? 24 : 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight(context),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary(context),
              ),
              decoration: InputDecoration(
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLightDark(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primaryLightDark(context),
                    size: isTablet ? 22 : 18,
                  ),
                ),
                filled: true,
                fillColor: AppColors.cardBackground(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
                  borderSide: BorderSide(color: AppColors.divider(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
                  borderSide: BorderSide(
                    color: AppColors.primaryLightDark(context),
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20 : 16,
                  vertical: isTablet ? 20 : 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedDropdownField(
    String label,
    String? selectedValue,
    List<String> items,
    ValueChanged<String?> onChanged,
    IconData icon,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight(context),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              value: selectedValue,
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary(context),
              ),
              dropdownColor: AppColors.cardBackground(context),
              decoration: InputDecoration(
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLightDark(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primaryLightDark(context),
                    size: isTablet ? 22 : 18,
                  ),
                ),
                filled: true,
                fillColor: AppColors.cardBackground(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
                  borderSide: BorderSide(color: AppColors.divider(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
                  borderSide: BorderSide(
                    color: AppColors.primaryLightDark(context),
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20 : 16,
                  vertical: isTablet ? 20 : 16,
                ),
              ),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.primaryLightDark(context),
                size: isTablet ? 28 : 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedPasswordButton() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Container(
      margin: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
          boxShadow: [
            BoxShadow(
              color: AppColors.passwordButtonShadow(context),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          icon: Icon(
            Icons.security_outlined,
            color: Colors.white,
            size: isTablet ? 24 : 20,
          ),
          label: Text(
            tr('profile.password.change'),
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 17 : 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => Container(
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground(context),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: ChangePasswordPage(user: widget.user),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.passwordButtonBackground(context),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
            ),
            padding: EdgeInsets.symmetric(
              vertical: isTablet ? 18 : 14,
              horizontal: isTablet ? 24 : 16,
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedSaveButton() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Container(
      width: double.infinity,
      height: isTablet ? 60 : 50,
      margin: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient(context),
        borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLightDark(context).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: _isLoading
            ? SizedBox(
                width: isTablet ? 22 : 18,
                height: isTablet ? 22 : 18,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(
                Icons.save_outlined,
                color: Colors.white,
                size: isTablet ? 24 : 20,
              ),
        label: Text(
          _isLoading ? tr('profile.save.loading') : tr('profile.save.button'),
          style: TextStyle(
            color: Colors.white,
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: _isLoading ? null : _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
          ),
        ),
      ),
    );
  }

  void _saveChanges() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(tr('profile.save.success')),
            ],
          ),
          backgroundColor: AppColors.success(context),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Widget _buildInfoCard() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 24 : 20),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: AppColors.getInfoCardBackground(context, AppColors.info(context)),
        borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
        border: Border.all(
          color: AppColors.getInfoCardBorder(context, AppColors.info(context)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 12 : 10),
            decoration: BoxDecoration(
              color: AppColors.getInfoIconBackground(context),
              borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
            ),
            child: Icon(
              Icons.info_outline,
              color: AppColors.info(context),
              size: isTablet ? 24 : 20,
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('profile.info.title'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.info(context),
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
                SizedBox(height: isTablet ? 6 : 4),
                Text(
                  tr('profile.info.message'),
                  style: TextStyle(
                    color: AppColors.info(context),
                    fontSize: isTablet ? 14 : 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final maxWidth = screenSize.width > 1200 ? 800.0 : double.infinity;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, _slideAnimation.value),
          end: Offset.zero,
        ).animate(_slideController),
        child: Container(
          height: MediaQuery.of(context).size.height * (isTablet ? 0.85 : 0.9),
          width: maxWidth,
          margin: screenSize.width > 1200
              ? EdgeInsets.symmetric(
                  horizontal: (screenSize.width - maxWidth) / 2,
                )
              : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackground(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowStrong(context),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildAdvancedHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isTablet ? 24 : 16),
                  child: Column(
                    children: [
                      _buildInfoCard(),

                      _buildAdvancedTextField(
                        tr('profile.fields.fullName'),
                        nameController,
                        Icons.person_outline,
                      ),

                      _buildAdvancedTextField(
                        tr('profile.fields.phone'),
                        phoneController,
                        Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),

                      _buildAdvancedDropdownField(
                        tr('profile.fields.city'),
                        selectedCity,
                        palestinianCities,
                        (value) => setState(() => selectedCity = value),
                        Icons.location_city_outlined,
                      ),

                      _buildAdvancedDropdownField(
                        tr('profile.fields.gender'),
                        selectedGender,
                        genders,
                        (value) => setState(() => selectedGender = value),
                        Icons.person_pin_outlined,
                      ),

                      // Divider
                      Container(
                        margin: EdgeInsets.symmetric(
                          vertical: isTablet ? 24 : 20,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(color: AppColors.divider(context)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 16 : 12,
                              ),
                              child: Text(
                                tr('profile.security.title'),
                                style: TextStyle(
                                  color: AppColors.textSecondary(context),
                                  fontSize: isTablet ? 14 : 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: AppColors.divider(context)),
                            ),
                          ],
                        ),
                      ),

                      _buildAdvancedPasswordButton(),

                      SizedBox(height: isTablet ? 24 : 20),

                      _buildAdvancedSaveButton(),

                      SizedBox(height: isTablet ? 20 : 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}