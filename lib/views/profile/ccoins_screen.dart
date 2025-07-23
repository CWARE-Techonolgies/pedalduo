import 'package:flutter/material.dart';
import 'dart:ui';

import '../../style/colors.dart';
import '../../style/fonts_sizes.dart';
import '../../style/texts.dart';

class CCoinsScreen extends StatefulWidget {
  const CCoinsScreen({super.key});

  @override
  State<CCoinsScreen> createState() => _CCoinsScreenState();
}

class _CCoinsScreenState extends State<CCoinsScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.primaryGradient,
          ),
        ),
        child: Column(
          children: [
            // Custom App Bar with Glass Effect
            SafeArea(
              child: Container(
                margin: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryColor),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Text(
                              'C Coins',
                              style: AppTexts.emphasizedTextStyle(
                                context: context,
                                textColor: AppColors.textPrimaryColor,
                                fontSize: AppFontSizes(context).size18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.info_outline, color: AppColors.textPrimaryColor),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Wallet Section with Glass Effect
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor.withOpacity(0.8),
                          AppColors.primaryLightColor.withOpacity(0.6),
                          AppColors.primaryDarkColor.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.glassBorderColor,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Your Wallet',
                          style: AppTexts.bodyTextStyle(
                            context: context,
                            textColor: AppColors.textPrimaryColor,
                            fontSize: AppFontSizes(context).size16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '1,250 C',
                          style: AppTexts.emphasizedTextStyle(
                            context: context,
                            textColor: AppColors.textPrimaryColor,
                            fontSize: AppFontSizes(context).size32,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.glassLightColor,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  side: BorderSide(
                                    color: AppColors.glassBorderColor,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Buy Coins',
                                style: AppTexts.bodyTextStyle(
                                  context: context,
                                  textColor: AppColors.textPrimaryColor,
                                  fontSize: AppFontSizes(context).size14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tab Bar with Glass Effect
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(4),
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
                        _buildTabItem('C Coins', 0),
                        _buildTabItem('Redeem', 1),
                        _buildTabItem('Transact', 2),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Content
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor.withOpacity(0.8) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(
              color: AppColors.primaryLightColor,
              width: 1,
            ) : null,
          ),
          child: Text(
            title,
            style: AppTexts.bodyTextStyle(
              context: context,
              textColor: isSelected ? AppColors.textPrimaryColor : AppColors.textSecondaryColor,
              fontSize: AppFontSizes(context).size14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildCCoinsTab();
      case 1:
        return _buildRedeemTab();
      case 2:
        return _buildTransactTab();
      default:
        return _buildCCoinsTab();
    }
  }

  Widget _buildCCoinsTab() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Earn C Coins',
            style: AppTexts.emphasizedTextStyle(
              context: context,
              textColor: AppColors.textPrimaryColor,
              fontSize: AppFontSizes(context).size18,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildEarnCard(
                  'Watch Ads',
                  Icons.play_circle_outline,
                  '+10 C',
                  AppColors.accentBlueColor,
                ),
                _buildEarnCard(
                  'Daily Check-in',
                  Icons.calendar_today,
                  '+25 C',
                  AppColors.primaryColor,
                ),
                _buildEarnCard(
                  'Share App',
                  Icons.share,
                  '+50 C',
                  AppColors.accentPurpleColor,
                ),
                _buildEarnCard(
                  'Rate Us',
                  Icons.star_outline,
                  '+30 C',
                  AppColors.warningColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRedeemTab() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Redeem C Coins',
            style: AppTexts.emphasizedTextStyle(
              context: context,
              textColor: AppColors.textPrimaryColor,
              fontSize: AppFontSizes(context).size18,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
              children: [
                _buildServiceCard('Netflix', Icons.movie, 500),
                _buildServiceCard('Amazon', Icons.shopping_bag, 750),
                _buildServiceCard('iTunes', Icons.music_note, 300),
                _buildServiceCard('Jarir', Icons.book, 200),
                _buildServiceCard('PSN', Icons.sports_esports, 400),
                _buildMoreCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactTab() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction History',
            style: AppTexts.emphasizedTextStyle(
              context: context,
              textColor: AppColors.textPrimaryColor,
              fontSize: AppFontSizes(context).size18,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildTransactionItem(
                  'Netflix Subscription',
                  '-500 C',
                  'Dec 20, 2024',
                  Icons.movie,
                  AppColors.errorColor,
                ),
                _buildTransactionItem(
                  'Daily Check-in Bonus',
                  '+25 C',
                  'Dec 19, 2024',
                  Icons.calendar_today,
                  AppColors.successColor,
                ),
                _buildTransactionItem(
                  'Watch Ads Reward',
                  '+10 C',
                  'Dec 19, 2024',
                  Icons.play_circle_outline,
                  AppColors.successColor,
                ),
                _buildTransactionItem(
                  'iTunes Gift Card',
                  '-300 C',
                  'Dec 18, 2024',
                  Icons.music_note,
                  AppColors.errorColor,
                ),
                _buildTransactionItem(
                  'App Rating Bonus',
                  '+30 C',
                  'Dec 17, 2024',
                  Icons.star,
                  AppColors.successColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarnCard(String title, IconData icon, String reward, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.glassColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.glassBorderColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: color.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.textPrimaryColor,
                        fontSize: AppFontSizes(context).size12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reward,
                      style: AppTexts.emphasizedTextStyle(
                        context: context,
                        textColor: AppColors.primaryColor,
                        fontSize: AppFontSizes(context).size14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(String name, IconData icon, int cost) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.glassColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.glassBorderColor,
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.glassLightColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.glassBorderColor,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: AppColors.textPrimaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.textPrimaryColor,
                        fontSize: AppFontSizes(context).size12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$cost C',
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.textSecondaryColor,
                        fontSize: AppFontSizes(context).size10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.glassColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.glassBorderColor,
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: AppColors.textSecondaryColor,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'More...',
                      style: TextStyle(
                        color: AppColors.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
      String title,
      String amount,
      String date,
      IconData icon,
      Color amountColor,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.glassLightColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.glassBorderColor,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.textPrimaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTexts.bodyTextStyle(
                          context: context,
                          textColor: AppColors.textPrimaryColor,
                          fontSize: AppFontSizes(context).size14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        date,
                        style: AppTexts.bodyTextStyle(
                          context: context,
                          textColor: AppColors.textSecondaryColor,
                          fontSize: AppFontSizes(context).size12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  amount,
                  style: AppTexts.emphasizedTextStyle(
                    context: context,
                    textColor: amountColor,
                    fontSize: AppFontSizes(context).size14,
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