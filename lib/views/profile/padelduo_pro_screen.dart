import 'package:flutter/material.dart';
import 'dart:ui';
import '../../style/colors.dart';
import '../../style/fonts_sizes.dart';
import '../../style/texts.dart';

class PadelDuoPlusScreen extends StatefulWidget {
  const PadelDuoPlusScreen({super.key});

  @override
  State<PadelDuoPlusScreen> createState() => _PadelDuoPlusScreenState();
}

class _PadelDuoPlusScreenState extends State<PadelDuoPlusScreen> {
  bool isMonthly = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkPrimaryColor,
      body: Stack(
        children: [
          // Background gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.darkPrimaryColor,
                  AppColors.darkSecondaryColor,
                  AppColors.darkTertiaryColor,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                floating: true,
                pinned: false,
                expandedHeight: 75,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.glassColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.glassBorderColor,
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimaryColor,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.glassColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.glassBorderColor,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.accentPurpleColor,
                                AppColors.accentBlueColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.workspace_premium,
                            color: AppColors.textPrimaryColor,
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'PadelDuo+',
                          style: AppTexts.bodyTextStyle(
                            context: context,
                            textColor: AppColors.textPrimaryColor,
                            fontSize: AppFontSizes(context).size14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryColor.withOpacity(0.3),
                          AppColors.accentPurpleColor.withOpacity(0.2),
                        ],
                      ),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(),
                    ),
                  ),
                ),
              ),
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Header Text
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.glassColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.glassBorderColor,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Elevate Your Game',
                              style: AppTexts.bodyTextStyle(
                                context: context,
                                textColor: AppColors.textPrimaryColor,
                                fontSize: AppFontSizes(context).size24,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Unlock premium features and take your padel skills to the next level',
                              style: AppTexts.bodyTextStyle(
                                context: context,
                                textColor: AppColors.textSecondaryColor,
                                fontSize: AppFontSizes(context).size16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Toggle between Monthly and Yearly
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.glassColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.glassBorderColor,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => isMonthly = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isMonthly
                                            ? AppColors.primaryColor
                                                .withOpacity(0.9)
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow:
                                        isMonthly
                                            ? [
                                              BoxShadow(
                                                color: AppColors.primaryColor
                                                    .withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                            : null,
                                  ),
                                  child: Text(
                                    'Monthly',
                                    textAlign: TextAlign.center,
                                    style: AppTexts.bodyTextStyle(
                                      context: context,
                                      textColor:
                                          isMonthly
                                              ? AppColors.textPrimaryColor
                                              : AppColors.textTertiaryColor,
                                      fontSize: AppFontSizes(context).size14,
                                      fontWeight:
                                          isMonthly
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => isMonthly = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        !isMonthly
                                            ? AppColors.primaryColor
                                                .withOpacity(0.9)
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow:
                                        !isMonthly
                                            ? [
                                              BoxShadow(
                                                color: AppColors.primaryColor
                                                    .withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                            : null,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Text(
                                        'Yearly',
                                        textAlign: TextAlign.center,
                                        style: AppTexts.bodyTextStyle(
                                          context: context,
                                          textColor:
                                              !isMonthly
                                                  ? AppColors.textPrimaryColor
                                                  : AppColors.textTertiaryColor,
                                          fontSize:
                                              AppFontSizes(context).size14,
                                          fontWeight:
                                              !isMonthly
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                        ),
                                      ),
                                      if (!isMonthly)
                                        Positioned(
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.successColor,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'Save 20%',
                                              style: TextStyle(
                                                color:
                                                    AppColors.textPrimaryColor,
                                                fontSize: 8,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Subscription Plans
                      _buildSubscriptionPlan(
                        context,
                        'Court Rookie',
                        isMonthly ? '\$9.99' : '\$95.99',
                        isMonthly ? '/month' : '/year',
                        [
                          'Premium Badge',
                          'Advanced Match Analytics',
                          'Training Video Library (50 videos)',
                          'Priority Match Finding',
                          'Basic Performance Tracking',
                        ],
                        AppColors.accentBlueColor,
                      ),
                      const SizedBox(height: 16),
                      _buildSubscriptionPlan(
                        context,
                        'Court Master',
                        isMonthly ? '\$19.99' : '\$191.99',
                        isMonthly ? '/month' : '/year',
                        [
                          'All Court Rookie Features',
                          'Tournament Organization Tools',
                          'Unlimited Training Videos',
                          'Live Match Streaming (30 hours)',
                          'Advanced Coaching Insights',
                          'Custom Training Plans',
                        ],
                        AppColors.accentPurpleColor,
                        isPopular: true,
                      ),
                      const SizedBox(height: 16),
                      _buildSubscriptionPlan(
                        context,
                        'Padel Legend',
                        isMonthly ? '\$29.99' : '\$287.99',
                        isMonthly ? '/month' : '/year',
                        [
                          'All Court Master Features',
                          'Unlimited Match Streaming',
                          'Personal AI Coach',
                          'VIP Tournament Access',
                          'Professional Stats Dashboard',
                          'Direct Coach Messaging',
                          'Equipment Discounts (15%)',
                        ],
                        AppColors.accentCyanColor,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlan(
    BuildContext context,
    String title,
    String price,
    String period,
    List<String> features,
    Color accentColor, {
    bool isPopular = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isPopular
                  ? accentColor.withOpacity(0.5)
                  : AppColors.glassBorderColor,
          width: isPopular ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                isPopular
                    ? accentColor.withOpacity(0.2)
                    : AppColors.blackColor.withOpacity(0.1),
            blurRadius: isPopular ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with popular badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: AppColors.textPrimaryColor,
                  fontSize: AppFontSizes(context).size20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor, accentColor.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'POPULAR',
                    style: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: AppColors.textPrimaryColor,
                      fontSize: AppFontSizes(context).size10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: accentColor,
                  fontSize: AppFontSizes(context).size32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  period,
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.textTertiaryColor,
                    fontSize: AppFontSizes(context).size14,
                  ),
                ),
              ),
            ],
          ),
          if (!isMonthly && period == '/year')
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Save ${((double.parse(price.substring(1)) * 12 - double.parse(price.substring(1))) / (double.parse(price.substring(1)) * 12) * 100).toInt()}% vs monthly',
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: AppColors.successColor,
                  fontSize: AppFontSizes(context).size12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 20),
          // Features
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.check, color: accentColor, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.textPrimaryColor,
                        fontSize: AppFontSizes(context).size14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Subscribe Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor, accentColor.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Start Free Trial',
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: AppColors.textPrimaryColor,
                  fontSize: AppFontSizes(context).size16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
