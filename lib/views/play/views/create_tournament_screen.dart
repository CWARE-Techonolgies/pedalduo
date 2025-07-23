import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:convert';
import 'dart:ui';

import '../../../style/colors.dart';
import '../../../style/fonts_sizes.dart';
import '../../../style/texts.dart';
import '../providers/tournament_provider.dart';
import '../providers/user_profile_provider.dart';

class CreateTournamentScreen extends StatefulWidget {
  const CreateTournamentScreen({super.key});

  @override
  State<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends State<CreateTournamentScreen> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _playersPerTeamController = TextEditingController();
  final _totalTeamsController = TextEditingController();
  final _playerFeeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rulesController = TextEditingController();

  // Cached image handling
  String _cachedImageUrl = '';
  Widget? _cachedImageWidget;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProfileProvider>().initializeUser().then((_) {
        final user = context.read<UserProfileProvider>().user;
        if (user?.isFirstTournament == true) {
          _showFirstTournamentDialog();
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _playersPerTeamController.dispose();
    _totalTeamsController.dispose();
    _playerFeeController.dispose();
    _descriptionController.dispose();
    _rulesController.dispose();
    super.dispose();
  }

  void _showFirstTournamentDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GlassContainer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Celebration icon
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor.withOpacity(0.3),
                        AppColors.accentPurpleColor.withOpacity(0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.celebration,
                    size: 48,
                    color: AppColors.accentPurpleColor,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  '🎉 Congratulations! 🎉',
                  style: AppTexts.headingStyle(
                    context: context,
                    textColor: AppColors.textPrimaryColor,
                    fontSize: AppFontSizes(context).size20,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'Welcome to Cricketify!',
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.textPrimaryColor,
                    fontSize: AppFontSizes(context).size16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'As this is your very first tournament, you can create it absolutely FREE! 🆓\n\nStart your cricket journey with us and experience the excitement of organizing tournaments.',
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.textSecondaryColor,
                    fontSize: AppFontSizes(context).size14,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                GlassButton(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(
                    'Let\'s Get Started! 🚀',
                    style: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: AppColors.textPrimaryColor,
                      fontSize: AppFontSizes(context).size16,
                      fontWeight: FontWeight.w600,
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

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        if (kDebugMode) {
          print('is user`s first tournament ? ${user?.isFirstTournament}');
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Consumer<TournamentProvider>(
                        builder: (context, provider, child) {
                          return Column(
                            children: [
                              _buildImagePicker(context, provider),
                              SizedBox(height: 20),
                              ..._buildFormFields(provider, user?.isFirstTournament ?? false),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return GlassContainer(
      margin: EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimaryColor,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Create Tournament',
              style: AppTexts.headingStyle(
                context: context,
                textColor: AppColors.textPrimaryColor,
                fontSize: AppFontSizes(context).size20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  List<Widget> _buildFormFields(TournamentProvider provider, bool isFirstTournament) {
    return [
      // Title Field
      GlassInputField(
        title: 'Tournament Title*',
        controller: _titleController,
        onChanged: provider.setTitle,
        icon: Icons.sports_cricket,
      ),
      SizedBox(height: 16),

      // Description Field
      GlassInputField(
        title: 'Description',
        controller: _descriptionController,
        onChanged: provider.setDescription,
        maxLines: 3,
        icon: Icons.description,
      ),
      SizedBox(height: 16),

      // Location Field
      GlassInputField(
        title: 'Location*',
        controller: _locationController,
        onChanged: provider.setLocation,
        icon: Icons.location_on,
      ),
      SizedBox(height: 16),

      // Players and Teams Row
      Row(
        children: [
          Expanded(
            child: GlassInputField(
              title: 'Players/Team*',
              controller: _playersPerTeamController,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final intValue = int.tryParse(value) ?? 0;
                provider.setPlayersPerTeam(intValue);
              },
              icon: Icons.group,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: GlassInputField(
              title: 'Total Teams*',
              controller: _totalTeamsController,
              keyboardType: TextInputType.number,
              errorText: provider.totalTeamsError.isEmpty ? null : provider.totalTeamsError,
              onChanged: (value) {
                final intValue = int.tryParse(value) ?? 0;
                provider.setTotalTeams(intValue);
              },
              icon: Icons.groups,
            ),
          ),
        ],
      ),
      SizedBox(height: 16),

      // Package Type Display
      _buildPackageDisplay(provider),
      SizedBox(height: 16),

      // Package Pricing Info
      _buildPricingInfo(provider, isFirstTournament),
      SizedBox(height: 16),

      // Player Fee Field
      GlassInputField(
        title: 'Player Fee (PKR)',
        controller: _playerFeeController,
        keyboardType: TextInputType.number,
        onChanged: (value) {
          final doubleValue = double.tryParse(value) ?? 0.0;
          provider.setPlayerFee(doubleValue);
        },
        icon: Icons.attach_money,
      ),
      SizedBox(height: 16),

      // Gender Dropdown
      _buildGenderDropdown(provider),
      SizedBox(height: 16),

      // Date Fields
      GlassDateField(
        title: 'Registration End*',
        selectedDate: provider.registrationEndDate,
        onDateSelected: provider.setRegistrationEndDate,
        icon: Icons.app_registration,
      ),
      SizedBox(height: 16),

      GlassDateField(
        title: 'Tournament Start*',
        selectedDate: provider.tournamentStartDate,
        onDateSelected: provider.setTournamentStartDate,
        icon: Icons.play_arrow,
      ),
      SizedBox(height: 16),

      GlassDateField(
        title: 'Tournament End*',
        selectedDate: provider.tournamentEndDate,
        onDateSelected: provider.setTournamentEndDate,
        icon: Icons.stop,
      ),
      SizedBox(height: 16),

      // Rules Field
      GlassInputField(
        title: 'Rules & Regulations',
        controller: _rulesController,
        onChanged: provider.setRulesAndRegulations,
        maxLines: 4,
        icon: Icons.rule,
      ),
      SizedBox(height: 16),

      // Error Display
      if (provider.errorMessage.isNotEmpty) ...[
        _buildErrorContainer(provider),
        SizedBox(height: 16),
      ],

      // Create Button
      _buildCreateButton(provider, isFirstTournament),
      SizedBox(height: 20),
    ];
  }

  Widget _buildPackageDisplay(TournamentProvider provider) {
    return GlassContainer(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accentBlueColor, AppColors.accentCyanColor],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.verified, color: Colors.white, size: 16),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto-Selected Package',
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.textSecondaryColor,
                    fontSize: AppFontSizes(context).size12,
                  ),
                ),
                Text(
                  provider.packageType,
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.textPrimaryColor,
                    fontSize: AppFontSizes(context).size14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingInfo(TournamentProvider provider, bool isFirstTournament) {
    return GlassContainer(
      gradient: LinearGradient(
        colors: isFirstTournament
            ? [AppColors.successColor.withOpacity(0.2), AppColors.successColor.withOpacity(0.1)]
            : [AppColors.accentBlueColor.withOpacity(0.2), AppColors.accentCyanColor.withOpacity(0.1)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isFirstTournament ? Icons.celebration : Icons.info_outline,
                color: isFirstTournament ? AppColors.successColor : AppColors.accentBlueColor,
                size: 20,
              ),
              SizedBox(width: 12),
              Text(
                isFirstTournament ? 'First Tournament - FREE!' : 'Package Pricing',
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: AppColors.textPrimaryColor,
                  fontSize: AppFontSizes(context).size14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            isFirstTournament
                ? '🎉 Congratulations! Your first tournament is completely FREE!\n• All package features included\n• No hidden charges\n• Start your cricket journey today!'
                : '• 4-7 teams: Basic (5000 PKR)\n• 8-16 teams: Premium (10000 PKR)\n• 17-32 teams: VIP (15000 PKR)',
            style: AppTexts.bodyTextStyle(
              context: context,
              textColor: AppColors.textSecondaryColor,
              fontSize: AppFontSizes(context).size12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderDropdown(TournamentProvider provider) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people, color: AppColors.accentPurpleColor, size: 16),
              SizedBox(width: 8),
              Text(
                'Gender',
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: AppColors.textSecondaryColor,
                  fontSize: AppFontSizes(context).size12,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: provider.gender,
            dropdownColor: AppColors.darkSecondaryColor,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            items: provider.genderOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.textPrimaryColor,
                    fontSize: AppFontSizes(context).size14,
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? value) {
              if (value != null) {
                provider.setGender(value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(BuildContext context, TournamentProvider provider) {
    if (_cachedImageUrl != provider.imageUrl) {
      _cachedImageUrl = provider.imageUrl;
      _cachedImageWidget = _buildImageContainer();
    }

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.image, color: AppColors.primaryColor, size: 16),
              SizedBox(width: 8),
              Text(
                'Tournament Image',
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: AppColors.textSecondaryColor,
                  fontSize: AppFontSizes(context).size12,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _cachedImageWidget ?? Container(),
          SizedBox(height: 12),
          GlassButton(
            onTap: provider.pickAndCompressImage,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primaryColor,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  _cachedImageUrl.isEmpty ? 'Select Image' : 'Change Image',
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.textPrimaryColor,
                    fontSize: AppFontSizes(context).size14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContainer() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorderColor),
      ),
      child: _cachedImageUrl.isEmpty
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 48,
            color: AppColors.textTertiaryColor,
          ),
          SizedBox(height: 8),
          Text(
            'No image selected',
            style: AppTexts.bodyTextStyle(
              context: context,
              textColor: AppColors.textTertiaryColor,
              fontSize: AppFontSizes(context).size12,
            ),
          ),
        ],
      )
          : Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              base64Decode(_cachedImageUrl.split(',')[1]),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => context.read<TournamentProvider>().clearImage(),
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.errorColor.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContainer(TournamentProvider provider) {
    return GlassContainer(
      gradient: LinearGradient(
        colors: [
          AppColors.errorColor.withOpacity(0.2),
          AppColors.errorColor.withOpacity(0.1),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.errorColor, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              provider.errorMessage,
              style: AppTexts.bodyTextStyle(
                context: context,
                textColor: AppColors.textPrimaryColor,
                fontSize: AppFontSizes(context).size14,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: AppColors.errorColor, size: 16),
            onPressed: provider.clearError,
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton(TournamentProvider provider, bool isFirstTournament) {
    return GlassButton(
      onTap: provider.isLoading || !provider.isFormValid
          ? null
          : () async {
        final success = await provider.createTournament(
          isFirstTournament: isFirstTournament,
        );
        if (success && mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isFirstTournament
                    ? 'Congratulations! Your first tournament created successfully for FREE!'
                    : 'Tournament created successfully!',
              ),
              backgroundColor: AppColors.successColor,
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
      gradient: provider.isFormValid && !provider.isLoading
          ? LinearGradient(
        colors: [AppColors.primaryColor, AppColors.accentPurpleColor],
      )
          : null,
      isDisabled: !provider.isFormValid || provider.isLoading,
      child: provider.isLoading
          ? SpinKitDoubleBounce(
        color: AppColors.textPrimaryColor,
        size: 24,
      )
          : Text(
        isFirstTournament
            ? 'Create Your First Tournament - FREE! 🎉'
            : 'Create Tournament - ${provider.getPackagePrice(isFirstTournament).toStringAsFixed(0)} PKR',
        style: AppTexts.bodyTextStyle(
          context: context,
          textColor: AppColors.textPrimaryColor,
          fontSize: AppFontSizes(context).size16,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// Custom Reusable Components

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;

  const GlassContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(16),
      margin: margin,
      decoration: BoxDecoration(
        gradient: gradient ?? LinearGradient(
          colors: [
            AppColors.glassLightColor,
            AppColors.glassColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.glassBorderColor,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }
}

class GlassInputField extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final Function(String) onChanged;
  final TextInputType? keyboardType;
  final String? errorText;
  final int maxLines;
  final IconData? icon;

  const GlassInputField({
    Key? key,
    required this.title,
    required this.controller,
    required this.onChanged,
    this.keyboardType,
    this.errorText,
    this.maxLines = 1,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.darkOrangeColor, size: 16),
                SizedBox(width: 8),
              ],
              Text(
                title,
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: AppColors.textSecondaryColor,
                  fontSize: AppFontSizes(context).size12,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            onChanged: onChanged,
            style: AppTexts.bodyTextStyle(
              context: context,
              textColor: AppColors.textPrimaryColor,
              fontSize: AppFontSizes(context).size14,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: 'Enter ${title.toLowerCase().replaceAll('*', '')}',
              hintStyle: AppTexts.bodyTextStyle(
                context: context,
                textColor: AppColors.textTertiaryColor,
                fontSize: AppFontSizes(context).size14,
              ),
            ),
          ),
          if (errorText != null) ...[
            SizedBox(height: 4),
            Text(
              errorText!,
              style: AppTexts.bodyTextStyle(
                context: context,
                textColor: AppColors.errorColor,
                fontSize: AppFontSizes(context).size12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class GlassDateField extends StatelessWidget {
  final String title;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final IconData? icon;

  const GlassDateField({
    Key? key,
    required this.title,
    required this.selectedDate,
    required this.onDateSelected,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.accentCyanColor, size: 16),
                SizedBox(width: 8),
              ],
              Text(
                title,
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: AppColors.textSecondaryColor,
                  fontSize: AppFontSizes(context).size12,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.dark(
                        primary: AppColors.primaryColor,
                        surface: AppColors.darkSecondaryColor,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) {
                onDateSelected(date);
              }
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                        : 'Select date',
                    style: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: selectedDate != null
                          ? AppColors.textPrimaryColor
                          : AppColors.textTertiaryColor,
                      fontSize: AppFontSizes(context).size14,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: AppColors.accentCyanColor,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GlassButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;
  final Gradient? gradient;
  final bool isDisabled;

  const GlassButton({
    Key? key,
    this.onTap,
    required this.child,
    this.gradient,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          gradient: isDisabled
              ? LinearGradient(
            colors: [
              AppColors.greyColor.withOpacity(0.3),
              AppColors.greyColor.withOpacity(0.2),
            ],
          )
              : gradient ??
              LinearGradient(
                colors: [
                  AppColors.glassLightColor,
                  AppColors.glassColor,
                ],
              ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDisabled
                ? AppColors.greyColor.withOpacity(0.3)
                : AppColors.greyColor,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: child,
          ),
        ),
      ),
    );
  }
}