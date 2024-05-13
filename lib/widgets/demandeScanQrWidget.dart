import 'dart:async';

import 'package:flutter/material.dart';

class DemandeScanQrCodewidget extends StatefulWidget {
  final Function onBtnCameraClick;
  final String title;
  final String decription;

  DemandeScanQrCodewidget(
      {super.key,
      required this.onBtnCameraClick,
      required this.title,
      required this.decription});
  @override
  _DemandeScanQrCodewidgetState createState() =>
      _DemandeScanQrCodewidgetState();
}

class _DemandeScanQrCodewidgetState extends State<DemandeScanQrCodewidget> {
  bool _isVisible = true;
  late Timer _timer;
  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      setState(() {
        _isVisible = !_isVisible;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: 120,
            color: (_isVisible)
                ? const Color.fromARGB(211, 244, 67, 54)
                : const Color.fromARGB(110, 244, 67, 54),
          ),
          const SizedBox(height: 20),
          Text(
            widget.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            widget.decription,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          const Text(
            "Ou",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () => widget.onBtnCameraClick(),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Ouvrir Camera'),
          ),
        ],
      ),
    );
  }
}
