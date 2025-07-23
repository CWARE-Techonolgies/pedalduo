import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../style/colors.dart';
import '../../style/texts.dart';
import 'easy_paisa_payment_provider.dart';

class EasyPaisaPaymentDialog extends StatefulWidget {
  final double amount;
  final String tournamentId;
  final VoidCallback onPaymentSuccess;

  const EasyPaisaPaymentDialog({
    super.key,
    required this.amount,
    required this.tournamentId,
    required this.onPaymentSuccess,
  });

  @override
  State<EasyPaisaPaymentDialog> createState() => _EasyPaisaPaymentDialogState();
}

class _EasyPaisaPaymentDialogState extends State<EasyPaisaPaymentDialog>
    with TickerProviderStateMixin {
  final _mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Consumer<EasyPaisaPaymentProvider>(
      builder: (context, paymentProvider, child) {
        return AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  width: screenWidth * 0.9,
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blackColor.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              width: screenWidth * 0.12,
                              height: screenWidth * 0.12,
                              decoration: BoxDecoration(
                                color: AppColors.lightGreenColor.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(
                                  screenWidth * 0.03,
                                ),
                              ),
                              child: Icon(
                                Icons.payment,
                                color: AppColors.lightGreenColor,
                                size: screenWidth * 0.06,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'EasyPaisa Payment',
                                    style: AppTexts.emphasizedTextStyle(
                                      context: context,
                                      textColor: AppColors.blackColor,
                                      fontSize: screenWidth * 0.045,
                                    ),
                                  ),
                                  Text(
                                    'Rs. ${widget.amount.toStringAsFixed(0)}',
                                    style: AppTexts.bodyTextStyle(
                                      context: context,
                                      textColor: AppColors.lightGreenColor,
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(
                                Icons.close,
                                color: AppColors.greyColor,
                                size: screenWidth * 0.06,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: screenHeight * 0.03),

                        // Mobile Number Input
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.lightGreyColor,
                            borderRadius: BorderRadius.circular(
                              screenWidth * 0.03,
                            ),
                            border: Border.all(
                              color: AppColors.greyColor.withOpacity(0.3),
                            ),
                          ),
                          child: TextFormField(
                            controller: _mobileController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            decoration: InputDecoration(
                              hintText: '03XXXXXXXXX',
                              hintStyle: AppTexts.bodyTextStyle(
                                context: context,
                                textColor: AppColors.greyColor,
                              ),
                              prefixIcon: Icon(
                                Icons.phone,
                                color: AppColors.lightGreenColor,
                                size: screenWidth * 0.05,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04,
                                vertical: screenHeight * 0.02,
                              ),
                            ),
                            style: AppTexts.bodyTextStyle(
                              context: context,
                              textColor: AppColors.blackColor,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter mobile number';
                              }
                              if (value.length != 11 ||
                                  !value.startsWith('03')) {
                                return 'Please enter valid mobile number';
                              }
                              return null;
                            },
                          ),
                        ),

                        if (paymentProvider.errorMessage != null) ...[
                          SizedBox(height: screenHeight * 0.02),
                          Container(
                            padding: EdgeInsets.all(screenWidth * 0.03),
                            decoration: BoxDecoration(
                              color: AppColors.redColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                screenWidth * 0.02,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: AppColors.redColor,
                                  size: screenWidth * 0.05,
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Expanded(
                                  child: Text(
                                    paymentProvider.errorMessage!,
                                    style: AppTexts.bodyTextStyle(
                                      context: context,
                                      textColor: AppColors.redColor,
                                      fontSize: screenWidth * 0.035,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        SizedBox(height: screenHeight * 0.03),

                        // Payment Button
                        SizedBox(
                          width: double.infinity,
                          height: screenHeight * 0.06,
                          child: ElevatedButton(
                            onPressed:
                                paymentProvider.isProcessingPayment
                                    ? null
                                    : () => _processPayment(
                                      context,
                                      paymentProvider,
                                    ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.lightGreenColor,
                              foregroundColor: AppColors.whiteColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  screenWidth * 0.03,
                                ),
                              ),
                            ),
                            child:
                                paymentProvider.isProcessingPayment
                                    ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: screenWidth * 0.05,
                                          height: screenWidth * 0.05,
                                          child:
                                              const CircularProgressIndicator(
                                                color: AppColors.whiteColor,
                                                strokeWidth: 2,
                                              ),
                                        ),
                                        SizedBox(width: screenWidth * 0.03),
                                        Text(
                                          'Processing...',
                                          style: AppTexts.bodyTextStyle(
                                            context: context,
                                            textColor: AppColors.whiteColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    )
                                    : Text(
                                      'Pay Now',
                                      style: AppTexts.bodyTextStyle(
                                        context: context,
                                        textColor: AppColors.whiteColor,
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
            );
          },
        );
      },
    );
  }

  Future<void> _processPayment(
    BuildContext context,
    EasyPaisaPaymentProvider paymentProvider,
  ) async {
    // if (!_formKey.currentState!.validate()) return;
    //
    // paymentProvider.clearError();
    //
    // // Get email from UserProfileProvider instead of API call
    // final userProfileProvider = Provider.of<UserProfileProvider>(
    //   context,
    //   listen: false,
    // );
    //
    // // Ensure user data is loaded
    // if (userProfileProvider.user == null) {
    //   await userProfileProvider.initializeUser();
    // }
    //
    // final email = userProfileProvider.user?.email;
    //
    // if (email == null || email.isEmpty) {
    //   if (kDebugMode) {
    //     print('User email not found. Please login again.');
    //   }
    //   return;
    // }
    //
    // // Initialize payment
    // paymentProvider.initializePayment(
    //   mobileNumber: _mobileController.text,
    //   email: email,
    //   amount: widget.amount,
    //   tournamentId: widget.tournamentId,
    // );

    // Process payment
    // final success =
    await paymentProvider.confirmPaymentWithBackend(
      int.parse(widget.tournamentId),
      context,
    );

    // if (success) {
    Navigator.of(context).pop();
    // widget.onPaymentSuccess();
    _showSuccessDialog(context);
    // }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.whiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                MediaQuery.of(context).size.width * 0.04,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.lightGreenColor,
                  size: MediaQuery.of(context).size.width * 0.15,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Text(
                  'Payment Successful!',
                  style: AppTexts.emphasizedTextStyle(
                    context: context,
                    textColor: AppColors.blackColor,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  'Your tournament payment has been processed successfully.',
                  textAlign: TextAlign.center,
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.greyColor,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightGreenColor,
                      foregroundColor: AppColors.whiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.width * 0.03,
                        ),
                      ),
                    ),
                    child: Text(
                      'Continue',
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.whiteColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
