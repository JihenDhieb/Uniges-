import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:uniges/modules/Dashboard/services/chart_setting_controller.dart';

class SettingsChartScreen extends StatelessWidget {
  final ChartSettingsController _controller =
      Get.put(ChartSettingsController());
  final List<Map<String, String>> gradientOptions = [
    {'label': '1', 'startColor': '#FF5733', 'endColor': '#FFC300'},
    {'label': '2', 'startColor': '#6A0572', 'endColor': '#AB83A1'},
    {'label': '3', 'startColor': '#24C6DC', 'endColor': '#514A9D'},
    {'label': '4', 'startColor': '#DA4453', 'endColor': '#89216B'},
  ];

  SettingsChartScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Enregistrer'),
        icon: const Icon(Icons.save),
        onPressed: () {
          _controller.saveSettings();
          Get.back();
          Get.snackbar('Settings enregistrer',
              'Your settings have been saved successfully!');
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Gradient Color:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildGradientOptions(),
              _buildRainbowBow(),
              _buildSliderWidget('Bar Width', _controller.barWidth, 20, 50),
              _buildSliderWidget(
                  'Aspect Ratio', _controller.aspectRatio, 0.5, 3),
              _buildSwitchRow('Y-Axis Visibility', _controller.isYAxisVisible),
              _buildSwitchRow('X-Axis Visibility', _controller.isXAxisVisible),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRainbowBow() {
    return Obx(() => GestureDetector(
          onTap: () {
            _controller.isRainbow.value = !_controller.isRainbow.value;
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              //width: 70.0,
              height: 60.0,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Colors.red,
                    Colors.orange,
                    Colors.yellow,
                    Colors.green,
                    Colors.blue,
                    Colors.indigo,
                    Colors.purple,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: (_controller.isRainbow.value)
                    ? Border.all(width: 3, color: Colors.blue)
                    : Border.all(width: 0),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: const Center(
                child: Text(
                  'Multi Color',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  Widget _buildSliderWidget(
      String title, RxDouble valueVariable, double min, double max) {
    return Obx(() => _buildSettingRow(
        title,
        Slider(
          value: valueVariable.value,
          onChanged: (value) {
            valueVariable.value = value;
          },
          min: min,
          max: max,
        ),
        valueVariable.value));
  }

  Widget _buildSettingRow(String title, Widget settingWidget, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$title : ${value.toStringAsFixed(1)}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 16),
        settingWidget,
      ],
    );
  }

  Widget _buildSwitchRow(String title, RxBool valueVariable) {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            Switch(
              value: valueVariable.value,
              onChanged: (value) {
                valueVariable.value = value;
              },
            ),
          ],
        ));
  }

  Widget _buildGradientOptions() {
    return Wrap(
      children: [
        for (var option in gradientOptions)
          GestureDetector(
            onTap: () {
              _controller.selectedGradient.value = LinearGradient(
                colors: [
                  Color(int.parse(option['startColor']!.substring(1, 7),
                          radix: 16) +
                      0xFF000000),
                  Color(int.parse(option['endColor']!.substring(1, 7),
                          radix: 16) +
                      0xFF000000),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              );
              _controller.isRainbow.value = false;
            },
            child: Container(
              width: 70,
              margin: const EdgeInsets.all(8),
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [
                    Color(int.parse(option['startColor']!.substring(1, 7),
                            radix: 16) +
                        0xFF000000),
                    Color(int.parse(option['endColor']!.substring(1, 7),
                            radix: 16) +
                        0xFF000000),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  option['label'].toString(),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
