import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoTimeline extends StatelessWidget {
  final VideoPlayerController controller;
  final Function(double start, double end) onTrimChanged;

  const VideoTimeline({
    Key? key,
    required this.controller,
    required this.onTrimChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, VideoPlayerValue value, child) {
          final position = value.position;
          final duration = value.duration;
          final progress = position.inMilliseconds / duration.inMilliseconds;

          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * progress,
                height: double.infinity,
                color: Colors.blue.withOpacity(0.5),
              ),
              Center(
                child: Text(
                  '${position.toString().split('.').first} / ${duration.toString().split('.').first}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}