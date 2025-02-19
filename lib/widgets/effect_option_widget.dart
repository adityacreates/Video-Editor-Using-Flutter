import 'package:flutter/material.dart';

class EffectOption {
  final String name;
  final Matrix4 Function() transform;
  final IconData icon;

  const EffectOption({
    required this.name,
    required this.transform,
    required this.icon,
  });
}