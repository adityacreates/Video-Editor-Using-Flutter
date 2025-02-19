import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Import file_picker
import 'package:video_player/video_player.dart';
import '../services/video_processor.dart';
import 'dart:io'; // Import dart:io for File class

class MergeToolScreen extends StatefulWidget {
  const MergeToolScreen({Key? key}) : super(key: key);

  @override
  State<MergeToolScreen> createState() => _MergeToolScreenState();
}

class _MergeToolScreenState extends State<MergeToolScreen> {
  List<String> videoPaths = [];
  List<VideoPlayerController> videoControllers = [];
  bool _isMerging = false;

  Future<void> _pickVideos() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video, // Use FileType from file_picker
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        videoPaths = result.paths.map((path) => path!).toList();
        _initializeVideoControllers();
      });
    }
  }

  void _initializeVideoControllers() {
    for (var path in videoPaths) {
      final controller = VideoPlayerController.file(File(path)); // Use File from dart:io
      controller.initialize().then((_) {
        setState(() {});
      });
      videoControllers.add(controller);
    }
  }

  Future<void> _mergeVideos() async {
    if (videoPaths.isEmpty) return;

    setState(() {
      _isMerging = true;
    });

    try {
      final String? outputPath = await VideoProcessor().mergeVideos(videoPaths);

      if (outputPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Videos merged successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to merge videos')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isMerging = false;
      });
    }
  }

  @override
  void dispose() {
    for (var controller in videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Merge Videos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickVideos,
              child: const Text('Select Videos'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: videoPaths.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ListTile(
                        title: Text(videoPaths[index]),
                      ),
                      if (videoControllers[index].value.isInitialized)
                        AspectRatio(
                          aspectRatio: videoControllers[index].value.aspectRatio,
                          child: VideoPlayer(videoControllers[index]),
                        ),
                    ],
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _isMerging ? null : _mergeVideos,
              child: _isMerging
                  ? const CircularProgressIndicator()
                  : const Text('Merge Videos'),
            ),
          ],
        ),
      ),
    );
  }
}