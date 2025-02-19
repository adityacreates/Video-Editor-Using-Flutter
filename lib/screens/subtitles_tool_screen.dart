import 'package:flutter/material.dart';
import '../services/video_processor.dart';

class SubtitlesToolScreen extends StatefulWidget {
  final String videoPath;

  const SubtitlesToolScreen({Key? key, required this.videoPath}) : super(key: key);

  @override
  State<SubtitlesToolScreen> createState() => _SubtitlesToolScreenState();
}

class _SubtitlesToolScreenState extends State<SubtitlesToolScreen> {
  final TextEditingController _textController = TextEditingController();
  double startTime = 0.0;
  bool _isProcessing = false;

  Future<void> _addSubtitles() async {
    if (_textController.text.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final String? outputPath = await VideoProcessor().addSubtitles(
        widget.videoPath,
        _textController.text,
        startTime,
      );

      if (outputPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subtitles added successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add subtitles')),
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
        title: const Text('Add Subtitles'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(labelText: 'Subtitles Text'),
            ),
            const SizedBox(height: 16),
            Slider(
              value: startTime,
              min: 0.0,
              max: 60.0,
              onChanged: (value) {
                setState(() {
                  startTime = value;
                });
              },
            ),
            Text('Start Time: ${startTime.toStringAsFixed(2)}s'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isProcessing ? null : _addSubtitles,
              child: _isProcessing
                  ? const CircularProgressIndicator()
                  : const Text('Add Subtitles'),
            ),
          ],
        ),
      ),
    );
  }
}