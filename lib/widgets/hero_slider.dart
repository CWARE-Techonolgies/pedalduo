import 'dart:async';
import 'package:flutter/material.dart';
import '../global/images.dart';
import '../style/colors.dart';

class AutoSlideHeroSlider extends StatefulWidget {
  const AutoSlideHeroSlider({super.key});

  @override
  State<AutoSlideHeroSlider> createState() => _AutoSlideHeroSliderState();
}

class _AutoSlideHeroSliderState extends State<AutoSlideHeroSlider> {
  late PageController _pageController;
  int _currentSlide = 0;
  Timer? _timer;

  // Auto-slide configuration
  static const Duration _autoSlideDuration = Duration(seconds: 4);
  static const Duration _animationDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentSlide);
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(_autoSlideDuration, (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentSlide + 1) % AppImages.slides.length;
        _pageController.animateToPage(
          nextPage,
          duration: _animationDuration,
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoSlide() {
    _timer?.cancel();
  }

  void _restartAutoSlide() {
    _stopAutoSlide();
    _startAutoSlide();
  }

  Widget _buildHeroSlider() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: GestureDetector(
              onTapDown: (_) => _stopAutoSlide(),
              onTapUp: (_) => _restartAutoSlide(),
              onTapCancel: () => _restartAutoSlide(),
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentSlide = index;
                  });
                  _restartAutoSlide();
                },
                itemCount: AppImages.slides.length,
                itemBuilder: (context, index) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background image
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: NetworkImage(AppImages.slides[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Blackish overlay
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ),
                      // Optional gradient for depth
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Page indicators
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                AppImages.slides.length,
                    (index) => GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: _animationDuration,
                      curve: Curves.easeInOut,
                    );
                    _restartAutoSlide();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentSlide == index ? 12 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentSlide == index
                          ? AppColors.orangeColor
                          : AppColors.whiteColor.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildHeroSlider();
  }
}