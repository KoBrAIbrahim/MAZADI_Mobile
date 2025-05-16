import 'package:application/widgets/customer_drop_down_item.dart';
import 'package:flutter/material.dart';
import '../../widgets/auth_background.dart';
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return AuthScaffold(
      showBottomBackground: true,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: height * 0.33,
          left: width * 0.07,
          right: width * 0.07,
          bottom: 30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إنشاء حساب',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(width: width * 0.3, height: 2, color: AppColors.primary),
            SizedBox(height: height * 0.03),

            Row(
              children: [
                Expanded(child: _buildInput('First Name',icon: Icons.person,)),
                const SizedBox(width: 10),
                Expanded(child: _buildInput('Last Name',icon: Icons.person,)),
              ],
            ),
            SizedBox(height: height * 0.03),

            _buildInput(
              'Mobile Number',
              hint: '+00 000-000-000',
              icon: Icons.phone,
            ),
            SizedBox(height: height * 0.03),

            _buildDropdown('City'),
            SizedBox(height: height * 0.03),

            Row(
              children: const [
                Icon(Icons.person_outline, size: 20, color: Colors.black),
                SizedBox(width: 6),
                Text('Gender', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),

            SizedBox(height: height * 0.01),
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

            SizedBox(height: height * 0.16),

            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'أكمل',
                    style: TextStyle(fontWeight: FontWeight.bold , fontSize: 20),
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
        prefixIcon:
            icon != null
                ? Icon(
                  icon,
                  size: 20,
                  color: const Color.fromARGB(255, 0, 0, 0),
                )
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
          children: [
            const Icon(
              Icons.location_city,
              size: 18,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.primary,
                ),
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
                DropdownMenuItem(
                  value: 'رام الله',
                  child: _buildCityItem('رام الله', Icons.location_on),
                ),
                DropdownMenuItem(
                  value: 'نابلس',
                  child: _buildCityItem('نابلس', Icons.location_on),
                ),
                DropdownMenuItem(
                  value: 'الخليل',
                  child: _buildCityItem('الخليل', Icons.location_on),
                ),
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

  Widget _buildCityItem(String cityName, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: cityName == selectedCity ? AppColors.primary : Colors.grey,
          ),
          const SizedBox(width: 12),
          Text(
            cityName,
            style: TextStyle(
              color:
                  cityName == selectedCity ? AppColors.primary : Colors.black87,
              fontWeight:
                  cityName == selectedCity
                      ? FontWeight.bold
                      : FontWeight.normal,
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
            child:
                selected
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
