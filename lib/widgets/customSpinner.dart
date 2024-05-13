import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomLogoSpinner extends StatelessWidget {
  final double size;

  const CustomLogoSpinner({Key? key, this.size = 60.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String logoImagePath = 'assets/icons/icon.png';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      width: size * 2,
      height: size,
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              logoImagePath,
              width: size * 0.5,
              height: size * 0.5,
            ),
            SizedBox(
              width: 5,
            ),
            SpinKitWave(
              color: Color.fromARGB(209, 33, 163, 243),
              size: 30.0,
            ),
          ],
        ),
      ),
    );
  }
}
