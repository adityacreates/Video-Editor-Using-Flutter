enum TimelineMarkerType {
  cut,
  textOverlay,
  audioTrack,
  subtitle,
}

class TimelineMarker {
  final TimelineMarkerType type;
  final Duration position;
  final String? label; // Optional label for text overlays or subtitles
  final String? audioPath; // Path to audio file for audio tracks

  TimelineMarker({
    required this.type,
    required this.position,
    this.label,
    this.audioPath,
  });
}