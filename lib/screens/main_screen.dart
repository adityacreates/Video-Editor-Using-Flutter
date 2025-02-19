import 'package:flutter/material.dart';
import 'merge_tool_screen.dart';
import 'settings_screen.dart';
import 'audio_tool_screen.dart';
import 'subtitles_tool_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isDarkMode = false;

  final List<Map<String, dynamic>> _videoTools = [
  {
    'icon': Icons.cut_rounded,
    'label': 'Trim',
    'onTap': (BuildContext context) {
      // TODO: Implement trim functionality
    },
  },
  {
    'icon': Icons.merge_type_rounded,
    'label': 'Merge',
    'onTap': (BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MergeToolScreen()),
      );
    },
  },
  {
    'icon': Icons.filter_rounded,
    'label': 'Filters',
    'onTap': (BuildContext context) {
      // TODO: Implement filters functionality
    },
  },
  {
    'icon': Icons.animation_rounded,
    'label': 'Effects',
    'onTap': (BuildContext context) {
      // TODO: Implement effects functionality
    },
  },
  {
    'icon': Icons.music_note_rounded,
    'label': 'Audio',
    'onTap': (BuildContext context) {
      // Navigate to AudioToolsScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AudioToolScreen(videoPath: 'path/to/video')),
      );
    },
  },
  {
    'icon': Icons.subtitles_rounded,
    'label': 'Subtitles',
    'onTap': (BuildContext context) {
      // Navigate to SubtitlesToolsScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SubtitlesToolScreen(videoPath: 'path/to/video')),
      );
    },
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
          onPressed: () {
            // TODO: Implement new project creation
          },
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
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
