import 'package:application/API_Service/api.dart';
import 'package:application/screens/Main_User_Pages.dart/Profile_Page/change_pass_page/change_pass.dart';
import 'package:flutter/material.dart';
import 'package:application/constants/app_colors.dart';
import 'package:application/models/user.dart';
import 'package:easy_localization/easy_localization.dart';

class EditProfileSheet extends StatefulWidget {
  final User user;
  final Function(User)? onUserUpdated;

  const EditProfileSheet({
    super.key,
    required this.user,
    this.onUserUpdated,
  });

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet>
    with TickerProviderStateMixin {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  String? selectedCity;
  String? selectedGender; // This will store the display value (translated)
  bool _isLoading = false;
  String? _error;

  // API service instance
  late final ApiService _apiService = ApiService();

  // Form validation
  final _formKey = GlobalKey<FormState>();
  bool _hasChanges = false;

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // City mapping: stored value -> display value
  final Map<String, String> cityMap = {
    'RAMALLAH': tr('cities.ramallah'),
    'NABLUS': tr('cities.nablus'),
    'HEBRON': tr('cities.hebron'),
    'BETHLEHEM': tr('cities.bethlehem'),
    'JENIN': tr('cities.jenin'),
    'TULKARM': tr('cities.tulkarm'),
    'QALQILYA': tr('cities.qalqilya'),
    'SALFIT': tr('cities.salfit'),
    'JERICHO': tr('cities.jericho'),
    'TUBAS': tr('cities.tubas'),
  };

  // Gender mapping: stored value -> display value
  final Map<String, String> genderMap = {
    'MALE': tr('gender.male'),
    'FEMALE': tr('gender.female')
  };

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _addChangeListeners();
  }

  void _initializeControllers() {
    nameController = TextEditingController(
      text: "${widget.user.firstName} ${widget.user.lastName}",
    );
    phoneController = TextEditingController(text: widget.user.phone);
    // Convert stored city value to display value
    selectedCity = _getDisplayCity(widget.user.city);
    // Convert stored gender value to display value
    selectedGender = _getDisplayGender(widget.user.gender);
  }

  // Helper method to convert stored city to display city
  String? _getDisplayCity(String? storedCity) {
    if (storedCity == null) return null;
    // Try to find the city in our mapping
    String? displayCity = cityMap[storedCity.toUpperCase()];
    if (displayCity != null) {
      return displayCity;
    }
    // If not found in mapping, check if it's already a display value
    if (cityMap.values.contains(storedCity)) {
      return storedCity;
    }
    // If neither, return the first city as default or null
    return cityMap.values.isNotEmpty ? cityMap.values.first : null;
  }

  // Helper method to convert display city to stored city
  String? _getStoredCity(String? displayCity) {
    if (displayCity == null) return null;
    MapEntry<String, String>? entry;
    try {
      entry = cityMap.entries.firstWhere((entry) => entry.value == displayCity);
      return entry.key;
    } catch (e) {
      // If not found, return null
      return null;
    }
  }

  // Helper method to convert stored gender to display gender
  String? _getDisplayGender(String? storedGender) {
    if (storedGender == null) return null;
    String? displayGender = genderMap[storedGender.toUpperCase()];
    if (displayGender != null) {
      return displayGender;
    }
    // If not found in mapping, check if it's already a display value
    if (genderMap.values.contains(storedGender)) {
      return storedGender;
    }
    // If neither, return the first gender as default or null
    return genderMap.values.isNotEmpty ? genderMap.values.first : null;
  }

  // Helper method to convert display gender to stored gender
  String? _getStoredGender(String? displayGender) {
    if (displayGender == null) return null;
    MapEntry<String, String>? entry;
    try {
      entry =
          genderMap.entries.firstWhere((entry) => entry.value == displayGender);
      return entry.key;
    } catch (e) {
      // If not found, return null
      return null;
    }
  }

