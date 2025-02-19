import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import '../services/video_processor.dart';
import '../widgets/video_timeline.dart';
import '../widgets/trim_slider.dart';

class TrimToolScreen extends StatefulWidget {
  final File videoFile;

  const TrimToolScreen({
    Key? key,
    required this.videoFile,
  }) : super(key: key);

  @override
  State<TrimToolScreen> createState() => _TrimToolScreenState();
}

class _TrimToolScreenState extends State<TrimToolScreen> {
  late VideoPlayerController _controller;
  final VideoProcessor _processor = VideoProcessor();
  bool _isPlaying = false;
  bool _isTrimming = false;
  double _startTrim = 0.0;
  double _endTrim = 0.0;
  
  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.file(widget.videoFile);
    await _controller.initialize();
    _endTrim = _controller.value.duration.inMilliseconds.toDouble();
    setState(() {});
  }

  Future<void> _trimVideo() async {
    if (_isTrimming) return;

    setState(() {
      _isTrimming = true;
    });

    try {
      final String? outputPath = await _processor.trimVideo(
        widget.videoFile.path,
        _startTrim / 1000, // Convert to seconds
        _endTrim / 1000,
      );

      if (outputPath != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video trimmed successfully!')),
        );
        // Return the trimmed video path to previous screen
        Navigator.pop(context, outputPath);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to trim video')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isTrimming = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trim Video'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isTrimming ? null : _trimVideo,
          ),
        ],
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          const SizedBox(height: 16),
          VideoTimeline(
            controller: _controller,
            onTrimChanged: (start, end) {
              setState(() {
                _startTrim = start;
                _endTrim = end;
              });
            },
          ),
          const SizedBox(height: 16),
          TrimSlider(
            controller: _controller,
            onTrimChanged: (start, end) {
              setState(() {
                _startTrim = start;
                _endTrim = end;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () {
                  setState(() {
                    _isPlaying = !_isPlaying;
                    _isPlaying ? _controller.play() : _controller.pause();
                  });
                },
              ),
              if (_isTrimming)
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}