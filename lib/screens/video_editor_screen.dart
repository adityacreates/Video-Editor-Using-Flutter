import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'dart:math' show pi;

import '../utils/video_filters.dart';
import '../utils/video_effects.dart';
import '../services/video_processor.dart';

class TextOverlay {
  final String text;
  final Offset position;
  final Color color;
  final double fontSize;

  TextOverlay({
    required this.text,
    required this.position,
    required this.color,
    required this.fontSize,
  });

  TextOverlay copyWith({
    String? text,
    Offset? position,
    Color? color,
    double? fontSize,
  }) {
    return TextOverlay(
      text: text ?? this.text,
      position: position ?? this.position,
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}

class VideoEditorScreen extends StatefulWidget {
  final File videoFile;
  final String toolType; // 'trim', 'filter', 'effects', 'merge', 'audio', 'subtitles', 'text'

  const VideoEditorScreen({
    Key? key,
    required this.videoFile,
    required this.toolType,
  }) : super(key: key);

  @override
  State<VideoEditorScreen> createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  double _currentPosition = 0.0;
  double _startTrim = 0.0;
  double _endTrim = 1.0;
  
  List<double> _currentFilter = VideoFilters.normal;
  Matrix4? _currentEffect;
  List<TextOverlay> textOverlays = [];

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.file(widget.videoFile);
    await _controller.initialize();
    
    if (!mounted) return;
    
    _controller.addListener(() {
      if (!mounted) return;
      setState(() {
        _currentPosition = _controller.value.position.inSeconds.toDouble();
      });
    });
    
    setState(() {});
  }

  Widget _buildTextTool() {
    return Column(
      children: [
        Stack(
          children: [
            _buildVideoPreview(),
            ...textOverlays.map((textOverlay) {
              return Positioned(
                left: textOverlay.position.dx,
                top: textOverlay.position.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    if (!mounted) return;
                    setState(() {
                      final index = textOverlays.indexOf(textOverlay);
                      textOverlays[index] = textOverlay.copyWith(
                        position: textOverlay.position + details.delta,
                      );
                    });
                  },
                  onDoubleTap: () => _showTextEditingDialog(textOverlay),
                  child: Text(
                    textOverlay.text,
                    style: TextStyle(
                      color: textOverlay.color,
                      fontSize: textOverlay.fontSize,
                      shadows: const [
                        Shadow(
                          blurRadius: 3.0,
                          color: Colors.black,
                          offset: Offset(1.0, 1.0),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
        const SizedBox(height: 16),
        _buildVideoControls(showExport: true),
      ],
    );
  }

  void _addNewText() {
    if (!mounted) return;
    setState(() {
      textOverlays.add(
        TextOverlay(
          text: 'New Text',
          position: Offset(
            MediaQuery.of(context).size.width / 3,
            MediaQuery.of(context).size.height / 3,
          ),
          color: Colors.white,
          fontSize: 20,
        ),
      );
    });
  }

  Future<void> _showTextEditingDialog(TextOverlay overlay) async {
    if (!mounted) return;
    final BuildContext contextRef = context;
    final TextEditingController textController =
        TextEditingController(text: overlay.text);
    Color selectedColor = overlay.color;
    double selectedFontSize = overlay.fontSize;

    await showDialog(
      context: contextRef,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Edit Text'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: textController,
                    decoration: const InputDecoration(labelText: 'Text'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Size: '),
                      Expanded(
                        child: Slider(
                          value: selectedFontSize,
                          min: 10,
                          max: 100,
                          onChanged: (value) {
                            setDialogState(() {
                              selectedFontSize = value;
                            });
                            if (!mounted) return;
                            setState(() {
                              final index = textOverlays.indexOf(overlay);
                              textOverlays[index] =
                                  overlay.copyWith(fontSize: value);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      ...Colors.primaries.map((color) {
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedColor = color;
                            });
                            if (!mounted) return;
                            setState(() {
                              final index = textOverlays.indexOf(overlay);
                              textOverlays[index] =
                                  overlay.copyWith(color: color);
                            });
                          },
                          child: CircleAvatar(
                            backgroundColor: color,
                            radius: 15,
                            child: selectedColor == color
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 15)
                                : null,
                          ),
                        );
                      }),
                      GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedColor = Colors.white;
                          });
                          if (!mounted) return;
                          setState(() {
                            final index = textOverlays.indexOf(overlay);
                            textOverlays[index] =
                                overlay.copyWith(color: Colors.white);
                          });
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 15,
                          child: selectedColor == Colors.white
                              ? const Icon(Icons.check,
                                  color: Colors.black, size: 15)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (!mounted) return;
              setState(() {
                final index = textOverlays.indexOf(overlay);
                textOverlays[index] = overlay.copyWith(
                  text: textController.text,
                  color: selectedColor,
                  fontSize: selectedFontSize,
                );
              });
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrimTool() {
    return Column(
      children: [
        _buildVideoPreview(),
        const SizedBox(height: 16),
        Container(
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: SliderTheme(
            data: SliderThemeData(
              rangeThumbShape: const RoundRangeSliderThumbShape(
                enabledThumbRadius: 8,
              ),
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: Colors.blue,
              inactiveTrackColor: Colors.grey[300],
            ),
            child: RangeSlider(
              values: RangeValues(_startTrim, _endTrim),
              onChanged: (RangeValues values) {
                if (!mounted) return;
                setState(() {
                  _startTrim = values.start;
                  _endTrim = values.end;
                  final duration =
                      _controller.value.duration.inMilliseconds.toDouble();
                  _controller.seekTo(Duration(
                    milliseconds: (duration * _startTrim).toInt(),
                  ));
                });
              },
              min: 0.0,
              max: 1.0,
            ),
          ),
        ),
        _buildVideoControls(showExport: true),
      ],
    );
  }

  Widget _buildFilterTool() {
    return Column(
      children: [
        _buildVideoPreview(),
        const SizedBox(height: 16),
        _buildFilterOptions(),
        _buildVideoControls(showReset: true),
      ],
    );
  }

  Widget _buildEffectsTool() {
    return Column(
      children: [
        _buildVideoPreview(),
        const SizedBox(height: 16),
        _buildEffectOptions(),
        _buildVideoControls(showReset: true),
      ],
    );
  }

  Widget _buildVideoPreview() {
    return Transform(
      transform: _currentEffect ?? Matrix4.identity(),
      alignment: Alignment.center,
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix(_currentFilter),
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }

  Widget _buildVideoControls({bool showExport = false, bool showReset = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: () {
            if (!mounted) return;
            setState(() {
              _isPlaying = !_isPlaying;
              _isPlaying ? _controller.play() : _controller.pause();
            });
          },
        ),
        if (showExport)
          ElevatedButton(
            onPressed: _exportVideo,
            child: const Text('Export'),
          ),
        if (showReset)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetFiltersAndEffects,
          ),
      ],
    );
  }

  final List<Map<String, dynamic>> filters = [
    {'name': 'Normal', 'matrix': VideoFilters.normal, 'icon': Icons.filter_none},
    {'name': 'Grayscale', 'matrix': VideoFilters.grayscale, 'icon': Icons.filter_b_and_w},
    {'name': 'Sepia', 'matrix': VideoFilters.sepia, 'icon': Icons.filter_vintage},
    {'name': 'Vintage', 'matrix': VideoFilters.vintage, 'icon': Icons.filter_drama},
    {'name': 'Bright', 'matrix': VideoFilters.bright, 'icon': Icons.brightness_5},
  ];

  Widget _buildFilterOptions() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _currentFilter == filter['matrix'];
          
          return GestureDetector(
            onTap: () {
              if (!mounted) return;
              setState(() => _currentFilter = filter['matrix']);
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    filter['icon'],
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    filter['name'],
                    style: TextStyle(
                      color: isSelected ? Colors.blue : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  final List<Map<String, dynamic>> effects = [
    {'name': 'Rotate Right', 'transform': VideoEffects.rotate(pi / 2), 'icon': Icons.rotate_right},
    {'name': 'Flip H', 'transform': VideoEffects.flip(horizontal: true), 'icon': Icons.flip},
    {'name': 'Flip V', 'transform': VideoEffects.flip(vertical: true), 'icon': Icons.flip_camera_android},
    {'name': 'Zoom In', 'transform': VideoEffects.scale(1.5), 'icon': Icons.zoom_in},
    {'name': 'Zoom Out', 'transform': VideoEffects.scale(0.75), 'icon': Icons.zoom_out},
  ];

  Widget _buildEffectOptions() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: effects.length,
        itemBuilder: (context, index) {
          final effect = effects[index];
          
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                if (!mounted) return;
                setState(() {
                  _currentEffect = effect['transform'];
                });
              },
              icon: Icon(effect['icon']),
              label: Text(effect['name']),
            ),
          );
        },
      ),
    );
  }

  void _resetFiltersAndEffects() {
    if (!mounted) return;
    setState(() {
      _currentFilter = VideoFilters.normal;
      _currentEffect = null;
    });
  }

  Future<void> _exportVideo() async {
  if (!mounted) return;
  
  try {
    final String? outputPath = await VideoProcessor().trimVideo(
      widget.videoFile.path,
      _startTrim,
      _endTrim,
    );
    
    if (!mounted) return; // Check again after the async call

    if (outputPath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video exported successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to export video')),
      );
    }
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.toolType.toUpperCase()} Video'),
      ),
      body: _controller.value.isInitialized
          ? SingleChildScrollView(
              child: Column(
                children: [
                  if (widget.toolType == 'trim') _buildTrimTool(),
                  if (widget.toolType == 'filter') _buildFilterTool(),
                  if (widget.toolType == 'effects') _buildEffectsTool(),
                  if (widget.toolType == 'text') _buildTextTool(),
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: widget.toolType == 'text'
          ? FloatingActionButton(
              onPressed: _addNewText,
              child: const Icon(Icons.text_fields),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
