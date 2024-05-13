import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthPickerWidget extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  MonthPickerWidget({required this.onDateSelected});

  @override
  _MonthPickerWidgetState createState() => _MonthPickerWidgetState();
}

class _MonthPickerWidgetState extends State<MonthPickerWidget> {
  DateTime selectedDate = DateTime.now();

  void _changeMonth(int increment) {
    setState(() {
      selectedDate =
          DateTime(selectedDate.year, selectedDate.month + increment, 1);
      widget.onDateSelected(selectedDate);
    });
  }

  String getFormattedDate(DateTime date) {
    return DateFormat.yMMMM().format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => _changeMonth(-1),
          ),
          Text(
            getFormattedDate(selectedDate),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
    );
  }
}