  void _initializeAnimations() {
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

  void _addChangeListeners() {
    nameController.addListener(_checkForChanges);
    phoneController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    final currentName = "${widget.user.firstName} ${widget.user.lastName}";
    final hasNameChanged = nameController.text.trim() != currentName;
    final hasPhoneChanged = phoneController.text.trim() != widget.user.phone;

    // Convert display city back to stored city for comparison
    final currentStoredCity = _getStoredCity(selectedCity);
    final hasCityChanged = currentStoredCity != widget.user.city;

    // Convert display gender back to stored gender for comparison
    final currentStoredGender = _getStoredGender(selectedGender);
    final hasGenderChanged = currentStoredGender != widget.user.gender;

    final newHasChanges = hasNameChanged || hasPhoneChanged || hasCityChanged ||
        hasGenderChanged;

    if (newHasChanges != _hasChanges) {
      setState(() => _hasChanges = newHasChanges);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasChanges) {
      _showMessage(
          'لا توجد تغييرات للحفظ', isError: false); // No changes to save
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Parse the full name into first and last name
      final nameParts = nameController.text.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';

      // Convert display values back to stored values
      final storedGender = _getStoredGender(selectedGender) ??
          widget.user.gender;
      final storedCity = _getStoredCity(selectedCity) ?? widget.user.city;

      // Create updated user object
      final updatedUser = User(
        id: widget.user.id,
        firstName: firstName,
        lastName: lastName,
        phone: phoneController.text.trim(),
        email: widget.user.email,
        city: storedCity,
        gender: storedGender,
        password: widget.user.password,
        role: widget.user.role,
      );
      final int currentUser = widget.user.id;

      // Call API to update user
      final apiUpdatedUser = await _apiService.updateUserProfile(
          userId: currentUser, user: updatedUser);

      setState(() => _isLoading = false);

      if (mounted) {
        // Call the callback to update parent widget
        widget.onUserUpdated?.call(apiUpdatedUser);

        Navigator.pop(context); // Return updated user
        _showSuccessMessage();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
      _showErrorMessage(e.toString());
    }
  }

  void _showSuccessMessage() {
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

  void _showErrorMessage(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${tr('profile.save.error')}: $error',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error(context),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: tr('common.retry'),
          textColor: Colors.white,
          onPressed: _saveChanges,
        ),
      ),
    );
  }

