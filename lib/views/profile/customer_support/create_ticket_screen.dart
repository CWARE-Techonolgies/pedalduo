// screens/create_ticket_screen.dart
import 'package:flutter/material.dart';
import 'package:pedalduo/views/profile/customer_support/support_model.dart';
import 'package:pedalduo/views/profile/customer_support/support_provider.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../../style/colors.dart';
import '../../../style/texts.dart';
import '../../../utils/app_utils.dart';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({Key? key}) : super(key: key);

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _metadataController = TextEditingController();

  TicketCategory _selectedCategory = TicketCategory.generalInquiry;
  TicketPriority _selectedPriority = TicketPriority.medium;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    _metadataController.dispose();
    super.dispose();
  }

  void _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<SupportTicketProvider>();

    Map<String, dynamic>? metadata;
    if (_metadataController.text.isNotEmpty) {
      metadata = {
        'additional_info': _metadataController.text,
        'created_from': 'mobile_app',
      };
    }

    final request = CreateTicketRequest(
      subject: _subjectController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory.value,
      priority: _selectedPriority.value,
      metadata: metadata,
    );

    final success = await provider.createTicket(request);

    if (success && mounted) {
      AppUtils.showSuccessSnackBar(
        context,
        'Support ticket created successfully!',
      );
      Navigator.pop(context);
    } else if (mounted) {
      AppUtils.showFailureSnackBar(
        context,
        provider.error ?? 'Failed to create ticket',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.darkPrimaryColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.primaryGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, screenSize),
              Expanded(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildForm(context, screenSize),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Size screenSize) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        border: Border(
          bottom: BorderSide(
            color: AppColors.glassBorderColor,
            width: 1,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.glassColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.glassBorderColor,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimaryColor,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Support Ticket',
                      style: AppTexts.emphasizedTextStyle(
                        context: context,
                        textColor: AppColors.textPrimaryColor,
                        fontSize: screenSize.width * 0.045,
                      ),
                    ),
                    Text(
                      'We\'re here to help you',
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.textSecondaryColor,
                        fontSize: screenSize.width * 0.032,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, Size screenSize) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSubjectField(context, screenSize),
            const SizedBox(height: 20),
            _buildCategorySelector(context, screenSize),
            const SizedBox(height: 20),
            _buildPrioritySelector(context, screenSize),
            const SizedBox(height: 20),
            _buildDescriptionField(context, screenSize),
            const SizedBox(height: 20),
            _buildMetadataField(context, screenSize),
            const SizedBox(height: 40),
            _buildSubmitButton(context, screenSize),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectField(BuildContext context, Size screenSize) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorderColor, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.title_rounded,
                        color: AppColors.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Subject',
                      style: AppTexts.emphasizedTextStyle(
                        context: context,
                        textColor: AppColors.textPrimaryColor,
                        fontSize: screenSize.width * 0.04,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _subjectController,
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.textPrimaryColor,
                    fontSize: screenSize.width * 0.034,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Brief description of your issue',
                    hintStyle: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: AppColors.textTertiaryColor,
                      fontSize: screenSize.width * 0.034,
                    ),
                    filled: true,
                    fillColor: AppColors.glassLightColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.glassBorderColor,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.glassBorderColor,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryColor,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.errorColor,
                        width: 1,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.errorColor,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a subject';
                    }
                    if (value.trim().length < 5) {
                      return 'Subject must be at least 5 characters';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context, Size screenSize) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorderColor, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accentBlueColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.accentBlueColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.category_rounded,
                        color: AppColors.accentBlueColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Category',
                      style: AppTexts.emphasizedTextStyle(
                        context: context,
                        textColor: AppColors.textPrimaryColor,
                        fontSize: screenSize.width * 0.04,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: TicketCategory.values.map((category) {
                    final isSelected = _selectedCategory == category;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryColor.withOpacity(0.2)
                              : AppColors.glassLightColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryColor.withOpacity(0.5)
                                : AppColors.glassBorderColor,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              category.icon,
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : AppColors.textSecondaryColor,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              category.displayName,
                              style: AppTexts.bodyTextStyle(
                                context: context,
                                textColor: isSelected
                                    ? AppColors.primaryColor
                                    : AppColors.textSecondaryColor,
                                fontSize: screenSize.width * 0.03,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrioritySelector(BuildContext context, Size screenSize) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorderColor, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.warningColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.warningColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.priority_high_rounded,
                        color: AppColors.warningColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Priority',
                      style: AppTexts.emphasizedTextStyle(
                        context: context,
                        textColor: AppColors.textPrimaryColor,
                        fontSize: screenSize.width * 0.04,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: TicketPriority.values.map((priority) {
                    final isSelected = _selectedPriority == priority;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPriority = priority;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? priority.color.withOpacity(0.2)
                                : AppColors.glassLightColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? priority.color.withOpacity(0.5)
                                  : AppColors.glassBorderColor,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            priority.displayName,
                            textAlign: TextAlign.center,
                            style: AppTexts.bodyTextStyle(
                              context: context,
                              textColor: isSelected
                                  ? priority.color
                                  : AppColors.textSecondaryColor,
                              fontSize: screenSize.width * 0.028,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionField(BuildContext context, Size screenSize) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorderColor, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accentPurpleColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.accentPurpleColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.description_rounded,
                        color: AppColors.accentPurpleColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Description',
                      style: AppTexts.emphasizedTextStyle(
                        context: context,
                        textColor: AppColors.textPrimaryColor,
                        fontSize: screenSize.width * 0.04,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.textPrimaryColor,
                    fontSize: screenSize.width * 0.034,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Please provide detailed information about your issue...',
                    hintStyle: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: AppColors.textTertiaryColor,
                      fontSize: screenSize.width * 0.034,
                    ),
                    filled: true,
                    fillColor: AppColors.glassLightColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.glassBorderColor,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.glassBorderColor,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryColor,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.errorColor,
                        width: 1,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.errorColor,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please provide a description';
                    }
                    if (value.trim().length < 20) {
                      return 'Description must be at least 20 characters';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataField(BuildContext context, Size screenSize) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorderColor, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accentCyanColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.accentCyanColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.accentCyanColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Additional Information',
                            style: AppTexts.emphasizedTextStyle(
                              context: context,
                              textColor: AppColors.textPrimaryColor,
                              fontSize: screenSize.width * 0.04,
                            ),
                          ),
                          Text(
                            'Optional • Any extra details that might help',
                            style: AppTexts.bodyTextStyle(
                              context: context,
                              textColor: AppColors.textTertiaryColor,
                              fontSize: screenSize.width * 0.028,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _metadataController,
                  maxLines: 3,
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.textPrimaryColor,
                    fontSize: screenSize.width * 0.034,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Error codes, transaction IDs, or other relevant details...',
                    hintStyle: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: AppColors.textTertiaryColor,
                      fontSize: screenSize.width * 0.034,
                    ),
                    filled: true,
                    fillColor: AppColors.glassLightColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.glassBorderColor,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.glassBorderColor,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryColor,
                        width: 2,
                      ),
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

  Widget _buildSubmitButton(BuildContext context, Size screenSize) {
    return Consumer<SupportTicketProvider>(
      builder: (context, provider, _) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryColor,
                AppColors.primaryLightColor,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: provider.isCreatingTicket ? null : _submitTicket,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: AppColors.whiteColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            child: provider.isCreatingTicket
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.whiteColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Creating Ticket...',
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.whiteColor,
                    fontSize: screenSize.width * 0.036,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.send_rounded,
                  color: AppColors.whiteColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Submit Ticket',
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.whiteColor,
                    fontSize: screenSize.width * 0.036,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}