import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uniges/modules/settings/http_logs_list.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Widget _buildSettingsList(var settings) {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          width: double.maxFinite,
          child: ElevatedButton.icon(
              onPressed: () {
                Get.to(() => HttpLogsScreen());
              },
              icon: const Icon(Icons.warning_amber),
              label: const Text("Logs")),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: settings.length,
            itemBuilder: (context, index) {
              final setting = settings[index];
              return ExpansionTile(
                leading: setting['icon'] != null
                    ? Icon(
                        setting['icon'],
                        color: Colors.blue,
                      )
                    : null,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      setting['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (setting['description'] != null)
                      Text(
                        setting['description'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
                children: _buildSettingChildren(setting['children']),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSettingChildren(List<Map<String, dynamic>> children) {
    List<Widget> widgets = [];
    for (var child in children) {
      if (child.containsKey('children')) {
        widgets.add(ExpansionTile(
          leading: child['icon'] != null
              ? Icon(
                  child['icon'],
                  color: Colors.blue,
                )
              : null,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                child['name'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (child['description'] != null)
                Text(
                  child['description'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
          children: _buildSettingChildren(child['children']),
        ));
      } else {
        widgets.add(ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Text(
            child['name'],
            style: const TextStyle(fontSize: 16),
          ),
          subtitle: child['description'] != null
              ? Text(
                  child['description'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                )
              : null,
          trailing: Text(
            child['value'],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          onTap: () {
            _showInputDialog();
          },
        ));
      }
    }
    return widgets;
  }

  var defaultListSetting = [];
  /* var defaultListSetting = [
    {
      "name": "WMS",
      "description": "Warehouse Management System",
      "icon": Icons.storage,
      "children": [
        {
          "name": "Réception",
          "description": "Reception settings",
          "children": [
            {
              "name": "Site Code",
              "value": "SFX",
              "description": "Site code for reception"
            },
            {
              "name": "OFS Param Code",
              "value": "SOF",
              "description": "OFS parameter code for reception"
            },
          ]
        }
      ]
    },
    {
      "name": "DASHBOARD",
      "description": "Dashboard settings",
      "icon": Icons.dashboard,
      "children": [
        {
          "name": "GENERAL",
          "description": "General dashboard settings",
          "children": [
            {
              "name": "Chart Color",
              "value": "red",
              "description": "Color for charts"
            },
          ]
        }
      ]
    },
    {
      "name": "Finance",
      "description": "Finance Param",
      "icon": Icons.monetization_on,
      "children": [
        {
          "name": "Chart Color",
          "value": "red",
          "description": "Color for charts"
        },
      ]
    }
  ];
*/
  void _showInputDialog() {
    TextEditingController valueController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Setting'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text("field"),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(labelText: 'Value'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings Page'),
      ),
      body: _buildSettingsList(defaultListSetting),
    );
  }
}
