import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// We define MarkerType to support different kinds of timeline markers
enum MarkerType {
  cut,
  textOverlay,
  audioTrack,
  subtitle,
}

// The Marker class represents a point of interest on the video timeline
class Marker {
  final Duration position;
  final MarkerType type;
  final String? label;
  final String? audioPath; // Added to support audio track markers

  const Marker({
    required this.position,
    required this.type,
    this.label,
    this.audioPath,
  });
}

// VideoTimeline is now a StatefulWidget to manage interactive marker operations
class VideoTimeline extends StatefulWidget {
  final VideoPlayerController controller;
  final Function(double start, double end)? onTrimChanged;
  final List<Marker> markers;
  final Function(Marker)? onMarkerAdded;
  final Function(Marker)? onMarkerEdited;
  final Function(Marker)? onMarkerRemoved;

  const VideoTimeline({
    Key? key,
    required this.controller,
    this.onTrimChanged,
    this.markers = const [],
    this.onMarkerAdded,
    this.onMarkerEdited,
    this.onMarkerRemoved,
  }) : super(key: key);

  @override
  State<VideoTimeline> createState() => _VideoTimelineState();
}

class _VideoTimelineState extends State<VideoTimeline> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => _handleTimelineTap(details.localPosition),
      child: Container(
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: ValueListenableBuilder(
          valueListenable: widget.controller,
          builder: (context, VideoPlayerValue value, child) {
            final position = value.position;
            final duration = value.duration;
            final progress = duration.inMilliseconds > 0
                ? position.inMilliseconds / duration.inMilliseconds
                : 0.0;

            return Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Progress indicator shows current playback position
                Container(
                  width: MediaQuery.of(context).size.width * progress,
                  height: double.infinity,
                  color: Colors.blue.withOpacity(0.5),
                ),
                
                // Time display shows current position and total duration
                Center(
                  child: Text(
                    '${position.toString().split('.').first} / ${duration.toString().split('.').first}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                // Interactive markers with tap and long-press handling
                for (var marker in widget.markers)
                  Positioned(
                    left: _calculateMarkerPosition(marker.position, duration),
                    child: GestureDetector(
                      onTap: () => _editMarker(marker),
                      onLongPress: () => _removeMarker(marker),
                      child: _buildMarker(marker),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Handles taps on the timeline to add new markers
  void _handleTimelineTap(Offset localPosition) {
    if (widget.onMarkerAdded == null) return;

    final double totalWidth = MediaQuery.of(context).size.width - 32;
    final double positionRatio = localPosition.dx / totalWidth;
    final Duration position = Duration(
      milliseconds: (positionRatio * widget.controller.value.duration.inMilliseconds).round(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Marker'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Cut'),
              onTap: () {
                widget.onMarkerAdded?.call(Marker(
                  type: MarkerType.cut,
                  position: position,
                ));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Text Overlay'),
              onTap: () {
                widget.onMarkerAdded?.call(Marker(
                  type: MarkerType.textOverlay,
                  position: position,
                  label: 'New Text',
                ));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Audio Track'),
              onTap: () {
                widget.onMarkerAdded?.call(Marker(
                  type: MarkerType.audioTrack,
                  position: position,
                  audioPath: 'path/to/audio',
                ));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Subtitle'),
              onTap: () {
                widget.onMarkerAdded?.call(Marker(
                  type: MarkerType.subtitle,
                  position: position,
                  label: 'New Subtitle',
                ));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Opens a dialog to edit an existing marker
  void _editMarker(Marker marker) {
    if (widget.onMarkerEdited == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Marker'),
        content: TextFormField(
          initialValue: marker.label,
          onChanged: (value) {
            widget.onMarkerEdited?.call(Marker(
              type: marker.type,
              position: marker.position,
              label: value,
              audioPath: marker.audioPath,
            ));
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Removes a marker from the timeline
  void _removeMarker(Marker marker) {
    widget.onMarkerRemoved?.call(marker);
  }

  // Calculates the horizontal position of a marker on the timeline
  double _calculateMarkerPosition(Duration position, Duration totalDuration) {
    final double totalWidth = MediaQuery.of(context).size.width - 32;
    return (position.inMilliseconds / totalDuration.inMilliseconds) * totalWidth;
  }

  // Creates appropriate visual representation for each marker type
  Widget _buildMarker(Marker marker) {
    switch (marker.type) {
      case MarkerType.cut:
        return _buildCutMarker();
      case MarkerType.textOverlay:
        return _buildTextOverlayMarker(marker.label ?? 'Text');
      case MarkerType.audioTrack:
        return _buildAudioTrackMarker();
      case MarkerType.subtitle:
        return _buildSubtitleMarker(marker.label ?? 'Subtitle');
    }
  }

  Widget _buildCutMarker() {
    return Container(
      width: 4,
      height: 40,
      color: Colors.red,
    );
  }

  Widget _buildTextOverlayMarker(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _buildAudioTrackMarker() {
    return Container(
      width: 4,
      height: 40,
      color: Colors.green,
    );
  }

  Widget _buildSubtitleMarker(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}