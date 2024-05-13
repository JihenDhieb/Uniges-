import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'http_logs_details.dart';

class HttpLogsScreen extends StatefulWidget {
  @override
  _HttpLogsScreenState createState() => _HttpLogsScreenState();
}

class _HttpLogsScreenState extends State<HttpLogsScreen> {
  final box = GetStorage();
  List<dynamic> logs = [];
  void sendHttpLogsToGlitchTip() async {
    List<dynamic> filteredLogs =
        logs.takeWhile((log) => log.length > 3).take(3).toList();
    String formattedText = "Time ${DateTime.now().toString()}  ==>";
    for (var item in filteredLogs) {
      formattedText += "Type: ${item['type']}  \n";
      formattedText += "URL: ${item['url']}  \n";
      formattedText += "Timestamp: ${item['timestamp']}  \n";

      if (item.containsKey('body')) {
        formattedText += "Body:  \n";
        formattedText += prettyJson(item['body']);
      }
      formattedText += "*********************************";
    }

    await Sentry.captureException(Exception(formattedText));
  }

  @override
  Widget build(BuildContext context) {
    logs = box.read<List<dynamic>>('http_logs') ?? [];
    var objlogs = logs.reversed;
    logs = List.from(objlogs);
    return Scaffold(
      appBar: AppBar(
        title: const Text('HTTP Logs'),
        actions: [
          IconButton(
              onPressed: sendHttpLogsToGlitchTip, icon: const Icon(Icons.send))
        ],
      ),
      body: ListView.builder(
        //reverse: true,
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          Color statusColor;
          if (log['statusCode'] == null) {
            statusColor = Colors.white;
          } else if (log['statusCode'] >= 100 && log['statusCode'] <= 199) {
            statusColor = Colors.blue;
          } else if (log['statusCode'] >= 200 && log['statusCode'] <= 299) {
            statusColor = Colors.green;
          } else if (log['statusCode'] >= 300 && log['statusCode'] <= 399) {
            statusColor = Colors.yellow;
          } else if (log['statusCode'] >= 400 && log['statusCode'] <= 499) {
            statusColor = Colors.red;
          } else if (log['statusCode'] >= 500 && log['statusCode'] <= 599) {
            statusColor = const Color.fromARGB(255, 77, 7, 2);
          } else {
            statusColor = Colors.grey;
          }
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5.0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              leading: Icon(
                Icons.info,
                color: statusColor,
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(log['type'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              subtitle: Text(log['timestamp']),
              trailing: const Icon(Icons.arrow_forward),
              //tileColor: statusColor,
              onTap: () {
                Get.to(DetailsHttpLogs(log));
              },
            ),
          );
        },
      ),
    );
  }
}

String prettyJson(dynamic json) {
  var spaces = ' ' * 4;
  var encoder = JsonEncoder.withIndent(spaces);
  return encoder.convert(json);
}
