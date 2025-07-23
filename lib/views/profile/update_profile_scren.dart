import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  final _countryController = TextEditingController();
  String _selectedGender = 'male';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<UserProfileProvider>(context, listen: false);
      provider.loadUserProfile().then((_) {
        if (provider.user != null) {
          _nameController.text = provider.user!.name;
          _phoneController.text = provider.user!.phone;
          _countryController.text = provider.user!.country;
          _selectedGender = provider.user!.gender;
        }
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    super.dispose();
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
        border: Border.all(
          color: AppColors.glassBorderColor,
          width: 1,
        ),
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
                child: ClipOval(
                  child:
                  provider.selectedImage != null
                      ? Image.file(
                    provider.selectedImage!,
                    fit: BoxFit.cover,
                    width: 120,
                    height: 120,
                  )
                      : provider.user?.imageUrl != null
                      ? Image.network(
                    provider.user!.imageUrl!,
                    fit: BoxFit.cover,
                    width: 120,
                    height: 120,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.darkSecondaryColor,
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.textSecondaryColor,
                        ),
                      );
                    },
                  )
                      : Container(
                    color: AppColors.darkSecondaryColor,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                ),
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
                        colors: [AppColors.primaryColor, AppColors.primaryLightColor],
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
        ],
      ),
    );
  }

  Widget _buildFormFields(UserProfileProvider provider) {
    return Container(
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
          ),
          const SizedBox(height: 20),

          // Phone Field
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your phone number';
              }
              if (value.trim().length < 10) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Country Field
          _buildTextField(
            controller: _countryController,
            label: 'Country',
            icon: Icons.flag,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your country';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Gender Field
          _buildGenderField(),
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
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

  Widget _buildGenderField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.glassBorderColor),
        borderRadius: BorderRadius.circular(12),
        color: AppColors.glassColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.person_outline, color: AppColors.primaryColor),
                const SizedBox(width: 12),
                Text(
                  'Gender',
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.glassBorderColor),
          RadioListTile<String>(
            title: Text(
              'Male',
              style: AppTexts.bodyTextStyle(
                context: context,
                textColor: AppColors.textPrimaryColor,
              ),
            ),
            value: 'male',
            groupValue: _selectedGender,
            activeColor: AppColors.primaryColor,
            onChanged: (value) {
              setState(() {
                _selectedGender = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: Text(
              'Female',
              style: AppTexts.bodyTextStyle(
                context: context,
                textColor: AppColors.textPrimaryColor,
              ),
            ),
            value: 'female',
            groupValue: _selectedGender,
            activeColor: AppColors.primaryColor,
            onChanged: (value) {
              setState(() {
                _selectedGender = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: Text(
              'Other',
              style: AppTexts.bodyTextStyle(
                context: context,
                textColor: AppColors.textPrimaryColor,
              ),
            ),
            value: 'other',
            groupValue: _selectedGender,
            activeColor: AppColors.primaryColor,
            onChanged: (value) {
              setState(() {
                _selectedGender = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton(UserProfileProvider provider) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: provider.isUpdating
              ? [AppColors.greyColor, AppColors.darkGreyColor]
              : [AppColors.primaryColor, AppColors.primaryLightColor],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: provider.isUpdating ? null : () => _handleUpdate(provider),
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
      if (provider.selectedImage != null) {
        avatarBase64 = provider.imageToBase64(provider.selectedImage!);
      }

      provider
          .updateUserProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        country: _countryController.text.trim(),
        gender: _selectedGender,
        avatar: avatarBase64,
      )
          .then((_) {
        if (provider.errorMessage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Profile updated successfully!',
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: AppColors.whiteColor,
                ),
              ),
              backgroundColor: AppColors.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      });
    }
  }
}