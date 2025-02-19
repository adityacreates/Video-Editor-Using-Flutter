import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class TrimSlider extends StatefulWidget {
  final VideoPlayerController controller;
  final Function(double start, double end) onTrimChanged;

  const TrimSlider({
    Key? key,
    required this.controller,
    required this.onTrimChanged,
  }) : super(key: key);

  @override
  State<TrimSlider> createState() => _TrimSliderState();
}

class _TrimSliderState extends State<TrimSlider> {
  RangeValues _currentRange = const RangeValues(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          RangeSlider(
            values: _currentRange,
            onChanged: (RangeValues values) {
              setState(() {
                _currentRange = values;
                widget.onTrimChanged(
                  values.start * widget.controller.value.duration.inMilliseconds,
                  values.end * widget.controller.value.duration.inMilliseconds,
                );
              });
            },
            labels: RangeLabels(
              '${(_currentRange.start * widget.controller.value.duration.inSeconds).round()}s',
              '${(_currentRange.end * widget.controller.value.duration.inSeconds).round()}s',
            ),
          ),
        ],
      ),
    );
  }
}