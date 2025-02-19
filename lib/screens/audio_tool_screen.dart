import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/video_processor.dart';

class AudioToolScreen extends StatefulWidget {
  final String videoPath;

  const AudioToolScreen({Key? key, required this.videoPath}) : super(key: key);

  @override
  State<AudioToolScreen> createState() => _AudioToolScreenState();
}

class _AudioToolScreenState extends State<AudioToolScreen> {
  String? audioPath;
  double volume = 1.0;
  bool _isProcessing = false;

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      setState(() {
        audioPath = result.files.single.path;
      });
    }
  }

  Future<void> _addAudio() async {
    if (audioPath == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final String? outputPath = await VideoProcessor().addAudioTrack(
        widget.videoPath,
        audioPath!,
        volume,
      );

      if (outputPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio added successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add audio')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Audio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickAudio,
              child: const Text('Select Audio File'),
            ),
            const SizedBox(height: 16),
            if (audioPath != null) Text('Selected Audio: $audioPath'),
            const SizedBox(height: 16),
            Slider(
              value: volume,
              min: 0.0,
              max: 2.0,
              onChanged: (value) {
                setState(() {
                  volume = value;
                });
              },
            ),
            Text('Volume: ${volume.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isProcessing ? null : _addAudio,
              child: _isProcessing
                  ? const CircularProgressIndicator()
                  : const Text('Add Audio'),
            ),
          ],
        ),
      ),
    );
  }
}