import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:pedalduo/style/fonts_sizes.dart';
import '../../../models/highlights_model.dart';
import '../../../providers/highlights_provider.dart';
import '../../../style/colors.dart';
import '../../../style/texts.dart';

class HighlightsScreen extends StatelessWidget {
  const HighlightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HighlightsProvider>(
      builder: (context, highlightsProvider, child) {
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
                // Header with title and add button
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Highlights',
                        style: AppTexts.headingStyle(
                          context: context,
                          textColor: AppColors.whiteColor,
                          fontSize: AppFontSizes(context).size32,
                        ),
                      ),
                    ],
                  ),
                ),

                // Tab Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      _buildTabButton(
                        context,
                        'For You',
                        0,
                        highlightsProvider.selectedTab == 0,
                        highlightsProvider,
                      ),
                      const SizedBox(width: 20),
                      _buildTabButton(
                        context,
                        'Battles',
                        1,
                        highlightsProvider.selectedTab == 1,
                        highlightsProvider,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Placeholder message when using sample data

                // Highlights Grid
                !highlightsProvider.hasRealData
                    ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: MediaQuery.sizeOf(context).height / 4),
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.orangeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.orangeColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppColors.orangeColor,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  highlightsProvider.placeholderMessage,
                                  style: AppTexts.bodyTextStyle(
                                    context: context,
                                    textColor: AppColors.orangeColor,
                                    fontSize: AppFontSizes(context).size14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                    : Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.8,
                              ),
                          itemCount: highlightsProvider.highlights.length,
                          itemBuilder: (context, index) {
                            final highlight =
                                highlightsProvider.highlights[index];
                            return _buildHighlightCard(context, highlight);
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

  Widget _buildTabButton(
    BuildContext context,
    String title,
    int index,
    bool isSelected,
    HighlightsProvider provider,
  ) {
    return GestureDetector(
      onTap: () => provider.setSelectedTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.orangeColor : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: AppTexts.emphasizedTextStyle(
            context: context,
            textColor: isSelected ? AppColors.orangeColor : AppColors.greyColor,
            fontSize: AppFontSizes(context).size16,
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightCard(BuildContext context, HighlightItem highlight) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.whiteColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.blackColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // Background tennis court pattern
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.greenColor.withOpacity(0.3),
                        AppColors.blackColor.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),

                // Play button
                const Positioned(
                  top: 16,
                  right: 16,
                  child: Icon(
                    Icons.play_circle_fill,
                    color: AppColors.orangeColor,
                    size: 32,
                  ),
                ),

                // Content
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.blackColor.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          highlight.title,
                          style: AppTexts.emphasizedTextStyle(
                            context: context,
                            textColor: AppColors.whiteColor,
                            fontSize: AppFontSizes(context).size14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        Text(
                          '${highlight.author} • ${highlight.timeAgo}',
                          style: AppTexts.bodyTextStyle(
                            context: context,
                            textColor: AppColors.greyColor,
                            fontSize: AppFontSizes(context).size12,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.favorite,
                                  color: AppColors.redColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  highlight.likes,
                                  style: AppTexts.bodyTextStyle(
                                    context: context,
                                    textColor: AppColors.whiteColor,
                                    fontSize: AppFontSizes(context).size12,
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                const Icon(
                                  Icons.comment,
                                  color: AppColors.commentColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  highlight.comments,
                                  style: AppTexts.bodyTextStyle(
                                    context: context,
                                    textColor: AppColors.whiteColor,
                                    fontSize: AppFontSizes(context).size12,
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                const Icon(
                                  Icons.share,
                                  color: AppColors.shareColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Share',
                                  style: AppTexts.bodyTextStyle(
                                    context: context,
                                    textColor: AppColors.whiteColor,
                                    fontSize: AppFontSizes(context).size12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Flag indicator
                const Positioned(
                  bottom: 16,
                  right: 16,
                  child: Icon(Icons.flag, color: AppColors.greyColor, size: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
