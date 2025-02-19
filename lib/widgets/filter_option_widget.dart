import 'package:flutter/material.dart';

class FilterOption {
  final String name;
  final List<double> matrix;
  final IconData icon;

  const FilterOption({
    required this.name,
    required this.matrix,
    required this.icon,
  });
}