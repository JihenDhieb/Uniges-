// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
//import 'package:share_plus/share_plus.dart';

class DrawingBoard extends StatefulWidget {
  final Uint8List backgroundImage;

  const DrawingBoard({super.key, required this.backgroundImage});

  @override
  _DrawingBoardState createState() => _DrawingBoardState();
}

class _DrawingBoardState extends State<DrawingBoard> {
  Color selectedColor = Colors.black;
  double strokeWidth = 5;
  List<DrawingPoint>? drawingPoints = [];
  ScreenshotController screenshotController = ScreenshotController();
  List<Color> colors = [
    Colors.pink,
    Colors.red,
    Colors.black,
    Colors.yellow,
    Colors.amberAccent,
    Colors.purple,
    Colors.green,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Expanded(
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  color: Colors.grey[200],
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                        side: const BorderSide(
                                            color: Colors.red)))),
                            onPressed: () => setState(() => drawingPoints = []),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text(
                              "Clear",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              colors.length,
                              (index) => _buildColorChose(colors[index]),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text("Size Pen"),
                          const SizedBox(
                            width: 15,
                          ),
                          Slider(
                            min: 2,
                            max: 20,
                            value: strokeWidth,
                            onChanged: (val) =>
                                setState(() => strokeWidth = val),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _screenshot(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          height: 60,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                    style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: const BorderSide(
                                        color: Color.fromARGB(
                                            255, 255, 255, 255))))),
                    label: const Text("Share"),
                    onPressed: () async {
                      String path = "";
                      final image = await screenshotController
                          .captureFromWidget(_screenshot());

                      path = await saveImage(image);

                      saveAndShare(image, path);
                    },
                    icon: const Icon(Icons.share_outlined)),
                const SizedBox(
                  width: 50,
                ),
                ElevatedButton.icon(
                    label: const Text("Save"),
                    style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: const BorderSide(
                                        color: Color.fromARGB(
                                            255, 255, 255, 255))))),
                    onPressed: () async {
                      final image = await screenshotController
                          .captureFromWidget(_screenshot());

                      await saveImage(image);
                      Get.showSnackbar(
                        const GetSnackBar(
                          title: "Image Saved !",
                          message: 'Image Saved Successfully',
                          icon: Icon(Icons.save_alt),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    },
                    icon: const Icon(Icons.save_alt_rounded)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _screenshot() {
    ImageProvider<Object> imageProvider = MemoryImage(widget.backgroundImage);
    return SizedBox(
      height: 500,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.fill,
              ),
            ),
          ),
          GestureDetector(
            onPanStart: (details) {
              setState(() {
                drawingPoints!.add(
                  DrawingPoint(
                    details.localPosition,
                    Paint()
                      ..color = selectedColor
                      ..isAntiAlias = true
                      ..strokeWidth = strokeWidth
                      ..strokeCap = StrokeCap.round,
                  ),
                );
              });
            },
            onPanUpdate: (details) {
              setState(() {
                drawingPoints!.add(
                  DrawingPoint(
                    details.localPosition,
                    Paint()
                      ..color = selectedColor
                      ..isAntiAlias = true
                      ..strokeWidth = strokeWidth
                      ..strokeCap = StrokeCap.round,
                  ),
                );
              });
            },
            onPanEnd: (details) {
              setState(() {
                drawingPoints!.add(DrawingPoint.empty());
              });
            },
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return CustomPaint(
                  painter: _DrawingPainter(drawingPoints!),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      height: constraints.maxHeight,
                      width: constraints.maxWidth,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorChose(Color color) {
    bool isSelected = selectedColor == color;
    return GestureDetector(
      onTap: () => setState(() => selectedColor = color),
      child: Container(
        height: isSelected ? 47 : 40,
        width: isSelected ? 47 : 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
        ),
      ),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<DrawingPoint> drawingPoints;

  _DrawingPainter(this.drawingPoints);

  List<Offset> offsetsList = [];

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < drawingPoints.length - 1; i++) {
      if (drawingPoints[i].offset != null &&
          drawingPoints[i + 1].offset != null) {
        canvas.drawLine(
          drawingPoints[i].offset!,
          drawingPoints[i + 1].offset!,
          drawingPoints[i].paint!,
        );
      } else if (drawingPoints[i].offset != null &&
          drawingPoints[i + 1].offset == null) {
        offsetsList.clear();
        offsetsList.add(drawingPoints[i].offset!);

        canvas.drawPoints(
          PointMode.points,
          offsetsList,
          drawingPoints[i].paint!,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DrawingPoint {
  Offset? offset;
  Paint? paint;

  DrawingPoint(this.offset, this.paint);

  static DrawingPoint empty() {
    return DrawingPoint(null, null);
  }
}

Future<String> saveImage(Uint8List bytes) async {
  await [Permission.storage].request();
  final time = DateTime.now()
      .toIso8601String()
      .replaceAll('.', '-')
      .replaceAll(':', '-');
  final name = 'screenshot_$time';
  await ImageGallerySaver.saveImage(bytes, name: name);
  return name;
}

Future saveAndShare(Uint8List bytes, name) async {
  final directory = await getApplicationDocumentsDirectory();
  final image = File('${directory.path}/$name.jpg');
  image.writeAsBytesSync(bytes);
  await Share.shareXFiles([XFile(image.path)]);
}
