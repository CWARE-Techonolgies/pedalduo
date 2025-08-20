import 'package:flutter/material.dart';
import 'package:pedalduo/chat/message_model.dart';
import 'package:pedalduo/style/texts.dart';
import 'package:provider/provider.dart';
import '../../style/colors.dart';
import '../chat_provider.dart';

class ShowMessageAction extends StatelessWidget {
  final Message message;
  const ShowMessageAction({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // drag indicator
        Container(
          width: width * 0.1,
          height: 4,
          margin: EdgeInsets.symmetric(vertical: width * 0.02),
          decoration: BoxDecoration(
            color: AppColors.greyColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Reply option
        ListTile(
          leading: Icon(Icons.reply, color: AppColors.lightGreenColor),
          title:  Text('Reply', style: AppTexts.emphasizedTextStyle(context: context, textColor: AppColors.whiteColor),),
          onTap: () {
            Navigator.pop(context, {"action": "reply", "message": message});
          },
        ),

        // Edit & Delete only if current user
        if (context.read<ChatProvider>().isCurrentUser(message.senderId)) ...[
          ListTile(
            leading: Icon(Icons.edit, color: AppColors.lightGreenColor),
            title:  Text('Edit Message', style: AppTexts.emphasizedTextStyle(context: context, textColor: AppColors.whiteColor)),
            onTap: () {
              Navigator.pop(context, {"action": "edit", "message": message});
            },
          ),
          ListTile(
            leading: Icon(Icons.delete, color: AppColors.redColor),
            title:  Text('Delete Message', style: AppTexts.emphasizedTextStyle(context: context, textColor: AppColors.redColor)),
            onTap: () {
              Navigator.pop(context, {"action": "delete", "message": message});
            },
          ),
        ],
      ],
    );
  }
}