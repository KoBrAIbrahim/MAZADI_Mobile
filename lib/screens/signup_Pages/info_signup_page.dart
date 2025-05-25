import 'package:application/widgets/backgorund/BlurredBackground.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String selectedGender = '';
  late String selectedCity;

  @override
  void initState() {
    super.initState();
    selectedCity = 'ramallah'.tr();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: BlurredBackground(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height * 0.05),
                    Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: width * 0.4,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: height * 0.04),
                    Text(
                      'create_account'.tr(),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: width * 0.3,
                      height: 2,
                      color: colorScheme.primary,
                    ),
                    SizedBox(height: height * 0.04),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInput(
                            'first_name'.tr(),
                            icon: Icons.person,
                            colorScheme: colorScheme,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildInput(
                            'last_name'.tr(),
                            icon: Icons.person,
                            colorScheme: colorScheme,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.03),
                    _buildInput(
                      'mobile_number'.tr(),
                      hint: 'phone_number_hint'.tr(),
                      icon: Icons.phone,
                      colorScheme: colorScheme,
                    ),
                    SizedBox(height: height * 0.03),
                    _buildDropdown('city'.tr(), colorScheme),
                    SizedBox(height: height * 0.03),
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 20, color: colorScheme.onSurface),
                        const SizedBox(width: 6),
                        Text(
                          'gender'.tr(),
                          style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildCustomCheckbox(
                          label: 'male'.tr(),
                          selected: selectedGender == 'male'.tr(),
                          onTap: () {
                            setState(() {
                              selectedGender = 'male'.tr();
                            });
                          },
                          colorScheme: colorScheme,
                        ),
                        _buildCustomCheckbox(
                          label: 'female'.tr(),
                          selected: selectedGender == 'female'.tr(),
                          onTap: () {
                            setState(() {
                              selectedGender = 'female'.tr();
                            });
                          },
                          colorScheme: colorScheme,
                        ),
                      ],
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              right: width * 0.08,
              left: width * 0.08,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: colorScheme.secondary,
                          child: Icon(Icons.arrow_back, color: colorScheme.onSecondary),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'back'.tr(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/account_signup_page'),
                    child: Row(
                      children: [
                        Text(
                          'continue'.tr(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 10),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: colorScheme.secondary,
                          child: Icon(Icons.arrow_forward, color: colorScheme.onSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, {String? hint, IconData? icon, required ColorScheme colorScheme}) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint ?? label,
        prefixIcon: icon != null ? Icon(icon, size: 20, color: colorScheme.primary) : null,
        hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_city, size: 18, color: colorScheme.onSurface),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.background,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCity,
              isExpanded: true,
              icon: Container(
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.keyboard_arrow_down, color: colorScheme.primary),
              ),
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              dropdownColor: colorScheme.background,
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              items: [
                _buildCityItem('ramallah'.tr(), colorScheme),
                _buildCityItem('nablus'.tr(), colorScheme),
                _buildCityItem('hebron'.tr(), colorScheme),
              ],
              onChanged: (value) {
                setState(() {
                  selectedCity = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  DropdownMenuItem<String> _buildCityItem(String city, ColorScheme colorScheme) {
    return DropdownMenuItem(
      value: city,
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            size: 18,
            color: city == selectedCity ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(width: 12),
          Text(
            city,
            style: TextStyle(
              color: city == selectedCity ? colorScheme.primary : colorScheme.onSurface,
              fontWeight: city == selectedCity ? FontWeight.bold : FontWeight.normal,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomCheckbox({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.primary, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
        const SizedBox(width: 16),
      ],
    );
  }
}