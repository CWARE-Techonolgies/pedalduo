import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:pedalduo/style/fonts_sizes.dart';
import '../../../models/courts_models.dart';
import '../../../providers/courts_provider.dart';
import '../../../style/colors.dart';
import '../../../style/texts.dart';

class CourtsScreen extends StatefulWidget {
  const CourtsScreen({super.key});

  @override
  State<CourtsScreen> createState() => _CourtsScreenState();
}

class _CourtsScreenState extends State<CourtsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CourtsProvider>(
      builder: (context, courtsProvider, child) {
        final filteredCourts = _searchQuery.isEmpty
            ? courtsProvider.courts
            : courtsProvider.searchCourts(_searchQuery);

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.navyBlueGrey, AppColors.lightNavyBlueGrey],
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and search
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Title and search icon row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Courts',
                                style: AppTexts.headingStyle(
                                  context: context,
                                  textColor: AppColors.whiteColor,
                                  fontSize: AppFontSizes(context).size32,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${filteredCourts.length} courts available',
                                style: AppTexts.bodyTextStyle(
                                  context: context,
                                  textColor: AppColors.greyColor,
                                  fontSize: AppFontSizes(context).size14,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isSearchActive = !_isSearchActive;
                                if (!_isSearchActive) {
                                  _searchController.clear();
                                  _searchQuery = '';
                                }
                              });
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _isSearchActive
                                    ? AppColors.orangeColor.withOpacity(0.2)
                                    : AppColors.whiteColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: _isSearchActive
                                      ? AppColors.orangeColor.withOpacity(0.4)
                                      : AppColors.whiteColor.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                _isSearchActive ? Icons.close : Icons.search,
                                color: AppColors.whiteColor,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Search field
                      if (_isSearchActive)
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: AppColors.whiteColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: AppTexts.bodyTextStyle(
                              context: context,
                              textColor: AppColors.whiteColor,
                              fontSize: AppFontSizes(context).size16,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search courts...',
                              hintStyle: AppTexts.bodyTextStyle(
                                context: context,
                                textColor: AppColors.greyColor,
                                fontSize: AppFontSizes(context).size16,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppColors.greyColor,
                                size: 20,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                ),

                // Courts Grid
                Expanded(
                  child: filteredCourts.isEmpty
                      ? _buildEmptyState()
                      : Padding(
                    padding: const EdgeInsets.only(
                      left: 20.0,
                      right: 20.0,
                      bottom: 20.0,
                    ),
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.68, // Increased height
                      ),
                      itemCount: filteredCourts.length,
                      itemBuilder: (context, index) {
                        final court = filteredCourts[index];
                        return _buildCourtCard(context, court);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.whiteColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.search_off,
              color: AppColors.greyColor,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No courts found',
            style: AppTexts.emphasizedTextStyle(
              context: context,
              textColor: AppColors.whiteColor,
              fontSize: AppFontSizes(context).size18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: AppTexts.bodyTextStyle(
              context: context,
              textColor: AppColors.greyColor,
              fontSize: AppFontSizes(context).size14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourtCard(BuildContext context, CourtItem court) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.whiteColor.withOpacity(0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.whiteColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                // Court Image/Header - Reduced height
                Expanded(
                  flex: 3, // Changed from 5 to 3
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.orangeColor.withOpacity(0.4),
                          AppColors.blueColor.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Padel court pattern
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.greenColor.withOpacity(0.15),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(18),
                              topRight: Radius.circular(18),
                            ),
                          ),
                        ),

                        // Court lines pattern
                        CustomPaint(
                          size: const Size(double.infinity, double.infinity),
                          painter: CourtPatternPainter(),
                        ),

                        // Court icon - Smaller
                        Center(
                          child: Container(
                            width: 44, // Reduced from 56
                            height: 44, // Reduced from 56
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: AppColors.whiteColor.withOpacity(0.4),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.sports_tennis,
                              color: AppColors.whiteColor,
                              size: 22, // Reduced from 28
                            ),
                          ),
                        ),

                        // Courts count badge - Smaller
                        Positioned(
                          top: 8, // Reduced from 12
                          right: 8, // Reduced from 12
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6, // Reduced from 8
                              vertical: 3, // Reduced from 4
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.orangeColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${court.courts}',
                              style: AppTexts.emphasizedTextStyle(
                                context: context,
                                textColor: AppColors.whiteColor,
                                fontSize: AppFontSizes(context).size10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Court Info - Increased space
                Expanded(
                  flex: 4, // Keep as 4 for more info space
                  child: Padding(
                    padding: const EdgeInsets.all(12), // Reduced from 16
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Court name
                        Text(
                          court.name,
                          style: AppTexts.emphasizedTextStyle(
                            context: context,
                            textColor: AppColors.whiteColor,
                            fontSize: AppFontSizes(context).size14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        // Location
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: AppColors.greyColor,
                              size: 12,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                court.location,
                                style: AppTexts.bodyTextStyle(
                                  context: context,
                                  textColor: AppColors.greyColor,
                                  fontSize: AppFontSizes(context).size11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 3),

                        // Court count text
                        Text(
                          '${court.courts} ${court.courts == 1 ? 'Court' : 'Courts'} Available',
                          style: AppTexts.bodyTextStyle(
                            context: context,
                            textColor: AppColors.greyColor,
                            fontSize: AppFontSizes(context).size10,
                          ),
                        ),

                        const Spacer(),

                        // Book Court Button - More compact
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Booking ${court.name}...'),
                                backgroundColor: AppColors.orangeColor,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 28, // Reduced from 32
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.orangeColor,
                                  AppColors.orangeColor.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.orangeColor.withOpacity(0.3),
                                  blurRadius: 4, // Reduced from 6
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Book Court',
                                style: AppTexts.emphasizedTextStyle(
                                  context: context,
                                  textColor: AppColors.whiteColor,
                                  fontSize: AppFontSizes(context).size11,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for court pattern
class CourtPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.whiteColor.withOpacity(0.1)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Draw court lines
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Center line
    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, size.height),
      paint,
    );

    // Horizontal line
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      paint,
    );

    // Corner rectangles - smaller for compact design
    const margin = 6.0;
    canvas.drawRect(
      Rect.fromLTWH(margin, margin, size.width / 4, size.height / 4),
      paint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        size.width - size.width / 4 - margin,
        size.height - size.height / 4 - margin,
        size.width / 4,
        size.height / 4,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}