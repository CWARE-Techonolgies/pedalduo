import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pedalduo/style/fonts_sizes.dart';
import 'package:provider/provider.dart';
import '../../../style/colors.dart';
import '../../../style/texts.dart';
import '../../../utils/app_utils.dart';
import '../models/tournament_data.dart';
import '../providers/brackets_provider.dart';

class ScheduleMatchDialog extends StatefulWidget {
  final MyMatch match;
  final String tournamentId;
  final DateTime tournamentStartDate;
  final DateTime tournamentEndDate;

  const ScheduleMatchDialog({
    super.key,
    required this.match,
    required this.tournamentId,
    required this.tournamentStartDate,
    required this.tournamentEndDate,
  });

  @override
  State<ScheduleMatchDialog> createState() => _ScheduleMatchDialogState();
}

class _ScheduleMatchDialogState extends State<ScheduleMatchDialog> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String selectedMatchType = 'one_set_6';
  bool isLoading = false;

  final Map<String, String> matchTypeDisplayNames = {
    'full_match': 'Full Match (3 Sets)',
    'one_set_6': '1 Set of 6',
    'one_set_9': '1 Set of 9',
  };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          color: AppColors.glassColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorderColor, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dialog Title
                  Text(
                    'Schedule Match',
                    style: AppTexts.emphasizedTextStyle(
                      context: context,
                      fontSize: AppFontSizes(context).size24,
                      textColor: AppColors.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Match ID: ${widget.match.id}',
                    style: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: AppColors.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Match Type Dropdown
                  Text(
                    'Match Type',
                    style: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: AppColors.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.glassLightColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.glassBorderColor,
                        width: 1,
                      ),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedMatchType,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: AppColors.textTertiaryColor,
                        ),
                      ),
                      dropdownColor: AppColors.darkSecondaryColor,
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.textPrimaryColor,
                      ),
                      items:
                          matchTypeDisplayNames.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(
                                entry.value,
                                style: AppTexts.bodyTextStyle(
                                  context: context,
                                  textColor: AppColors.textPrimaryColor,
                                ),
                              ),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedMatchType = newValue;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Date Selection
                  Text(
                    'Match Date',
                    style: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: AppColors.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.glassLightColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.glassBorderColor,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: AppColors.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            selectedDate != null
                                ? DateFormat(
                                  'MMM dd, yyyy',
                                ).format(selectedDate!)
                                : 'Select Date',
                            style: AppTexts.bodyTextStyle(
                              context: context,
                              textColor:
                                  selectedDate != null
                                      ? AppColors.textPrimaryColor
                                      : AppColors.textTertiaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Time Selection
                  Text(
                    'Match Time',
                    style: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: AppColors.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _selectTime,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.glassLightColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.glassBorderColor,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: AppColors.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            selectedTime != null
                                ? selectedTime!.format(context)
                                : 'Select Time',
                            style: AppTexts.bodyTextStyle(
                              context: context,
                              textColor:
                                  selectedTime != null
                                      ? AppColors.textPrimaryColor
                                      : AppColors.textTertiaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: AppColors.glassBorderColor,
                              ),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: AppTexts.bodyTextStyle(
                              context: context,
                              textColor: AppColors.textSecondaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _scheduleMatch,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child:
                              isLoading
                                  ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.whiteColor,
                                      ),
                                    ),
                                  )
                                  : Text(
                                    'Schedule Match',
                                    style: AppTexts.bodyTextStyle(
                                      context: context,
                                      textColor: AppColors.whiteColor,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    if (kDebugMode) {
      print('Tournament Start Date: ${widget.tournamentStartDate}');
      print('Tournament End Date: ${widget.tournamentEndDate}');
    }

    final DateTime? selectedDate = await _showCustomDatePicker();

    if (selectedDate != null) {
      // Validate date is within tournament period
      if (selectedDate.isBefore(widget.tournamentStartDate) ||
          selectedDate.isAfter(widget.tournamentEndDate)) {
        AppUtils.showFailureDialog(
          context,
          'Failed to Schedule Match',
          'Please select a date between ${DateFormat('MMM dd, yyyy').format(widget.tournamentStartDate)} and ${DateFormat('MMM dd, yyyy').format(widget.tournamentEndDate)}',
        );
        return;
      }

      setState(() {
        this.selectedDate = selectedDate;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? selectedTime = await _showCustomTimePicker();

    if (selectedTime != null) {
      setState(() {
        this.selectedTime = selectedTime;
      });
    }
  }

  Future<DateTime?> _showCustomDatePicker() async {
    return showDialog<DateTime>(
      context: context,
      builder:
          (context) => CustomDatePickerDialog(
            initialDate:
                widget.tournamentStartDate.isAfter(DateTime.now())
                    ? widget.tournamentStartDate
                    : DateTime.now(),
            firstDate: widget.tournamentStartDate,
            lastDate: widget.tournamentEndDate,
          ),
    );
  }

  Future<TimeOfDay?> _showCustomTimePicker() async {
    return showDialog<TimeOfDay>(
      context: context,
      builder:
          (context) => CustomTimePickerDialog(initialTime: TimeOfDay.now()),
    );
  }

  Future<void> _scheduleMatch() async {
    if (selectedDate == null || selectedTime == null) {
      AppUtils.showFailureDialog(
        context,
        'Failed to Schedule Match',
        'Please select both date and time for the match',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final DateTime combinedDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final String formattedDate = DateFormat(
      "yyyy-MM-dd'T'HH:mm:ss'Z'",
    ).format(combinedDateTime.toUtc());

    try {
      final success = await context.read<Brackets>().scheduleMatch(
        widget.match.id,
        formattedDate,
        widget.tournamentId,
        selectedMatchType,
      );

      if (mounted) {
        setState(() {
          isLoading = false;
        });

        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              decoration: BoxDecoration(
                color: AppColors.glassColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      success
                          ? 'Match scheduled successfully'
                          : 'Failed to schedule match',
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.textPrimaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        AppUtils.showFailureDialog(
          context,
          'Failed',
          'Error scheduling match: $e',
        );
      }
    }
  }
}

// Custom Date Picker Dialog
class CustomDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const CustomDatePickerDialog({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<CustomDatePickerDialog> createState() => _CustomDatePickerDialogState();
}

class _CustomDatePickerDialogState extends State<CustomDatePickerDialog> {
  late DateTime selectedDate;
  late DateTime displayedMonth;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    displayedMonth = DateTime(selectedDate.year, selectedDate.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
          color: AppColors.glassColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorderColor, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 20),

                  // Calendar Grid
                  _buildCalendarGrid(),
                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: _previousMonth,
          icon: Icon(
            Icons.chevron_left,
            color: AppColors.primaryColor,
            size: 28,
          ),
        ),
        Text(
          DateFormat('MMMM yyyy').format(displayedMonth),
          style: TextStyle(
            color: AppColors.textPrimaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          onPressed: _nextMonth,
          icon: Icon(
            Icons.chevron_right,
            color: AppColors.primaryColor,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassLightColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorderColor, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Days of week header
                _buildDaysOfWeekHeader(),
                const SizedBox(height: 12),

                // Calendar days
                _buildCalendarDays(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDaysOfWeekHeader() {
    const daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      children:
          daysOfWeek
              .map(
                (day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        color: AppColors.textSecondaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildCalendarDays() {
    final daysInMonth =
        DateTime(displayedMonth.year, displayedMonth.month + 1, 0).day;
    final firstDayOfWeek =
        DateTime(displayedMonth.year, displayedMonth.month, 1).weekday % 7;

    List<Widget> dayWidgets = [];

    // Add empty spaces for days before the first day of the month
    for (int i = 0; i < firstDayOfWeek; i++) {
      dayWidgets.add(const SizedBox());
    }

    // Add days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(displayedMonth.year, displayedMonth.month, day);
      final isSelected =
          date.day == selectedDate.day &&
          date.month == selectedDate.month &&
          date.year == selectedDate.year;
      final isEnabled =
          !date.isBefore(widget.firstDate) && !date.isAfter(widget.lastDate);

      dayWidgets.add(_buildDayWidget(day, date, isSelected, isEnabled));
    }

    // Create rows of 7 days each
    List<Widget> rows = [];
    for (int i = 0; i < dayWidgets.length; i += 7) {
      rows.add(
        Row(
          children: dayWidgets.sublist(
            i,
            i + 7 > dayWidgets.length ? dayWidgets.length : i + 7,
          ),
        ),
      );
      if (i + 7 < dayWidgets.length) {
        rows.add(const SizedBox(height: 8));
      }
    }

    return Column(children: rows);
  }

  Widget _buildDayWidget(
    int day,
    DateTime date,
    bool isSelected,
    bool isEnabled,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap:
            isEnabled
                ? () {
                  setState(() {
                    selectedDate = date;
                  });
                }
                : null,
        child: Container(
          height: 40,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border:
                isSelected
                    ? null
                    : Border.all(color: Colors.transparent, width: 1),
          ),
          child: Center(
            child: Text(
              day.toString(),
              style: TextStyle(
                color:
                    isEnabled
                        ? (isSelected
                            ? AppColors.whiteColor
                            : AppColors.textPrimaryColor)
                        : AppColors.textTertiaryColor,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.glassBorderColor),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondaryColor,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(selectedDate),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Select',
              style: TextStyle(
                color: AppColors.whiteColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _previousMonth() {
    setState(() {
      displayedMonth = DateTime(
        displayedMonth.year,
        displayedMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      displayedMonth = DateTime(
        displayedMonth.year,
        displayedMonth.month + 1,
        1,
      );
    });
  }
}

// Custom Time Picker Dialog
class CustomTimePickerDialog extends StatefulWidget {
  final TimeOfDay initialTime;

  const CustomTimePickerDialog({Key? key, required this.initialTime})
    : super(key: key);

  @override
  State<CustomTimePickerDialog> createState() => _CustomTimePickerDialogState();
}

class _CustomTimePickerDialogState extends State<CustomTimePickerDialog> {
  late int selectedHour;
  late int selectedMinute;
  late bool isAM;

  @override
  void initState() {
    super.initState();
    selectedHour = widget.initialTime.hourOfPeriod;
    if (selectedHour == 0) selectedHour = 12;
    selectedMinute = widget.initialTime.minute;
    isAM = widget.initialTime.period == DayPeriod.am;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          color: AppColors.glassColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorderColor, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    'Select Time',
                    style: TextStyle(
                      color: AppColors.textPrimaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Time Display
                  _buildTimeDisplay(),
                  const SizedBox(height: 32),

                  // Time Selectors
                  _buildTimeSelectors(),
                  const SizedBox(height: 32),

                  // Action Buttons
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.glassLightColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorderColor, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                selectedHour.toString().padLeft(2, '0'),
                style: TextStyle(
                  color: AppColors.textPrimaryColor,
                  fontSize: 36,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                ':',
                style: TextStyle(
                  color: AppColors.textPrimaryColor,
                  fontSize: 36,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                selectedMinute.toString().padLeft(2, '0'),
                style: TextStyle(
                  color: AppColors.textPrimaryColor,
                  fontSize: 36,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                isAM ? 'AM' : 'PM',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelectors() {
    return Row(
      children: [
        // Hour Selector
        Expanded(
          child: _buildWheelSelector(
            title: 'Hour',
            selectedValue: selectedHour,
            values: List.generate(12, (index) => index + 1),
            onChanged: (value) {
              setState(() {
                selectedHour = value;
              });
            },
          ),
        ),
        const SizedBox(width: 16),

        // Minute Selector
        Expanded(
          child: _buildWheelSelector(
            title: 'Minute',
            selectedValue: selectedMinute,
            values: List.generate(60, (index) => index),
            onChanged: (value) {
              setState(() {
                selectedMinute = value;
              });
            },
          ),
        ),
        const SizedBox(width: 16),

        // AM/PM Selector
        Expanded(child: _buildAMPMSelector()),
      ],
    );
  }

  Widget _buildWheelSelector({
    required String title,
    required int selectedValue,
    required List<int> values,
    required Function(int) onChanged,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textSecondaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.glassLightColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.glassBorderColor, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: ListWheelScrollView.useDelegate(
                itemExtent: 40,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (index) {
                  onChanged(values[index]);
                },
                controller: FixedExtentScrollController(
                  initialItem: values.indexOf(selectedValue),
                ),
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (context, index) {
                    if (index < 0 || index >= values.length) return null;
                    final value = values[index];
                    final isSelected = value == selectedValue;

                    return Center(
                      child: Text(
                        title == 'Minute'
                            ? value.toString().padLeft(2, '0')
                            : value.toString(),
                        style: TextStyle(
                          color:
                              isSelected
                                  ? AppColors.primaryColor
                                  : AppColors.textSecondaryColor,
                          fontSize: 18,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                  childCount: values.length,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAMPMSelector() {
    return Column(
      children: [
        Text(
          'Period',
          style: TextStyle(
            color: AppColors.textSecondaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.glassLightColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.glassBorderColor, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isAM = true;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color:
                              isAM
                                  ? AppColors.primaryColor.withOpacity(0.2)
                                  : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'AM',
                            style: TextStyle(
                              color:
                                  isAM
                                      ? AppColors.primaryColor
                                      : AppColors.textSecondaryColor,
                              fontSize: 18,
                              fontWeight:
                                  isAM ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(height: 1, color: AppColors.glassBorderColor),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isAM = false;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color:
                              !isAM
                                  ? AppColors.primaryColor.withOpacity(0.2)
                                  : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'PM',
                            style: TextStyle(
                              color:
                                  !isAM
                                      ? AppColors.primaryColor
                                      : AppColors.textSecondaryColor,
                              fontSize: 18,
                              fontWeight:
                                  !isAM ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.glassBorderColor),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondaryColor,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              final hour =
                  isAM
                      ? (selectedHour == 12 ? 0 : selectedHour)
                      : (selectedHour == 12 ? 12 : selectedHour + 12);

              final timeOfDay = TimeOfDay(hour: hour, minute: selectedMinute);
              Navigator.of(context).pop(timeOfDay);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Select',
              style: TextStyle(
                color: AppColors.whiteColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
