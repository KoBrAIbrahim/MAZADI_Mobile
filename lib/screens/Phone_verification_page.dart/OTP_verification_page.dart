import 'dart:async';
import 'package:application/constants/app_colors.dart';
import 'package:application/widgets/auth_background.dart';
import 'package:flutter/material.dart';

class VerificationCodePage extends StatefulWidget {
  const VerificationCodePage({super.key});

  @override
  State<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  int _secondsLeft = 60;
  Timer? _timer;

  bool get _isFilled => _controllers.every((c) => c.text.isNotEmpty);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsLeft = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return AuthScaffold(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: height * 0.35,
          left: width * 0.07,
          right: width * 0.07,
          bottom: 30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Enter Verification code',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'أدخل رمز التحقق المرسل إلى رقم هاتفك لإتمام تسجيل الدخول',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return SizedBox(
                  width: 50,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: _isFilled ? AppColors.secondary : Colors.black,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor:
                          _isFilled
                              ? AppColors.secondary.withOpacity(0.2)
                              : Colors.grey.shade100,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color:
                              _isFilled
                                  ? AppColors.secondary
                                  : Colors.grey.shade400,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color:
                              _isFilled
                                  ? AppColors.secondary
                                  : AppColors.primary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (val) => _onChanged(index, val),
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isFilled ? () {} : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isFilled ? AppColors.secondary : Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Submit',
                  style: TextStyle(
                    color: _isFilled ? Colors.white : Colors.grey.shade600,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Resend code in 0:${_secondsLeft.toString().padLeft(2, '0')}',
              style: const TextStyle(color: AppColors.primary),
            ),
            if (_secondsLeft == 0)
              TextButton(
                onPressed: () {
                  // Reset all fields
                  for (var controller in _controllers) {
                    controller.clear();
                  }

                  // Set focus to أول خانة
                  _focusNodes[0].requestFocus();

                  // Restart timer
                  _startTimer();

                  // تحديث الواجهة
                  setState(() {});
                },

                child: const Text(
                  'Resend Code',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Back to log in',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
