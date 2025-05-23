import 'package:application/widgets/backgorund/BlurredBackground.dart';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
 
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String selectedGender = '';
  String selectedCity = 'رام الله';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: BlurredBackground(
        child: Stack(
          children: [
            // ✅ محتوى الصفحة (قابل للتمرير)
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height * 0.05),

                    // اللوجو
                    Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: width * 0.4,
                        fit: BoxFit.contain,
                      ),
                    ),

                    SizedBox(height: height * 0.04),

                    const Text(
                      'إنشاء حساب',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Container(width: width * 0.3, height: 2, color: AppColors.primary),
                    SizedBox(height: height * 0.04),

                    Row(
                      children: [
                        Expanded(child: _buildInput('First Name', icon: Icons.person)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildInput('Last Name', icon: Icons.person)),
                      ],
                    ),

                    SizedBox(height: height * 0.03),
                    _buildInput('Mobile Number', hint: '+00 000-000-000', icon: Icons.phone),
                    SizedBox(height: height * 0.03),
                    _buildDropdown('City'),
                    SizedBox(height: height * 0.03),

                    const Row(
                      children: [
                        Icon(Icons.person_outline, size: 20, color: Colors.black),
                        SizedBox(width: 6),
                        Text('Gender', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),

                    SizedBox(height: 8),
                    Row(
                      children: [
                        _buildCustomCheckbox(
                          label: 'Male',
                          selected: selectedGender == 'Male',
                          onTap: () {
                            setState(() {
                              selectedGender = 'Male';
                            });
                          },
                        ),
                        _buildCustomCheckbox(
                          label: 'Female',
                          selected: selectedGender == 'Female',
                          onTap: () {
                            setState(() {
                              selectedGender = 'Female';
                            });
                          },
                        ),
                      ],
                    ),

                    // مساحة كافية لتجنب تغطية الزر المثبت
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),

            // ✅ زر "أكمل" ثابت في أسفل يمين الشاشة
            Positioned(
              bottom: 20,
              right: width * 0.08,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'أكمل',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: const Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, {String? hint, IconData? icon}) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint ?? label,
        prefixIcon: icon != null
            ? Icon(icon, size: 20, color: Colors.black)
            : null,
        hintStyle: const TextStyle(color: Colors.grey),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.location_city, size: 18, color: Colors.black),
            SizedBox(width: 8),
            Text('City', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
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
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
              ),
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              dropdownColor: Colors.white,
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              items: [
                _buildCityItem('رام الله'),
                _buildCityItem('نابلس'),
                _buildCityItem('الخليل'),
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

  DropdownMenuItem<String> _buildCityItem(String city) {
    return DropdownMenuItem(
      value: city,
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            size: 18,
            color: city == selectedCity ? AppColors.primary : Colors.grey,
          ),
          const SizedBox(width: 12),
          Text(
            city,
            style: TextStyle(
              color: city == selectedCity ? AppColors.primary : Colors.black87,
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
              border: Border.all(color: AppColors.primary, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 16),
      ],
    );
  }
}
