import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import '../services/video_processor.dart';
import 'dart:io';

// Define marker types for different editing operations
enum MarkerType {
  cut,
  textOverlay,
  audioTrack,
  subtitle,
}

// Marker class to store information about each edit point
class Marker {
  final Duration position;
  final MarkerType type;
  final String? label;

  const Marker({
    required this.position,
    required this.type,
    this.label,
  });
}

// Timeline widget to display video progress and markers
class VideoTimeline extends StatelessWidget {
  final VideoPlayerController controller;
  final List<Marker> markers;

  const VideoTimeline({
    Key? key,
    required this.controller,
    required this.markers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, VideoPlayerValue value, child) {
          final position = value.position;
          final duration = value.duration;
          final progress = duration.inMilliseconds > 0
              ? position.inMilliseconds / duration.inMilliseconds
              : 0.0;

          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Progress indicator
              Container(
                width: MediaQuery.of(context).size.width * progress,
                height: double.infinity,
                color: Colors.blue.withOpacity(0.5),
              ),
              
              // Time display
              Center(
                child: Text(
                  '${position.toString().split('.').first} / ${duration.toString().split('.').first}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              // Display markers
              ...markers.map((marker) => Positioned(
                left: _calculateMarkerPosition(marker.position, duration, context),
                child: _buildMarker(marker),
              )),
            ],
          );
        },
      ),
    );
  }

  // Calculate marker position on the timeline
  double _calculateMarkerPosition(Duration position, Duration totalDuration, BuildContext context) {
    final double totalWidth = MediaQuery.of(context).size.width - 32;
    return (position.inMilliseconds / totalDuration.inMilliseconds) * totalWidth;
  }

  // Build marker widget based on type
  Widget _buildMarker(Marker marker) {
    switch (marker.type) {
      case MarkerType.cut:
        return Container(
          width: 4,
          height: 40,
          color: Colors.red,
        );
      case MarkerType.textOverlay:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            marker.label ?? 'Text',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        );
      case MarkerType.audioTrack:
        return Container(
          width: 4,
          height: 40,
          color: Colors.green,
        );
      case MarkerType.subtitle:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            marker.label ?? 'Subtitle',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        );
    }
  }
}

// Main screen widget for video merging tool
class MergeToolScreen extends StatefulWidget {
  const MergeToolScreen({Key? key}) : super(key: key);

  @override
  State<MergeToolScreen> createState() => _MergeToolScreenState();
}

class _MergeToolScreenState extends State<MergeToolScreen> {
  // State variables for video management
  List<String> videoPaths = [];
  List<VideoPlayerController> videoControllers = [];
  List<List<Marker>> videoMarkers = [];
  int _selectedVideoIndex = 0;
  bool _isMerging = false;

  @override
  void initState() {
    super.initState();
    videoMarkers = [];
  }

  // Handle video selection using file picker
  Future<void> _pickVideos() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: true,
    );
    if (!mounted) return;
    if (result != null) {
      setState(() {
        videoPaths = result.paths.map((path) => path!).toList();
        videoMarkers = List.generate(videoPaths.length, (index) => []);
        _initializeVideoControllers();
      });
    }
  }

  // Initialize video controllers for selected videos
  void _initializeVideoControllers() {
    for (var controller in videoControllers) {
      controller.dispose();
    }
    videoControllers.clear();

    for (var path in videoPaths) {
      final controller = VideoPlayerController.file(File(path));
      controller.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
      videoControllers.add(controller);
    }
  }

  // Add a marker at the current position in the selected video
  void _addMarker(MarkerType type, {String? label}) {
    if (videoControllers.isEmpty || _selectedVideoIndex >= videoControllers.length) {
      return;
    }

    final controller = videoControllers[_selectedVideoIndex];
    final position = controller.value.position;

    setState(() {
      videoMarkers[_selectedVideoIndex].add(
        Marker(
          position: position,
          type: type,
          label: label,
        ),
      );
    });
  }

  // Process and merge selected videos
  Future<void> _mergeVideos() async {
    if (videoPaths.isEmpty) return;

    setState(() {
      _isMerging = true;
    });

    String? outputPath;
    Object? mergeError;

    try {
      outputPath = await VideoProcessor().mergeVideos(videoPaths);
    } catch (e) {
      mergeError = e;
    } finally {
      if (mounted) {
        setState(() {
          _isMerging = false;
        });
      }
    }

    if (!mounted) return;

    if (mergeError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${mergeError.toString()}')),
      );
    } else if (outputPath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Videos merged successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to merge videos')),
      );
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
            
            // Video timeline and marker controls
            if (videoControllers.isNotEmpty &&
                _selectedVideoIndex < videoControllers.length &&
                videoControllers[_selectedVideoIndex].value.isInitialized)
              Column(
                children: [
                  VideoTimeline(
                    controller: videoControllers[_selectedVideoIndex],
                    markers: videoMarkers.isNotEmpty 
                        ? videoMarkers[_selectedVideoIndex]
                        : [],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _addMarker(MarkerType.cut),
                        child: const Text('Add Cut'),
                      ),
                      ElevatedButton(
                        onPressed: () => _addMarker(
                          MarkerType.textOverlay,
                          label: 'Text Overlay',
                        ),
                        child: const Text('Add Text'),
                      ),
                      ElevatedButton(
                        onPressed: () => _addMarker(MarkerType.audioTrack),
                        child: const Text('Add Audio'),
                      ),
                      ElevatedButton(
                        onPressed: () => _addMarker(
                          MarkerType.subtitle,
                          label: 'Subtitle',
                        ),
                        child: const Text('Add Subtitle'),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 16),
            
            // Video list with previews
            Expanded(
              child: ListView.builder(
                itemCount: videoPaths.length,
                itemBuilder: (context, index) {
                  final bool isInitialized = index < videoControllers.length &&
                      videoControllers[index].value.isInitialized;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedVideoIndex = index;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedVideoIndex == index
                              ? Colors.blue
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(videoPaths[index]),
                            subtitle: Text(
                              '${videoMarkers.isNotEmpty ? videoMarkers[index].length : 0} markers',
                            ),
                          ),
                          if (isInitialized)
                            AspectRatio(
                              aspectRatio: videoControllers[index].value.aspectRatio,
                              child: VideoPlayer(videoControllers[index]),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Merge button
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
