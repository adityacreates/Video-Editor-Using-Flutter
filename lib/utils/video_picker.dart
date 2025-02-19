import 'package:flutter/material.dart';
import 'dart:io';  // Make sure to import this for File

class VideoEditorScreen extends StatefulWidget {
  final File videoFile;  // Changed from XFile to File
  final String toolType;

  const VideoEditorScreen({
    super.key,
    required this.videoFile,
    required this.toolType,
  });

  @override
  State<VideoEditorScreen> createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Editor'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // You can now use widget.videoFile directly
            // Example of how to get the path:
            Text('Video path: ${widget.videoFile.path}'),
            Text('Tool type: ${widget.toolType}'),
            // Add your video editing UI here
          ],
        ),
      ),
    );
  }
}
