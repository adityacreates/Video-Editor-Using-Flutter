import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'merge_tool_screen.dart';
import 'settings_screen.dart';
import 'audio_tool_screen.dart';
import 'subtitles_tool_screen.dart';
import 'trim_tool_screen.dart';
import 'video_editor_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isDarkMode = false;

  // Helper: Navigate to Trim Tool Screen
  Future<void> _navigateToTrim() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (!mounted) return;
    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.first.path!);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TrimToolScreen(videoFile: file)),
      );
    }
  }

  // Helper: Navigate to Filters (Video Editor Screen with filter tool)
  Future<void> _navigateToFilters() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (!mounted) return;
    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.first.path!);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              VideoEditorScreen(videoFile: file, toolType: 'filter'),
        ),
      );
    }
  }

  // Helper: Navigate to Effects (Video Editor Screen with effects tool)
  Future<void> _navigateToEffects() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (!mounted) return;
    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.first.path!);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              VideoEditorScreen(videoFile: file, toolType: 'effects'),
        ),
      );
    }
  }

  // Helper: Navigate to Merge Tool Screen
  Future<void> _navigateToMerge() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MergeToolScreen()),
    );
  }

  // Helper: Navigate to Audio Tool Screen
  Future<void> _navigateToAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (!mounted) return;
    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.first.path!);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AudioToolScreen(videoPath: file.path),
        ),
      );
    }
  }

  // Helper: Navigate to Subtitles Tool Screen
  Future<void> _navigateToSubtitles() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (!mounted) return;
    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.first.path!);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubtitlesToolScreen(videoPath: file.path),
        ),
      );
    }
  }

  // Video tools definitions with onTap callbacks.
  late final List<Map<String, dynamic>> _videoTools = [
    {
      'icon': Icons.cut_rounded,
      'label': 'Trim',
      'onTap': _navigateToTrim,
    },
    {
      'icon': Icons.merge_type_rounded,
      'label': 'Merge',
      'onTap': _navigateToMerge,
    },
    {
      'icon': Icons.filter_rounded,
      'label': 'Filters',
      'onTap': _navigateToFilters,
    },
    {
      'icon': Icons.animation_rounded,
      'label': 'Effects',
      'onTap': _navigateToEffects,
    },
    {
      'icon': Icons.music_note_rounded,
      'label': 'Audio',
      'onTap': _navigateToAudio,
    },
    {
      'icon': Icons.subtitles_rounded,
      'label': 'Subtitles',
      'onTap': _navigateToSubtitles,
    },
  ];

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _showCompletedTasks() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Completed Tasks'),
        content: const Text('No completed tasks yet'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Stub for new project creation.
  void _createNewProject() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New project creation is not implemented yet')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.white,
          elevation: 0,
          title: Text(
            'VideoEditor',
            style: TextStyle(
              color: _isDarkMode ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.task_rounded),
              color: _isDarkMode ? Colors.white : Colors.black87,
              onPressed: _showCompletedTasks,
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: _isDarkMode ? Colors.grey[900] : Colors.blue,
                ),
                child: const Text(
                  'VideoEditor',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: _isDarkMode ? Colors.white : Colors.black87,
                ),
                title: Text(
                  _isDarkMode ? 'Light Theme' : 'Dark Theme',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                onTap: _toggleTheme,
              ),
              ListTile(
                leading: Icon(
                  Icons.settings,
                  color: _isDarkMode ? Colors.white : Colors.black87,
                ),
                title: Text(
                  'Settings',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Video',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: _videoTools.length,
                  itemBuilder: (context, index) {
                    return _buildToolButton(
                      icon: _videoTools[index]['icon'],
                      label: _videoTools[index]['label'],
                      onTap: _videoTools[index]['onTap'],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _createNewProject,
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: _isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: Colors.blue,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: _isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



