import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _highQualityExport = true;
  String _defaultExportFormat = 'mp4';
  bool _autoSaveEnabled = true;
  int _autoSaveInterval = 5;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highQualityExport = prefs.getBool('highQualityExport') ?? true;
      _defaultExportFormat = prefs.getString('defaultExportFormat') ?? 'mp4';
      _autoSaveEnabled = prefs.getBool('autoSaveEnabled') ?? true;
      _autoSaveInterval = prefs.getInt('autoSaveInterval') ?? 5;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('highQualityExport', _highQualityExport);
    await prefs.setString('defaultExportFormat', _defaultExportFormat);
    await prefs.setBool('autoSaveEnabled', _autoSaveEnabled);
    await prefs.setInt('autoSaveInterval', _autoSaveInterval);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('High Quality Export'),
            subtitle: const Text('Export videos in highest quality'),
            value: _highQualityExport,
            onChanged: (bool value) {
              setState(() {
                _highQualityExport = value;
                _saveSettings();
              });
            },
          ),
          ListTile(
            title: const Text('Default Export Format'),
            subtitle: Text(_defaultExportFormat.toUpperCase()),
            trailing: PopupMenuButton<String>(
              onSelected: (String value) {
                setState(() {
                  _defaultExportFormat = value;
                  _saveSettings();
                });
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'mp4',
                  child: Text('MP4'),
                ),
                const PopupMenuItem(
                  value: 'mov',
                  child: Text('MOV'),
                ),
                const PopupMenuItem(
                  value: 'avi',
                  child: Text('AVI'),
                ),
              ],
            ),
          ),
          SwitchListTile(
            title: const Text('Auto-Save'),
            subtitle: const Text('Automatically save project progress'),
            value: _autoSaveEnabled,
            onChanged: (bool value) {
              setState(() {
                _autoSaveEnabled = value;
                _saveSettings();
              });
            },
          ),
          ListTile(
            title: const Text('Auto-Save Interval'),
            subtitle: Text('$_autoSaveInterval minutes'),
            enabled: _autoSaveEnabled,
            trailing: DropdownButton<int>(
              value: _autoSaveInterval,
              onChanged: _autoSaveEnabled
                  ? (int? value) {
                      if (value != null) {
                        setState(() {
                          _autoSaveInterval = value;
                          _saveSettings();
                        });
                      }
                    }
                  : null,
              items: const [
                DropdownMenuItem(value: 1, child: Text('1 minute')),
                DropdownMenuItem(value: 5, child: Text('5 minutes')),
                DropdownMenuItem(value: 10, child: Text('10 minutes')),
                DropdownMenuItem(value: 15, child: Text('15 minutes')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}