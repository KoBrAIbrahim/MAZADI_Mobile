import 'dart:async';
import 'package:application/widgets/backgorund/BlurredBackground.dart';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class VerificationCodePage extends StatefulWidget {
  const VerificationCodePage({super.key});

  @override
  State<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
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
    for (var c in _controllers) {
      c.dispose();
    }
    for (var n in _focusNodes) {
      n.dispose();
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

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: BlurredBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                    child: Column(
                      children: [
                        SizedBox(height: height * 0.05),

                        // اللوجو
                        Image.asset(
                          'assets/images/logo.png',
                          width: width * 0.4,
                          fit: BoxFit.contain,
                        ),

                        SizedBox(height: height * 0.04),

                        const Text(
                          'Enter Verification code',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'أدخل رمز التحقق المرسل إلى رقم هاتفك لإتمام تسجيل الدخول',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 30),

                        // حقول الإدخال
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
                                  color: _isFilled
                                      ? AppColors.secondary
                                      : Colors.black,
                                ),
                                decoration: InputDecoration(
                                  counterText: '',
                                  filled: true,
                                  fillColor: _isFilled
                                      ? AppColors.secondary.withOpacity(0.2)
                                      : Colors.grey.shade100,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: _isFilled
                                          ? AppColors.secondary
                                          : Colors.grey.shade400,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: _isFilled
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

                        // زر التأكيد
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isFilled ? () {} : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isFilled
                                  ? AppColors.secondary
                                  : Colors.grey.shade300,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                color: _isFilled
                                    ? Colors.white
                                    : Colors.grey.shade600,
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
                              for (var c in _controllers) {
                                c.clear();
                              }
                              _focusNodes[0].requestFocus();
                              _startTimer();
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

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
