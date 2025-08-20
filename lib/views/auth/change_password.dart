import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../providers/change_password_provider.dart';
import '../../style/colors.dart';
import '../../style/texts.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChangePasswordProvider(),
      child: const _ChangePasswordView(),
    );
  }
}

class _ChangePasswordView extends StatelessWidget {
  const _ChangePasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.darkPrimaryColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.primaryGradient,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                // Header
                _buildHeader(context),
                SizedBox(height: screenSize.height * 0.05),

                // Main Card
                _buildMainCard(context, screenSize),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.glassColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.glassBorderColor, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: AppColors.textPrimaryColor,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Change Password',
          style: AppTexts.headingStyle(
            context: context,
            textColor: AppColors.textPrimaryColor,
            fontSize: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildMainCard(BuildContext context, Size screenSize) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorderColor, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.darkPrimaryColor.withOpacity(0.7),
                  AppColors.darkSecondaryColor.withOpacity(0.8),
                  AppColors.darkTertiaryColor.withOpacity(0.7),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon and Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Security Settings',
                          style: AppTexts.emphasizedTextStyle(
                            context: context,
                            textColor: AppColors.textPrimaryColor,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Update your account password',
                          style: AppTexts.bodyTextStyle(
                            context: context,
                            textColor: AppColors.textSecondaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Current Password Field
                Consumer<ChangePasswordProvider>(
                  builder: (context, provider, _) {
                    return _buildPasswordField(
                      context: context,
                      controller: provider.currentPasswordController,
                      label: 'Current Password',
                      hint: 'Enter your current password',
                      isPassword: !provider.currentPasswordVisible,
                      onToggleVisibility: provider.toggleCurrentPasswordVisibility,
                      errorText: provider.currentPasswordError,
                    );
                  },
                ),
                const SizedBox(height: 24),

                // New Password Field with real-time validation
                Consumer<ChangePasswordProvider>(
                  builder: (context, provider, _) {
                    final String newPassword = provider.newPasswordController.text;
                    String? validationError;

                    if (newPassword.isNotEmpty) {
                      validationError = provider.validateNewPassword(newPassword);
                    }

                    return _buildPasswordField(
                      context: context,
                      controller: provider.newPasswordController,
                      label: 'New Password',
                      hint: 'Enter your new password',
                      isPassword: !provider.newPasswordVisible,
                      onToggleVisibility: provider.toggleNewPasswordVisibility,
                      errorText: provider.newPasswordError ?? validationError,
                      isRealTimeValidation: true,
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Confirm Password Field
                Consumer<ChangePasswordProvider>(
                  builder: (context, provider, _) {
                    return _buildPasswordField(
                      context: context,
                      controller: provider.confirmPasswordController,
                      label: 'Confirm New Password',
                      hint: 'Confirm your new password',
                      isPassword: !provider.confirmPasswordVisible,
                      onToggleVisibility: provider.toggleConfirmPasswordVisibility,
                      errorText: provider.confirmPasswordError,
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Change Password Button
                Consumer<ChangePasswordProvider>(
                  builder: (context, provider, _) {
                    return _buildChangePasswordButton(context, provider);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isPassword,
    required VoidCallback onToggleVisibility,
    String? errorText,
    bool isRealTimeValidation = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTexts.emphasizedTextStyle(
            context: context,
            textColor: AppColors.textPrimaryColor,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.glassColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: errorText != null
                  ? AppColors.errorColor.withOpacity(0.5)
                  : AppColors.glassBorderColor,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.darkSecondaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextFormField(
                  controller: controller,
                  obscureText: isPassword,
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.textPrimaryColor,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: AppColors.textTertiaryColor,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondaryColor,
                        size: 20,
                      ),
                      onPressed: onToggleVisibility,
                    ),
                  ),
                  onChanged: (_) {
                    // Clear error when user starts typing (only for non-real-time validation)
                    if (errorText != null && !isRealTimeValidation) {
                      context.read<ChangePasswordProvider>().clearFieldError(label);
                    }
                    // Notify listeners to update button state and real-time validation
                    context.read<ChangePasswordProvider>().notifyListeners();
                  },
                ),
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText,
            style: AppTexts.bodyTextStyle(
              context: context,
              textColor: AppColors.errorColor,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordRequirements(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorderColor, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password Requirements:',
                style: AppTexts.emphasizedTextStyle(
                  context: context,
                  textColor: AppColors.textPrimaryColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              _buildRequirementItem('At least 6 characters', context),
              _buildRequirementItem('One uppercase letter (A-Z)', context),
              _buildRequirementItem('One lowercase letter (a-z)', context),
              _buildRequirementItem('One number (0-9)', context),
              _buildRequirementItem(
                'One special character (!@#\$%^&*)',
                context,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTexts.bodyTextStyle(
              context: context,
              textColor: AppColors.textSecondaryColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangePasswordButton(
      BuildContext context,
      ChangePasswordProvider provider,
      ) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: provider.isFormValid && !provider.isLoading
            ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryColor, AppColors.primaryDarkColor],
        )
            : LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.textTertiaryColor.withOpacity(0.3),
            AppColors.textTertiaryColor.withOpacity(0.5),
          ],
        ),
        boxShadow: provider.isFormValid && !provider.isLoading
            ? [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: ElevatedButton(
            onPressed: provider.isFormValid && !provider.isLoading
                ? () => provider.changePassword(context)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: provider.isFormValid && !provider.isLoading
                  ? AppColors.whiteColor
                  : AppColors.textTertiaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            child: provider.isLoading
                ? const SpinKitCircle(color: AppColors.whiteColor, size: 24)
                : Text(
              'Change Password',
              style: AppTexts.emphasizedTextStyle(
                context: context,
                textColor: provider.isFormValid
                    ? AppColors.whiteColor
                    : AppColors.textTertiaryColor,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
