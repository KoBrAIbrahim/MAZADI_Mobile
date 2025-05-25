import 'package:flutter/material.dart';

class AuctionTimer extends StatefulWidget {
  final Color accentColor;

  const AuctionTimer({
    super.key,
    required this.accentColor,
  });

  @override
  State<AuctionTimer> createState() => _AuctionTimerState();
}

class _AuctionTimerState extends State<AuctionTimer>
    with SingleTickerProviderStateMixin {
  late Duration _timeLeft;
  late final AnimationController _timerAnimController;

  @override
  void initState() {
    super.initState();
    _timeLeft = _getNextDeadlineDuration();

    _timerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_updateTimer);

    _timerAnimController.repeat();
  }

  void _updateTimer() {
    if (_timerAnimController.isCompleted) {
      if (_timeLeft.inSeconds > 0) {
        setState(() {
          _timeLeft = Duration(seconds: _timeLeft.inSeconds - 1);
        });
      }
      _timerAnimController
        ..reset()
        ..forward();
    }
  }

  Duration _getNextDeadlineDuration() {
    final now = DateTime.now();
    late DateTime target;

    if (now.weekday >= DateTime.friday) {
      target = _nextWeekdayTime(DateTime.monday, 18);
    } else if (now.weekday >= DateTime.tuesday) {
      target = _nextWeekdayTime(DateTime.thursday, 18);
    } else {
      final todayAt6 = DateTime(now.year, now.month, now.day, 18);
      target = now.isBefore(todayAt6)
          ? todayAt6
          : _nextWeekdayTime(DateTime.thursday, 18);
    }

    return target.difference(now);
  }

  DateTime _nextWeekdayTime(int weekday, int hour) {
    final now = DateTime.now();
    int daysUntil = (weekday - now.weekday + 7) % 7;
    if (daysUntil == 0 && now.hour >= hour) daysUntil = 7;
    return DateTime(now.year, now.month, now.day + daysUntil, hour);
  }

  @override
  void dispose() {
    _timerAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hours = _timeLeft.inHours;
    final minutes = _timeLeft.inMinutes % 60;
    final seconds = _timeLeft.inSeconds % 60;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTimerUnit(context, hours.toString().padLeft(2, '0'), 'HRS'),
          _buildTimerSeparator(context),
          _buildTimerUnit(context, minutes.toString().padLeft(2, '0'), 'MIN'),
          _buildTimerSeparator(context),
          _buildTimerUnit(context, seconds.toString().padLeft(2, '0'), 'SEC', isLast: true),
        ],
      ),
    );
  }

  Widget _buildTimerUnit(BuildContext context, String value, String label, {bool isLast = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [Colors.grey.shade900, Colors.grey.shade800]
              : [Colors.white, Colors.grey.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isLast && _timeLeft.inHours < 1
                  ? Colors.red
                  : (isDark ? Colors.white : Colors.black87),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSeparator(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
        ),
      ),
    );
  }
}
