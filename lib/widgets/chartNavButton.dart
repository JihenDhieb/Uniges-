import 'package:flutter/material.dart';

Widget buildButtonChart(VoidCallback onPressed, String title, chartType) {
  IconData iconData;
  if (chartType.toString().toUpperCase() == 'BARCHART') {
    iconData = Icons.bar_chart;
  } else if (chartType.toUpperCase() == 'PIECHART') {
    iconData = Icons.pie_chart;
  } else if (chartType.toUpperCase() == 'LINECHART') {
    iconData = Icons.show_chart;
  } else {
    iconData = Icons.show_chart;
  }

  return ElevatedButton.icon(
    icon: Icon(iconData, color: Colors.white),
    onPressed: () => onPressed(),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 148, 87, 245),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 24.0,
      ),
    ),
    label: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
