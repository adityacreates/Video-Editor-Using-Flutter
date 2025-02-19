import 'package:flutter/material.dart';
import 'main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Easy Video Editing',
      'description': 'Edit your videos with simple gestures. Trim, cut, and merge videos effortlessly.',
      'icon': Icons.cut_rounded,
    },
    {
      'title': 'Add Effects & Filters',
      'description': 'Enhance your videos with beautiful filters and special effects to make them stand out.',
      'icon': Icons.auto_fix_high_rounded,
    },
    {
      'title': 'Share Instantly',
      'description': 'Export in multiple formats and share your masterpiece directly to social media.',
      'icon': Icons.share_rounded,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  );
                },
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _pages[index]['icon'],
                              size: 150,
                              color: Colors.blue,
                            ),
                            const SizedBox(height: 40),
                            Text(
                              _pages[index]['title'],
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _pages[index]['description'],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  // Navigation Buttons
                  Positioned.fill(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentPage > 0)
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_rounded,
                              color: Colors.blue,
                            ),
                            onPressed: previousPage,
                          )
                        else
                          const SizedBox(width: 48),
                        if (_currentPage < _pages.length - 1)
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.blue,
                            ),
                            onPressed: nextPage,
                          )
                        else
                          const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Colors.blue
                        : Colors.blue.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_currentPage == _pages.length - 1)
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    "Let's Begin!",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
            else
              const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}