import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../style/colors.dart';
import '../../style/texts.dart';
import '../chat_provider.dart';
import '../message_model.dart';

class ChatDialogues{
  void showDeleteConfirmation(BuildContext context, Message message) {
    final width = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(width * 0.04),
          ),
          title: Text('Delete Message', style: AppTexts.emphasizedTextStyle(context: context, textColor: AppColors.redColor)),
          content: Text('Are you sure you want to delete this message?', style: AppTexts.bodyTextStyle(context: context, textColor: AppColors.whiteColor)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppTexts.emphasizedTextStyle(context: context, textColor: AppColors.whiteColor)),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<ChatProvider>().deleteMessage(message.id);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redColor,
              ),
              child: Text('Delete', style: AppTexts.emphasizedTextStyle(context: context, textColor: AppColors.whiteColor)),
            ),
          ],
        );
      },
    );
  }

}