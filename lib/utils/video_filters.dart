class VideoFilters {
  static const List<double> normal = [
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ];

  static const List<double> grayscale = [
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ];

  static const List<double> sepia = [
    0.393, 0.769, 0.189, 0, 0,
    0.349, 0.686, 0.168, 0, 0,
    0.272, 0.534, 0.131, 0, 0,
    0, 0, 0, 1, 0,
  ];

  static const List<double> vintage = [
    0.9, 0.5, 0.1, 0, 0,
    0.3, 0.8, 0.1, 0, 0,
    0.2, 0.3, 0.5, 0, 0,
    0, 0, 0, 1, 0,
  ];

  static const List<double> bright = [
    1.2, 0, 0, 0, 0.1,
    0, 1.2, 0, 0, 0.1,
    0, 0, 1.2, 0, 0.1,
    0, 0, 0, 1, 0,
  ];
}