  void _showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error(context) : AppColors.info(
            context),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value
        .trim()
        .isEmpty) {
      return 'الاسم مطلوب'; // Name required
    }
    if (value
        .trim()
        .length < 2) {
      return 'الاسم قصير جداً'; // Name too short
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value
        .trim()
        .isEmpty) {
      return 'رقم الهاتف مطلوب'; // Phone required
    }
    // Basic phone validation for Palestinian numbers
    final phoneRegex = RegExp(r'^(\+970\s?|0)(5[0-9]|2[0-9]|9[0-9])[0-9]{7}$');
    Widget _buildAdvancedHeader() {
      final screenSize = MediaQuery
          .of(context)
          .size;
      final isTablet = screenSize.width > 600;

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
                if (_hasChanges)
                  Container(
                    padding: EdgeInsets.all(isTablet ? 12 : 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(isTablet ? 14 : 10),
                    ),
                    child: Icon(
                      Icons.edit,
                      color: Colors.orange,
                      size: isTablet ? 24 : 20,
                    ),
                  )
                else
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

    Widget _buildAdvancedTextField(String label,
        TextEditingController controller,
        IconData icon, {
          TextInputType keyboardType = TextInputType.text,
          String? Function(String?)? validator,
        }) {
      final screenSize = MediaQuery
          .of(context)
          .size;
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
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                validator: validator,
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
                      color: AppColors.primaryLightDark(context).withOpacity(
                          0.1),
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
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
                    borderSide: BorderSide(
                      color: AppColors.error(context),
                      width: 2,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
                    borderSide: BorderSide(
                      color: AppColors.error(context),
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

    Widget _buildAdvancedDropdownField(String label,
        String? selectedValue,
        List<String> items,
        ValueChanged<String?> onChanged,
        IconData icon,) {
      final screenSize = MediaQuery
          .of(context)
          .size;
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
                      color: AppColors.primaryLightDark(context).withOpacity(
                          0.1),
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
                onChanged: (value) {
                  onChanged(value);
                  _checkForChanges();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'هذا الحقل مطلوب'; // This field is required
                  }
                  return null;
                },
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
      final screenSize = MediaQuery
          .of(context)
          .size;
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
            onPressed: () async {
              final result = await showModalBottomSheet<bool>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) =>
                    Container(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.7,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground(context),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: ChangePasswordPage(userEmail: widget.user.email ,
                        userId: '${widget.user.id}',
                      ),
                    ),
              );

              // If password was changed successfully, show message
              if (result == true && mounted) {
                _showMessage(
                  'تم تغيير كلمة المرور بنجاح', // Password changed successfully
                  isError: false,
                );
              }
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
      final screenSize = MediaQuery
          .of(context)
          .size;
      final isTablet = screenSize.width > 600;

      return Container(
        width: double.infinity,
        height: isTablet ? 60 : 50,
        margin: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
        decoration: BoxDecoration(
          gradient: _hasChanges
              ? AppColors.primaryGradient(context)
              : LinearGradient(
            colors: [
              AppColors.textSecondary(context).withOpacity(0.3),
              AppColors.textSecondary(context).withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
          boxShadow: _hasChanges ? [
            BoxShadow(
              color: AppColors.primaryLightDark(context).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ] : [],
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
            _hasChanges ? Icons.save_outlined : Icons.check_circle_outline,
            color: Colors.white,
            size: isTablet ? 24 : 20,
          ),
          label: Text(
            _isLoading
                ? tr('profile.save.loading')
                : _hasChanges
                ? tr('profile.save.button')
                : 'لا توجد تغييرات', // No changes
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: (_isLoading || !_hasChanges) ? null : _saveChanges,
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

    Widget _buildInfoCard() {
      final screenSize = MediaQuery
          .of(context)
          .size;
      final isTablet = screenSize.width > 600;

      return Container(
        margin: EdgeInsets.only(bottom: isTablet ? 24 : 20),
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        decoration: BoxDecoration(
          color: AppColors.getInfoCardBackground(
              context, AppColors.info(context)),
          borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
          border: Border.all(
            color: AppColors.getInfoCardBorder(
                context, AppColors.info(context)),
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

    Widget _buildErrorDisplay() {
      if (_error == null) return const SizedBox.shrink();

      final screenSize = MediaQuery
          .of(context)
          .size;
      final isTablet = screenSize.width > 600;

      return Container(
        margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
        padding: EdgeInsets.all(isTablet ? 16 : 12),
        decoration: BoxDecoration(
          color: AppColors.error(context).withOpacity(0.1),
          borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
          border: Border.all(
            color: AppColors.error(context).withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.error(context),
              size: isTablet ? 24 : 20,
            ),
            SizedBox(width: isTablet ? 12 : 8),
            Expanded(
              child: Text(
                _error!,
                style: TextStyle(
                  color: AppColors.error(context),
                  fontSize: isTablet ? 14 : 12,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                color: AppColors.error(context),
                size: isTablet ? 20 : 18,
              ),
              onPressed: () => setState(() => _error = null),
            ),
          ],
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      final screenSize = MediaQuery
          .of(context)
          .size;
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
            height: MediaQuery
                .of(context)
                .size
                .height * (isTablet ? 0.85 : 0.9),
            width: maxWidth,
            margin: screenSize.width > 1200
                ? EdgeInsets.symmetric(
              horizontal: (screenSize.width - maxWidth) / 2,
            )
                : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: AppColors.scaffoldBackground(context),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowStrong(context),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildAdvancedHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isTablet ? 24 : 16),
                      child: Column(
                        children: [
                          _buildInfoCard(),
                          _buildErrorDisplay(),

                          _buildAdvancedTextField(
                            tr('profile.fields.fullName'),
                            nameController,
                            Icons.person_outline,
                            validator: _validateName,
                          ),

                          _buildAdvancedTextField(
                            tr('profile.fields.phone'),
                            phoneController,
                            Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: _validatePhone,
                          ),

                          _buildAdvancedDropdownField(
                            tr('profile.fields.city'),
                            selectedCity,
                            cityMap.values.toList(), // Use display values
                                (value) => setState(() => selectedCity = value),
                            Icons.location_city_outlined,
                          ),

                          _buildAdvancedDropdownField(
                            tr('profile.fields.gender'),
                            selectedGender,
                            genderMap.values.toList(), // Use display values
                                (value) =>
                                setState(() => selectedGender = value),
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
                                  child: Divider(
                                      color: AppColors.divider(context)),
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
                                  child: Divider(
                                      color: AppColors.divider(context)),
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
        ),
      );
    }

    if (!phoneRegex.hasMatch(value.trim())) {
      return 'رقم الهاتف غير صحيح'; // Invalid phone
    }
    return null;
  }

  Widget _buildAdvancedHeader() {
    final screenSize = MediaQuery
        .of(context)
        .size;
    final isTablet = screenSize.width > 600;

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
              if (_hasChanges)
                Container(
                  padding: EdgeInsets.all(isTablet ? 12 : 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(isTablet ? 14 : 10),
                  ),
                  child: Icon(
                    Icons.edit,
                    color: Colors.orange,
                    size: isTablet ? 24 : 20,
                  ),
                )
              else
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

  Widget _buildAdvancedTextField(String label,
      TextEditingController controller,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator,
      }) {
    final screenSize = MediaQuery
        .of(context)
        .size;
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
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              validator: validator,
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
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
                  borderSide: BorderSide(
                    color: AppColors.error(context),
                    width: 2,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
                  borderSide: BorderSide(
                    color: AppColors.error(context),
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

  Widget _buildAdvancedDropdownField(String label,
      String? selectedValue,
      List<String> items,
      ValueChanged<String?> onChanged,
      IconData icon,) {
    final screenSize = MediaQuery
        .of(context)
        .size;
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
              onChanged: (value) {
                onChanged(value);
                _checkForChanges();
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return tr('validation.field_required');
                }
                return null;
              },
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
    final screenSize = MediaQuery
        .of(context)
        .size;
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
          onPressed: () async {
            final result = await showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) =>
                  Container(
                    height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.7,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground(context),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: ChangePasswordPage(),
                  ),
            );

            // If password was changed successfully, show message
            if (result == true && mounted) {
              _showMessage(
                tr('profile.password.change_success'),
                isError: false,
              );
            }
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
    final screenSize = MediaQuery
        .of(context)
        .size;
    final isTablet = screenSize.width > 600;

    return Container(
      width: double.infinity,
      height: isTablet ? 60 : 50,
      margin: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
      decoration: BoxDecoration(
        gradient: _hasChanges
            ? AppColors.primaryGradient(context)
            : LinearGradient(
          colors: [
            AppColors.textSecondary(context).withOpacity(0.3),
            AppColors.textSecondary(context).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
        boxShadow: _hasChanges ? [
          BoxShadow(
            color: AppColors.primaryLightDark(context).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ] : [],
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
          _hasChanges ? Icons.save_outlined : Icons.check_circle_outline,
          color: Colors.white,
          size: isTablet ? 24 : 20,
        ),
        label: Text(
          _isLoading
              ? tr('profile.save.loading')
              : _hasChanges
              ? tr('profile.save.button')
              : tr('profile.save.no_changes'),
          style: TextStyle(
            color: Colors.white,
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: (_isLoading || !_hasChanges) ? null : _saveChanges,
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

  Widget _buildInfoCard() {
    final screenSize = MediaQuery
        .of(context)
        .size;
    final isTablet = screenSize.width > 600;

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 24 : 20),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: AppColors.getInfoCardBackground(
            context, AppColors.info(context)),
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

  Widget _buildErrorDisplay() {
    if (_error == null) return const SizedBox.shrink();

    final screenSize = MediaQuery
        .of(context)
        .size;
    final isTablet = screenSize.width > 600;

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: AppColors.error(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
        border: Border.all(
          color: AppColors.error(context).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error(context),
            size: isTablet ? 24 : 20,
          ),
          SizedBox(width: isTablet ? 12 : 8),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(
                color: AppColors.error(context),
                fontSize: isTablet ? 14 : 12,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: AppColors.error(context),
              size: isTablet ? 20 : 18,
            ),
            onPressed: () => setState(() => _error = null),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery
        .of(context)
        .size;
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
          height: MediaQuery
              .of(context)
              .size
              .height * (isTablet ? 0.85 : 0.9),
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildAdvancedHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    child: Column(
                      children: [
                        _buildInfoCard(),
                        _buildErrorDisplay(),

                        _buildAdvancedTextField(
                          tr('profile.fields.fullName'),
                          nameController,
                          Icons.person_outline,
                          validator: _validateName,
                        ),

                        _buildAdvancedTextField(
                          tr('profile.fields.phone'),
                          phoneController,
                          Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: _validatePhone,
                        ),

                        _buildAdvancedDropdownField(
                          tr('profile.fields.city'),
                          selectedCity,
                          cityMap.values.toList(), // Use display values
                              (value) => setState(() => selectedCity = value),
                          Icons.location_city_outlined,
                        ),

                        _buildAdvancedDropdownField(
                          tr('profile.fields.gender'),
                          selectedGender,
                          genderMap.values.toList(), // Use display values
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
                                child: Divider(
                                    color: AppColors.divider(context)),
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
                                child: Divider(
                                    color: AppColors.divider(context)),
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
      ),
    );
  }
}