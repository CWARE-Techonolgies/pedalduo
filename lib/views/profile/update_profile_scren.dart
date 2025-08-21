import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../global/apis.dart';
import '../../style/colors.dart';
import '../../style/texts.dart';
import '../play/providers/user_profile_provider.dart';

class UserProfileUpdateScreen extends StatefulWidget {
  const UserProfileUpdateScreen({super.key});

  @override
  State<UserProfileUpdateScreen> createState() =>
      _UserProfileUpdateScreenState();
}

class _UserProfileUpdateScreenState extends State<UserProfileUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneOtpController = TextEditingController();
  final _emailOtpController = TextEditingController();

  String _originalName = '';
  String _originalPhone = '';
  String _originalEmail = '';

  bool _isEmailVerified = false;
  bool _isPhoneVerified = false;
  bool _showEmailOtp = false;
  bool _showPhoneOtp = false;
  bool _isEmailVerifying = false;
  bool _isPhoneVerifying = false;
  bool _isEmailOtpVerifying = false;
  bool _isPhoneOtpVerifying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<UserProfileProvider>(context, listen: false);
      provider.loadUserProfile().then((_) {
        provider.resetImageDeletionState();
        if (provider.user != null) {
          _originalName = provider.user!.name;
          _originalPhone = provider.user!.phone;
          _originalEmail = provider.user!.email;

          _nameController.text = provider.user!.name;
          _phoneController.text = provider.user!.phone;
          _emailController.text = provider.user!.email;
        }
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _phoneOtpController.dispose();
    _emailOtpController.dispose();
    super.dispose();
  }

  bool get _hasChanges {
    final provider = Provider.of<UserProfileProvider>(context, listen: false);

    // Check for text field changes
    bool textFieldsChanged =
        _nameController.text.trim() != _originalName ||
        (_isPhoneVerified && _phoneController.text.trim() != _originalPhone) ||
        (_isEmailVerified && _emailController.text.trim() != _originalEmail);

    // Check for image changes
    bool imageChanged =
        provider.selectedImage != null || provider.isImageDeleted;

    return textFieldsChanged || imageChanged;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^\+923\d{9}$');
    return phoneRegex.hasMatch(phone);
  }

  // Helper method to safely show SnackBar
  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTexts.bodyTextStyle(
              context: context,
              textColor: AppColors.whiteColor,
            ),
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkPrimaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.darkSecondaryColor,
        elevation: 0,
        title: Text(
          'Update Profile',
          style: AppTexts.emphasizedTextStyle(
            context: context,
            textColor: AppColors.textPrimaryColor,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.primaryGradient,
            ),
          ),
        ),
      ),
      body: Consumer<UserProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: SpinKitThreeBounce(
                color: AppColors.primaryColor,
                size: 50.0,
              ),
            );
          }

          if (provider.user == null) {
            return Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.glassColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.glassBorderColor,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.errorColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load user profile',
                      style: AppTexts.emphasizedTextStyle(
                        context: context,
                        textColor: AppColors.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.loadUserProfile(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.whiteColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Retry',
                        style: AppTexts.bodyTextStyle(
                          context: context,
                          textColor: AppColors.whiteColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Avatar Section
                  _buildAvatarSection(provider),
                  const SizedBox(height: 32),

                  // Form Fields
                  _buildFormFields(provider),

                  const SizedBox(height: 32),

                  // Update Button
                  _buildUpdateButton(provider),

                  // Error Message
                  if (provider.errorMessage != null)
                    _buildErrorMessage(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarSection(UserProfileProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorderColor, width: 1),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryColor, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipOval(child: _buildProfileImage(provider)),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => provider.pickImage(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor,
                          AppColors.primaryLightColor,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: AppColors.whiteColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Tap camera icon to change photo',
            style: AppTexts.bodyTextStyle(
              context: context,
              textColor: AppColors.textSecondaryColor,
              fontSize: 14,
            ),
          ),

          // Delete Picture Button - Show only if there's an existing image
          if (_shouldShowDeleteButton(provider)) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _showDeleteConfirmationDialog(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.errorColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.delete_outline,
                      color: AppColors.errorColor,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Delete Picture',
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.errorColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileImage(UserProfileProvider provider) {
    // If image was deleted, show fallback icon
    if (provider.isImageDeleted) {
      return _buildFallbackIcon();
    }

    // If new image was selected, show it
    if (provider.selectedImage != null) {
      return Image.file(
        provider.selectedImage!,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
      );
    }

    // If user has existing image from backend, show it
    if (provider.user?.imageUrl != null &&
        provider.user!.imageUrl!.isNotEmpty) {
      return Image.memory(
        base64Decode(_extractBase64(provider.user!.imageUrl!)),
        fit: BoxFit.cover,
        width: 120,
        height: 120,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackIcon();
        },
      );
    }

    // Default fallback icon
    return _buildFallbackIcon();
  }

  bool _shouldShowDeleteButton(UserProfileProvider provider) {
    return (!provider.isImageDeleted &&
            provider.user?.imageUrl != null &&
            provider.user!.imageUrl!.isNotEmpty) ||
        provider.selectedImage != null;
  }

  Widget _buildFormFields(UserProfileProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorderColor, width: 1),
      ),
      child: Column(
        children: [
          // Name Field
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            icon: Icons.person,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              }
              if (value.trim().length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 20),

          // Email Field with verification
          _buildVerifiableTextField(
            controller: _emailController,
            label: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            isValid: _isValidEmail(_emailController.text),
            isVerified: _isEmailVerified,
            isVerifying: _isEmailVerifying,
            onVerify: _handleEmailVerification,
            enabled: !_isEmailVerified,
            showVerifyButton:
                _isValidEmail(_emailController.text) &&
                _emailController.text.trim() != _originalEmail &&
                !_isEmailVerified,
            onChanged: (value) {
              setState(() {
                if (value != _originalEmail) {
                  _isEmailVerified = false;
                  _showEmailOtp = false;
                  _emailOtpController.clear();
                }
              });
            },
          ),

          // Email OTP field
          if (_showEmailOtp) ...[
            const SizedBox(height: 20),
            _buildOtpField(
              controller: _emailOtpController,
              label: 'Enter Email OTP',
              isVerifying: _isEmailOtpVerifying,
              onVerify: _handleEmailOtpVerification,
            ),
          ],

          // Email verified indicator
          if (_isEmailVerified) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.verified, color: AppColors.successColor, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Email verified successfully',
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.successColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 20),

          // Phone Field with verification
          _buildVerifiableTextField(
            controller: _phoneController,
            label: 'Phone Number (+923xxxxxxxxx)',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            isValid: _isValidPhone(_phoneController.text),
            isVerified: _isPhoneVerified,
            isVerifying: _isPhoneVerifying,
            onVerify: _handlePhoneVerification,
            enabled: !_isPhoneVerified,
            showVerifyButton:
                _isValidPhone(_phoneController.text) &&
                _phoneController.text.trim() != _originalPhone &&
                !_isPhoneVerified,
            onChanged: (value) {
              setState(() {
                if (value != _originalPhone) {
                  _isPhoneVerified = false;
                  _showPhoneOtp = false;
                  _phoneOtpController.clear();
                }
              });
            },
          ),

          // Phone OTP field
          if (_showPhoneOtp) ...[
            if (!AppApis.isProduction) ...[
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
              Text(
                'As the application is currently in the Testing Mode, Use 123456 as your OTP',
                style: AppTexts.emphasizedTextStyle(
                  context: context,
                  textColor: AppColors.whiteColor.withOpacity(0.8),
                  fontSize: MediaQuery.sizeOf(context).width * 0.038,
                ),
              ),
            ],
            const SizedBox(height: 12),
            _buildOtpField(
              controller: _phoneOtpController,
              label: 'Enter Phone OTP',
              isVerifying: _isPhoneOtpVerifying,
              onVerify: _handlePhoneOtpVerification,
            ),
          ],

          // Phone verified indicator
          if (_isPhoneVerified) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.verified, color: AppColors.successColor, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Phone number verified successfully',
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.successColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondaryColor),
        prefixIcon: Icon(icon, color: AppColors.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.glassBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.glassBorderColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.errorColor, width: 2),
        ),
        filled: true,
        fillColor: AppColors.glassColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      style: AppTexts.bodyTextStyle(
        context: context,
        textColor: AppColors.textPrimaryColor,
      ),
    );
  }

  Widget _buildVerifiableTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required bool isValid,
    required bool isVerified,
    required bool isVerifying,
    required VoidCallback onVerify,
    required bool enabled,
    required bool showVerifyButton,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color:
              enabled
                  ? AppColors.textSecondaryColor
                  : AppColors.textSecondaryColor.withOpacity(0.6),
        ),
        prefixIcon: Icon(
          isVerified ? Icons.verified : icon,
          color: isVerified ? AppColors.successColor : AppColors.primaryColor,
        ),
        suffixIcon:
            showVerifyButton
                ? Container(
                  margin: const EdgeInsets.all(8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isVerifying ? null : onVerify,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            isVerifying
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.whiteColor,
                                    ),
                                  ),
                                )
                                : Text(
                                  'Verify',
                                  style: AppTexts.bodyTextStyle(
                                    context: context,
                                    textColor: AppColors.whiteColor,
                                    fontSize: 12,
                                  ),
                                ),
                      ),
                    ),
                  ),
                )
                : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.glassBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isVerified ? AppColors.successColor : AppColors.primaryColor,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color:
                isVerified
                    ? AppColors.successColor.withOpacity(0.6)
                    : AppColors.glassBorderColor,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.successColor.withOpacity(0.6),
          ),
        ),
        filled: true,
        fillColor:
            enabled
                ? AppColors.glassColor
                : AppColors.glassColor.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      style: AppTexts.bodyTextStyle(
        context: context,
        textColor:
            enabled
                ? AppColors.textPrimaryColor
                : AppColors.textPrimaryColor.withOpacity(0.6),
      ),
    );
  }

  Widget _buildOtpField({
    required TextEditingController controller,
    required String label,
    required bool isVerifying,
    required VoidCallback onVerify,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 6,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondaryColor),
        prefixIcon: Icon(Icons.security, color: AppColors.primaryColor),
        suffixIcon:
            controller.text.length == 6
                ? Container(
                  margin: const EdgeInsets.all(8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isVerifying ? null : onVerify,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            isVerifying
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.whiteColor,
                                    ),
                                  ),
                                )
                                : Text(
                                  'Verify',
                                  style: AppTexts.bodyTextStyle(
                                    context: context,
                                    textColor: AppColors.whiteColor,
                                    fontSize: 12,
                                  ),
                                ),
                      ),
                    ),
                  ),
                )
                : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.glassBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.glassBorderColor),
        ),
        filled: true,
        fillColor: AppColors.glassColor,
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      style: AppTexts.bodyTextStyle(
        context: context,
        textColor: AppColors.textPrimaryColor,
      ),
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildUpdateButton(UserProfileProvider provider) {
    final bool isEnabled = _hasChanges && !provider.isUpdating;

    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isEnabled
                  ? [AppColors.primaryColor, AppColors.primaryLightColor]
                  : [AppColors.greyColor, AppColors.darkGreyColor],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isEnabled ? AppColors.primaryColor : AppColors.greyColor)
                .withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isEnabled ? () => _handleUpdate(provider) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child:
            provider.isUpdating
                ? const SpinKitThreeBounce(
                  color: AppColors.whiteColor,
                  size: 20.0,
                )
                : Text(
                  'Update Profile',
                  style: AppTexts.emphasizedTextStyle(
                    context: context,
                    textColor: AppColors.whiteColor,
                    fontSize: 16,
                  ),
                ),
      ),
    );
  }

  Widget _buildErrorMessage(UserProfileProvider provider) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.errorColor),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.errorColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              provider.errorMessage!,
              style: AppTexts.bodyTextStyle(
                context: context,
                textColor: AppColors.errorColor,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: AppColors.errorColor, size: 20),
            onPressed: () => provider.clearError(),
          ),
        ],
      ),
    );
  }

  void _handleUpdate(UserProfileProvider provider) {
    if (_formKey.currentState!.validate()) {
      String? avatarBase64;

      // Only convert to base64 if a new image was selected and not deleted
      if (provider.selectedImage != null && !provider.isImageDeleted) {
        avatarBase64 = provider.imageToBase64(provider.selectedImage!);
      }

      // Prepare update data
      String? emailToUpdate =
          _isEmailVerified ? _emailController.text.trim() : null;
      String? phoneToUpdate =
          _isPhoneVerified ? _phoneController.text.trim() : null;

      provider
          .updateUserProfile(
            name: _nameController.text.trim(),
            phone: phoneToUpdate ?? _originalPhone,
            email: emailToUpdate ?? _originalEmail,
            avatar: avatarBase64,
          )
          .then((_) {
            if (mounted && provider.errorMessage == null) {
              // Update original values after successful update
              setState(() {
                _originalName = _nameController.text.trim();
                if (_isEmailVerified) {
                  _originalEmail = _emailController.text.trim();
                }
                if (_isPhoneVerified) {
                  _originalPhone = _phoneController.text.trim();
                }
              });

              _showSnackBar(
                'Profile updated successfully!',
                AppColors.successColor,
              );
            }
          });
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Delete Profile Picture',
            style: AppTexts.emphasizedTextStyle(
              context: context,
              textColor: AppColors.textPrimaryColor,
            ),
          ),
          content: Text(
            'Are you sure you want to delete your profile picture? This action cannot be undone.',
            style: AppTexts.bodyTextStyle(
              context: context,
              textColor: AppColors.textSecondaryColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: AppColors.textSecondaryColor,
                ),
              ),
            ),
            Consumer<UserProfileProvider>(
              builder: (context, provider, child) {
                return TextButton(
                  onPressed:
                      provider.isUpdating
                          ? null
                          : () async {
                            Navigator.of(dialogContext).pop();
                            final success =
                                await provider.deleteProfileImageFromServer();

                            if (mounted) {
                              if (success) {
                                _showSnackBar(
                                  'Profile picture deleted successfully!',
                                  AppColors.successColor,
                                );
                              } else {
                                _showSnackBar(
                                  provider.errorMessage ??
                                      'Failed to delete profile picture',
                                  AppColors.errorColor,
                                );
                              }
                            }
                          },
                  child:
                      provider.isUpdating
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.errorColor,
                              ),
                            ),
                          )
                          : Text(
                            'Delete',
                            style: AppTexts.bodyTextStyle(
                              context: context,
                              textColor: AppColors.errorColor,
                            ),
                          ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Email verification handlers
  Future<void> _handleEmailVerification() async {
    setState(() => _isEmailVerifying = true);

    // Call the provider method to send email OTP
    final provider = Provider.of<UserProfileProvider>(context, listen: false);
    final success = await provider.sendEmailOtp(_emailController.text.trim());

    if (mounted) {
      setState(() {
        _isEmailVerifying = false;
        if (success) {
          _showEmailOtp = true;
        }
      });

      if (success) {
        _showSnackBar(
          'OTP sent to your email successfully!',
          AppColors.successColor,
        );
      } else {
        _showSnackBar(
          'Failed to send OTP. Please try again.',
          AppColors.errorColor,
        );
      }
    }
  }

  Future<void> _handleEmailOtpVerification() async {
    setState(() => _isEmailOtpVerifying = true);

    // Call the provider method to verify email OTP
    final provider = Provider.of<UserProfileProvider>(context, listen: false);
    final success = await provider.verifyEmailOtp(
      _emailController.text.trim(),
      _emailOtpController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isEmailOtpVerifying = false;
        if (success) {
          _isEmailVerified = true;
          _showEmailOtp = false;
          _emailOtpController.clear();
        }
      });

      if (success) {
        _showSnackBar('Email verified successfully!', AppColors.successColor);
      } else {
        _showSnackBar('Invalid OTP. Please try again.', AppColors.errorColor);
      }
    }
  }

  // Phone verification handlers
  Future<void> _handlePhoneVerification() async {
    setState(() => _isPhoneVerifying = true);

    // Call the provider method to send phone OTP
    final provider = Provider.of<UserProfileProvider>(context, listen: false);
    final success = await provider.sendPhoneOtp(_phoneController.text.trim());

    if (mounted) {
      setState(() {
        _isPhoneVerifying = false;
        if (success) {
          _showPhoneOtp = true;
        }
      });

      if (success) {
        _showSnackBar(
          'OTP sent to your phone successfully!',
          AppColors.successColor,
        );
      } else {
        _showSnackBar(
          'Failed to send OTP. Please try again.',
          AppColors.errorColor,
        );
      }
    }
  }

  Future<void> _handlePhoneOtpVerification() async {
    setState(() => _isPhoneOtpVerifying = true);

    // Call the provider method to verify phone OTP
    final provider = Provider.of<UserProfileProvider>(context, listen: false);
    final success = await provider.verifyPhoneOtp(
      _phoneController.text.trim(),
      _phoneOtpController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isPhoneOtpVerifying = false;
        if (success) {
          _isPhoneVerified = true;
          _showPhoneOtp = false;
          _phoneOtpController.clear();
        }
      });

      if (success) {
        _showSnackBar(
          'Phone number verified successfully!',
          AppColors.successColor,
        );
      } else {
        _showSnackBar('Invalid OTP. Please try again.', AppColors.errorColor);
      }
    }
  }

  String _extractBase64(String dataUrl) {
    if (dataUrl.contains(',')) {
      return dataUrl.split(',').last;
    }
    return dataUrl;
  }

  /// Helper widget for fallback icon
  Widget _buildFallbackIcon() {
    return Container(
      width: 120,
      height: 120,
      color: AppColors.darkSecondaryColor,
      child: Icon(Icons.person, size: 60, color: AppColors.textSecondaryColor),
    );
  }
}
