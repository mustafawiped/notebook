import 'package:flutter/material.dart';
import 'package:notebook/utils/constants/app_colors.dart';

class BottomDatePicker extends StatefulWidget {
  final Function(DateTime) onConfirm;
  final DateTime? initialDate;

  const BottomDatePicker({
    super.key,
    required this.onConfirm,
    this.initialDate,
  });

  static Future<void> show(
    BuildContext context, {
    required Function(DateTime) onConfirm,
    DateTime? initialDate,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          BottomDatePicker(onConfirm: onConfirm, initialDate: initialDate),
    );
  }

  @override
  State<BottomDatePicker> createState() => _BottomDatePickerState();
}

class _BottomDatePickerState extends State<BottomDatePicker> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;
  late int _selectedHour;
  late int _selectedMinute;
  late bool _isAM;

  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  int get _currentYear => DateTime.now().year;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialDate ?? DateTime.now();
    _selectedYear = initial.year;
    _selectedMonth = initial.month;
    _selectedDay = initial.day;
    _isAM = initial.hour < 12;
    _selectedHour = initial.hour % 12 == 0 ? 12 : initial.hour % 12;
    _selectedMinute = initial.minute;
  }

  int get _daysInMonth =>
      DateUtils.getDaysInMonth(_selectedYear, _selectedMonth);

  DateTime get _result {
    int hour = _isAM
        ? (_selectedHour == 12 ? 0 : _selectedHour)
        : (_selectedHour == 12 ? 12 : _selectedHour + 12);
    return DateTime(
      _selectedYear,
      _selectedMonth,
      _selectedDay.clamp(1, _daysInMonth),
      hour,
      _selectedMinute,
    );
  }

  Widget _buildPicker({
    required int itemCount,
    required int selectedIndex,
    required String Function(int) labelBuilder,
    required ValueChanged<int> onChanged,
    required double width,
  }) {
    final controller = FixedExtentScrollController(initialItem: selectedIndex);
    return SizedBox(
      width: width,
      height: 180,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 44,
        diameterRatio: 1.4,
        perspective: 0.003,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: itemCount,
          builder: (context, index) {
            final isSelected = index == selectedIndex;
            return Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isSelected ? 18 : 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.white38,
                ),
                child: Text(labelBuilder(index)),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAMPMPicker({required double width}) {
    return SizedBox(
      width: width,
      height: 180,
      child: ListWheelScrollView(
        itemExtent: 44,
        diameterRatio: 1.4,
        perspective: 0.003,
        physics: const FixedExtentScrollPhysics(),
        controller: FixedExtentScrollController(initialItem: _isAM ? 0 : 1),
        onSelectedItemChanged: (i) => setState(() => _isAM = i == 0),
        children: ['AM', 'PM'].map((label) {
          final isSelected =
              (_isAM && label == 'AM') || (!_isAM && label == 'PM');
          return Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isSelected ? 18 : 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.white38,
              ),
              child: Text(label),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 20),

          // Title
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Pick a complete date",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Picker alanı
          Stack(
            alignment: Alignment.center,
            children: [
              // Seçili satır highlight
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              // Picker'lar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Yıl
                  _buildPicker(
                    itemCount: 20, // sadece ileriye, 20 yıl
                    selectedIndex: _selectedYear - _currentYear,
                    labelBuilder: (i) => '${_currentYear + i}',
                    onChanged: (i) => setState(() {
                      _selectedYear = _currentYear + i;
                      _selectedDay = _selectedDay.clamp(1, _daysInMonth);
                    }),
                    width: screenWidth * 0.16,
                  ),

                  SizedBox(width: screenWidth * 0.01),

                  // Ay
                  _buildPicker(
                    itemCount: 12,
                    selectedIndex: _selectedMonth - 1,
                    labelBuilder: (i) => _months[i],
                    onChanged: (i) => setState(() {
                      _selectedMonth = i + 1;
                      _selectedDay = _selectedDay.clamp(1, _daysInMonth);
                    }),
                    width: screenWidth * 0.20,
                  ),

                  SizedBox(width: screenWidth * 0.01),

                  // Gün
                  _buildPicker(
                    itemCount: _daysInMonth,
                    selectedIndex: (_selectedDay - 1).clamp(
                      0,
                      _daysInMonth - 1,
                    ),
                    labelBuilder: (i) => '${i + 1}',
                    onChanged: (i) => setState(() => _selectedDay = i + 1),
                    width: screenWidth * 0.10,
                  ),

                  SizedBox(width: screenWidth * 0.02),

                  // Saat
                  _buildPicker(
                    itemCount: 12,
                    selectedIndex: _selectedHour - 1,
                    labelBuilder: (i) => '${i + 1}'.padLeft(2, '0'),
                    onChanged: (i) => setState(() => _selectedHour = i + 1),
                    width: screenWidth * 0.10,
                  ),

                  Text(
                    ":",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Dakika
                  _buildPicker(
                    itemCount: 60,
                    selectedIndex: _selectedMinute,
                    labelBuilder: (i) => '$i'.padLeft(2, '0'),
                    onChanged: (i) => setState(() => _selectedMinute = i),
                    width: screenWidth * 0.10,
                  ),

                  SizedBox(width: screenWidth * 0.02),

                  // AM/PM
                  _buildAMPMPicker(width: screenWidth * 0.12),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Confirm butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onConfirm(_result);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.text,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Confirm",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
