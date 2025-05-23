import 'package:flutter/material.dart';

class AuctionTimer extends StatefulWidget {
  final Color accentColor;
  final bool isDark;

  const AuctionTimer({
    super.key,
    required this.accentColor,
    required this.isDark,
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
      target = _nextWeekdayTime(DateTime.monday, 18); // الإثنين 6 مساءً
    } else if (now.weekday >= DateTime.tuesday) {
      target = _nextWeekdayTime(DateTime.thursday, 18); // الخميس 6 مساءً
    } else {
      // يوم الإثنين قبل 6 مساءً => نعد لـ الاثنين 6 مساءً
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
    final hours = _timeLeft.inHours;
    final minutes = _timeLeft.inMinutes % 60;
    final seconds = _timeLeft.inSeconds % 60;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTimerUnit(hours.toString().padLeft(2, '0'), 'HRS'),
          _buildTimerSeparator(),
          _buildTimerUnit(minutes.toString().padLeft(2, '0'), 'MIN'),
          _buildTimerSeparator(),
          _buildTimerUnit(seconds.toString().padLeft(2, '0'), 'SEC', isLast: true),
        ],
      ),
    );
  }

  Widget _buildTimerUnit(String value, String label, {bool isLast = false}) {
    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isDark
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
          color: widget.isDark ? Colors.grey.shade800 : Colors.grey.shade300,
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
                  : (widget.isDark ? Colors.white : Colors.black87),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: widget.isDark
                  ? Colors.grey.shade400
                  : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: widget.isDark
              ? Colors.grey.shade300
              : Colors.grey.shade700,
        ),
      ),
    );
  }
}
