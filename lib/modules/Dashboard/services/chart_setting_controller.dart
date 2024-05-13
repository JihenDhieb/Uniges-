import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ChartSettingsController extends GetxController {
  var selectedGradient = Rx<Gradient>(const LinearGradient(
    colors: [Colors.blue, Colors.green],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ));
  var barWidth = 30.0.obs;
  var isYAxisVisible = true.obs;
  var isXAxisVisible = true.obs;
  var isRainbow = false.obs;
  var aspectRatio = 1.2.obs;
  List<Color> barColors = [
    const Color(0xFF176BA0),
    const Color(0xFF1AC9E6),
    const Color(0xFF1DE4BD),
    const Color(0xFF7D3AC1),
    const Color(0xFFDB4CB2),
    const Color(0xFFEA7369),
    const Color(0xFFC02323),
    const Color(0xFFEF7E32),
    const Color(0xFFEABD3B),
    const Color(0xFF176BA0),
    const Color(0xFF1AC9E6),
    const Color(0xFF1DE4BD),
  ];
  @override
  void onInit() {
    super.onInit();
    loadSettingChartStorage();
  }

  void saveSettings() {
    GetStorage().write('selectedGradient', selectedGradient.value.toString());
    GetStorage().write('isYAxisVisible', isYAxisVisible.value);
    GetStorage().write('isXAxisVisible', isXAxisVisible.value);
    GetStorage().write('barWidth', barWidth.value);
    GetStorage().write('aspectRatio', aspectRatio.value);
  }

  void loadSettingChartStorage() {
    var savedGradient = GetStorage().read<String>('selectedGradient');
    if (savedGradient != null && savedGradient.startsWith('LinearGradient')) {
      // Extract color codes from the string
      final List<int> colorCodes = savedGradient
          .replaceAll(
              'LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(',
              '')
          .replaceAll('), Color(', ',')
          .replaceAll(')], tileMode: TileMode.clamp)', '')
          .split(',')
          .map(int.parse)
          .toList();

      if (colorCodes.length == 2) {
        selectedGradient.value = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(colorCodes[0]),
            Color(colorCodes[1]),
          ],
          tileMode: TileMode.clamp,
        );
      }
    }

    isYAxisVisible.value = GetStorage().read<bool>('isYAxisVisible') ?? true;
    isXAxisVisible.value = GetStorage().read<bool>('isXAxisVisible') ?? true;
    barWidth.value = GetStorage().read<double>('barWidth') ?? 30.0;
    aspectRatio.value = GetStorage().read<double>('aspectRatio') ?? 1.2;
  }
}
