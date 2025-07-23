import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../style/colors.dart';
import '../../style/texts.dart';
import 'chat_provider.dart';
import 'chat_room.dart';
import 'message_model.dart';

class ChatScreen extends StatefulWidget {
  final ChatRoom chatRoom;

  const ChatScreen({super.key, required this.chatRoom});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  Timer? _typingTimer;
  ChatProvider? _chatProvider;
  bool _isSending = false;
  Message? _replyToMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ChatProvider>();
      provider.initializeCurrentUser();
      provider.fetchMessages(widget.chatRoom.id).then((_) {
        // Auto-scroll to bottom after messages are loaded
        Future.delayed(Duration(milliseconds: 100), () {
          _scrollToBottom(animate: false);
        });
      });
    });

    // Fix auto-scroll listener
    _scrollController.addListener(() {
      // Load more when scrolled to top (because reverse: true)
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        context.read<ChatProvider>().loadMoreMessages(widget.chatRoom.id);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Store the provider reference safely
    _chatProvider = context.read<ChatProvider>();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _typingTimer?.cancel();

    // Leave room when disposing
    _chatProvider?.leaveRoom();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final provider = context.read<ChatProvider>();
    if (state == AppLifecycleState.paused) {
      provider.stopTyping(widget.chatRoom.id);
    }
  }

  void _scrollToBottom({bool animate = true}) {
    if (_scrollController.hasClients) {
      if (animate) {
        _scrollController.animateTo(
          0.0, // Change to 0.0 because reverse: true
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(0.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, child) {
                if (provider.error != null) {
                  return _buildErrorState(context, provider.error!);
                }

                return _buildMessagesList(context, provider);
              },
            ),
          ),
          _buildMessageInputWithReply(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return AppBar(
      backgroundColor: AppColors.navyBlueGrey,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.whiteColor),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Row(
        children: [
          _buildAppBarAvatar(context),
          SizedBox(width: width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chatRoom.displayName,
                  style: AppTexts.emphasizedTextStyle(
                    context: context,
                    textColor: AppColors.whiteColor,
                    fontSize: width * 0.04,
                  ),
                ),
                Text(
                  widget.chatRoom.subtitle,
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.greyColor,
                    fontSize: width * 0.03,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert, color: AppColors.whiteColor),
          onPressed: () {
            // Show chat options
          },
        ),
      ],
    );
  }

  Widget _buildAppBarAvatar(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: width * 0.1,
      height: width * 0.1,
      decoration: BoxDecoration(
        gradient:
            widget.chatRoom.isTeamChat
                ? LinearGradient(
                  colors: [AppColors.orangeColor, AppColors.lightOrangeColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                : LinearGradient(
                  colors: [AppColors.greyColor, AppColors.orangeColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        borderRadius: BorderRadius.circular(width * 0.05),
      ),
      child:
          widget.chatRoom.isTeamChat
              ? Icon(
                Icons.group,
                color: AppColors.whiteColor,
                size: width * 0.05,
              )
              : Center(
                child: Text(
                  widget.chatRoom.user2?.initials ??
                      widget.chatRoom.user1?.initials ??
                      '?',
                  style: AppTexts.emphasizedTextStyle(
                    context: context,
                    textColor: AppColors.whiteColor,
                    fontSize: width * 0.03,
                  ),
                ),
              ),
    );
  }

  Widget _buildMessagesList(BuildContext context, ChatProvider provider) {
    final width = MediaQuery.of(context).size.width;

    return Skeletonizer(
      enabled: provider.isLoading,
      child:
      provider.messages.isEmpty && !provider.isLoading
          ? _buildEmptyMessagesPlaceholder(context)
          : ListView.builder(
        controller: _scrollController,
        reverse: true,
        padding: EdgeInsets.only(
          left: width * 0.04,
          right: width * 0.04,
          top: width * 0.04,
          bottom: width * 0.04, // Increase bottom padding
        ),
        itemCount:
        provider.isLoading
            ? 10
            : provider.messages.length +
            (provider.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (provider.isLoading) {
            return _buildSkeletonMessage(context, index % 2 == 0);
          }

          if (provider.isLoadingMore &&
              index == provider.messages.length) {
            return _buildLoadingMoreIndicator(context);
          }

          final messageIndex = provider.messages.length - 1 - index;
          final message = provider.messages[messageIndex];
          final isCurrentUser = provider.isCurrentUser(
            message.senderId,
          );

          return _buildMessageBubble(context, message, isCurrentUser);
        },
      ),
    );
  }

  Widget _buildEmptyMessagesPlaceholder(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: width * 0.2,
            height: width * 0.2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.orangeColor.withOpacity(0.3),
                  AppColors.darkOrangeColor.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(width * 0.1),
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: width * 0.08,
              color: AppColors.darkOrangeColor,
            ),
          ),
          SizedBox(height: width * 0.06),
          Text(
            'No messages yet',
            style: AppTexts.emphasizedTextStyle(
              context: context,
              textColor: AppColors.whiteColor,
              fontSize: width * 0.045,
            ),
          ),
          SizedBox(height: width * 0.02),
          Text(
            'Start a conversation by sending a message',
            style: AppTexts.bodyTextStyle(
              context: context,
              textColor: AppColors.greyColor,
              fontSize: width * 0.035,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonMessage(BuildContext context, bool isCurrentUser) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(bottom: width * 0.03),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            Container(
              width: width * 0.08,
              height: width * 0.08,
              decoration: BoxDecoration(
                color: AppColors.lightGreyColor,
                borderRadius: BorderRadius.circular(width * 0.04),
              ),
            ),
            SizedBox(width: width * 0.02),
          ],
          Container(
            constraints: BoxConstraints(maxWidth: width * 0.7),
            padding: EdgeInsets.all(width * 0.04),
            decoration: BoxDecoration(
              color: AppColors.lightGreyColor,
              borderRadius: BorderRadius.circular(width * 0.04),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: width * 0.3,
                  height: width * 0.03,
                  decoration: BoxDecoration(
                    color: AppColors.greyColor,
                    borderRadius: BorderRadius.circular(width * 0.015),
                  ),
                ),
                SizedBox(height: width * 0.02),
                Container(
                  width: width * 0.5,
                  height: width * 0.03,
                  decoration: BoxDecoration(
                    color: AppColors.greyColor,
                    borderRadius: BorderRadius.circular(width * 0.015),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMoreIndicator(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(width * 0.04),
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.lightGreenColor),
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    Message message,
    bool isCurrentUser,
  ) {
    final width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onLongPress: () {
        _showMessageActions(context, message);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: width * 0.03),
        child: Row(
          mainAxisAlignment:
              isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isCurrentUser) ...[
              _buildUserAvatar(context, message.sender),
              SizedBox(width: width * 0.02),
            ],
            Flexible(
              child: Container(
                constraints: BoxConstraints(maxWidth: width * 0.7),
                padding: EdgeInsets.all(width * 0.04),
                decoration: BoxDecoration(
                  gradient:
                      isCurrentUser
                          ? LinearGradient(
                            colors: [
                              AppColors.lightOrangeColor,
                              AppColors.orangeColor,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                          : null,
                  color: isCurrentUser ? null : AppColors.whiteColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(width * 0.04),
                    topRight: Radius.circular(width * 0.04),
                    bottomLeft:
                        isCurrentUser
                            ? Radius.circular(width * 0.04)
                            : Radius.circular(width * 0.01),
                    bottomRight:
                        isCurrentUser
                            ? Radius.circular(width * 0.01)
                            : Radius.circular(width * 0.04),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.greyColor.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isCurrentUser && widget.chatRoom.isTeamChat) ...[
                      Text(
                        message.sender.name,
                        style: AppTexts.bodyTextStyle(
                          context: context,
                          textColor: AppColors.lightGreenColor,
                          fontSize: width * 0.028,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: width * 0.01),
                    ],
                    if (message.isReply && message.repliedMessage != null) ...[
                      _buildReplyPreview(
                        context,
                        message.repliedMessage!,
                        isCurrentUser,
                      ),
                      SizedBox(height: width * 0.02),
                    ],
                    Text(
                      message.content,
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor:
                            isCurrentUser
                                ? AppColors.whiteColor
                                : AppColors.navyBlueGrey,
                        fontSize: width * 0.035,
                      ),
                    ),
                    SizedBox(height: width * 0.02),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatMessageTime(message.createdAt),
                          style: AppTexts.bodyTextStyle(
                            context: context,
                            textColor:
                                isCurrentUser
                                    ? AppColors.whiteColor.withOpacity(0.8)
                                    : AppColors.greyColor,
                            fontSize: width * 0.025,
                          ),
                        ),
                        if (message.isEdited) ...[
                          SizedBox(width: width * 0.01),
                          Text(
                            'edited',
                            style: AppTexts.bodyTextStyle(
                              context: context,
                              textColor:
                                  isCurrentUser
                                      ? AppColors.whiteColor.withOpacity(0.8)
                                      : AppColors.greyColor,
                              fontSize: width * 0.025,
                            ),
                          ),
                        ],
                        if (isCurrentUser) ...[
                          SizedBox(width: width * 0.01),
                          Icon(
                            message.readBy.length > 1
                                ? Icons.done_all
                                : Icons.done,
                            color: AppColors.whiteColor.withOpacity(0.8),
                            size: width * 0.04,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isCurrentUser) ...[
              SizedBox(width: width * 0.02),
              _buildUserAvatar(context, message.sender),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReplyPreviewBar(BuildContext context) {
    if (_replyToMessage == null) return SizedBox.shrink();

    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(width * 0.03),
      decoration: BoxDecoration(
        color: AppColors.lightGreyColor,
        border: Border(
          bottom: BorderSide(color: AppColors.greyColor.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: width * 0.1,
            decoration: BoxDecoration(
              color: AppColors.lightGreenColor,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          SizedBox(width: width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${_replyToMessage!.sender.name}',
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.lightGreenColor,
                    fontSize: width * 0.03,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: width * 0.01),
                Text(
                  _replyToMessage!.content,
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.greyColor,
                    fontSize: width * 0.032,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: AppColors.greyColor),
            onPressed: () {
              setState(() {
                _replyToMessage = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInputWithReply(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTypingIndicator(context),
          _buildReplyPreviewBar(context),
          _buildMessageInput(context),
        ],
      ),
    );
  }

  void _showEditMessageDialog(BuildContext context, Message message) {
    final editController = TextEditingController(text: message.content);
    final width = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(width * 0.04),
          ),
          title: Row(
            children: [
              Icon(Icons.edit, color: AppColors.lightGreenColor),
              SizedBox(width: width * 0.02),
              Text(
                'Edit Message',
                style: AppTexts.emphasizedTextStyle(
                  context: context,
                  textColor: AppColors.navyBlueGrey,
                  fontSize: width * 0.04,
                ),
              ),
            ],
          ),
          content: Container(
            width: width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  constraints: BoxConstraints(maxHeight: width * 0.4),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.lightGreyColor),
                    borderRadius: BorderRadius.circular(width * 0.03),
                  ),
                  child: TextField(
                    controller: editController,
                    maxLines: null,
                    autofocus: true,
                    style: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: AppColors.navyBlueGrey,
                      fontSize: width * 0.035,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                      hintStyle: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.greyColor,
                        fontSize: width * 0.035,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(width * 0.04),
                    ),
                  ),
                ),
                SizedBox(height: width * 0.04),
                Text(
                  'Original: ${message.content}',
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.greyColor,
                    fontSize: width * 0.03,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: AppColors.greyColor,
                  fontSize: width * 0.035,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (editController.text.trim().isNotEmpty &&
                    editController.text.trim() != message.content) {
                  context.read<ChatProvider>().editMessage(
                    message.id,
                    editController.text.trim(),
                  );
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightGreenColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(width * 0.02),
                ),
              ),
              child: Text(
                'Save',
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: AppColors.whiteColor,
                  fontSize: width * 0.035,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReplyPreview(
    BuildContext context,
    Message repliedMessage,
    bool isCurrentUser,
  ) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(width * 0.03),
      decoration: BoxDecoration(
        color:
            isCurrentUser
                ? AppColors.whiteColor.withOpacity(0.2)
                : AppColors.lightGreyColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(width * 0.02),
        border: Border(
          left: BorderSide(
            color:
                isCurrentUser
                    ? AppColors.whiteColor
                    : AppColors.lightGreenColor,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            repliedMessage.sender.name,
            style: AppTexts.bodyTextStyle(
              context: context,
              textColor:
                  isCurrentUser
                      ? AppColors.whiteColor.withOpacity(0.9)
                      : AppColors.lightGreenColor,
              fontSize: width * 0.028,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: width * 0.01),
          Text(
            repliedMessage.content,
            style: AppTexts.bodyTextStyle(
              context: context,
              textColor:
                  isCurrentUser
                      ? AppColors.whiteColor.withOpacity(0.8)
                      : AppColors.greyColor,
              fontSize: width * 0.03,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context, User user) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: width * 0.08,
      height: width * 0.08,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.blueColor, AppColors.purpleColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(width * 0.04),
      ),
      child:
          user.avatarUrl != null
              ? ClipRRect(
                borderRadius: BorderRadius.circular(width * 0.04),
                child: Image.network(
                  user.avatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        user.initials,
                        style: AppTexts.emphasizedTextStyle(
                          context: context,
                          textColor: AppColors.whiteColor,
                          fontSize: width * 0.025,
                        ),
                      ),
                    );
                  },
                ),
              )
              : Center(
                child: Text(
                  user.initials,
                  style: AppTexts.emphasizedTextStyle(
                    context: context,
                    textColor: AppColors.whiteColor,
                    fontSize: width * 0.025,
                  ),
                ),
              ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.navyBlueGrey,
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: width * 0.04,
          right: width * 0.04,
          top: width * 0.02,
          bottom: width * 0.02,
        ),
        child: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: width * 0.3, // Limit height
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreyColor,
                    borderRadius: BorderRadius.circular(width * 0.08),
                  ),
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    style: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: AppColors.whiteColor,
                      fontSize: width * 0.035,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.greyColor,
                        fontSize: width * 0.035,
                      ),
                      fillColor: AppColors.lightNavyBlueGrey,
                      filled: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: width * 0.04,
                        vertical: width * 0.03,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                      context.read<ChatProvider>().onTypingChanged(
                        value,
                        widget.chatRoom.id,
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: width * 0.02),
              Consumer<ChatProvider>(
                builder: (context, provider, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.lightOrangeColor,
                          AppColors.orangeColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(width * 0.06),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(width * 0.06),
                        onTap:
                            (_messageController.text.trim().isEmpty ||
                                    provider.isSending ||
                                    _isSending)
                                ? null
                                : () async {
                                  if (_isSending) return;

                                  _isSending = true;
                                  final message =
                                      _messageController.text.trim();
                                  final replyToId = _replyToMessage?.id;

                                  _messageController.clear();

                                  // Clear reply state
                                  setState(() {
                                    _replyToMessage = null;
                                  });

                                  try {
                                    await provider.sendMessage(
                                      widget.chatRoom.id,
                                      message,
                                      replyToMessageId: replyToId,
                                    );
                                    provider.stopTyping(widget.chatRoom.id);
                                    _focusNode.unfocus();
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          Future.delayed(
                                            Duration(milliseconds: 100),
                                            () {
                                              _scrollToBottom();
                                            },
                                          );
                                        });
                                  } finally {
                                    _isSending = false;
                                  }
                                },
                        child: SizedBox(
                          width: width * 0.12,
                          height: width * 0.12,
                          child:
                              (provider.isSending || _isSending)
                                  ? SizedBox(
                                    width: width * 0.04,
                                    height: width * 0.04,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.whiteColor,
                                      ),
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Icon(
                                    Icons.send,
                                    color: AppColors.whiteColor,
                                    size: width * 0.05,
                                  ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    final width = MediaQuery.of(context).size.width;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: width * 0.15,
            color: AppColors.redColor,
          ),
          SizedBox(height: width * 0.04),
          Text(
            'Something went wrong',
            style: AppTexts.emphasizedTextStyle(
              context: context,
              textColor: AppColors.navyBlueGrey,
              fontSize: width * 0.04,
            ),
          ),
          SizedBox(height: width * 0.02),
          Text(
            error,
            style: AppTexts.bodyTextStyle(
              context: context,
              textColor: AppColors.greyColor,
              fontSize: width * 0.032,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: width * 0.06),
          ElevatedButton(
            onPressed: () {
              context.read<ChatProvider>().refresh(widget.chatRoom.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightGreenColor,
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.08,
                vertical: width * 0.04,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(width * 0.03),
              ),
            ),
            child: Text(
              'Retry',
              style: AppTexts.emphasizedTextStyle(
                context: context,
                textColor: AppColors.whiteColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return DateFormat('MMM d, HH:mm').format(dateTime);
    } else {
      return DateFormat('HH:mm').format(dateTime);
    }
  }

  Widget _buildTypingIndicator(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Consumer<ChatProvider>(
      builder: (context, provider, child) {
        if (provider.typingUsers.isEmpty) {
          return SizedBox.shrink();
        }

        final typingText =
            provider.typingUsers.length == 1
                ? '${provider.typingUsers.values.first} is typing...'
                : '${provider.typingUsers.length} people are typing...';

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.04,
            vertical: width * 0.02,
          ),
          child: Row(
            children: [
              SizedBox(
                // width: width * 0.01,
                height: width * 0.01,
                child: SpinKitThreeBounce(color: AppColors.greenColor),
              ),
              SizedBox(width: width * 0.02),
              Text(
                typingText,
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: AppColors.greenColor,
                  fontSize: width * 0.03,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMessageActions(BuildContext context, Message message) {
    final width = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(width * 0.05)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: width * 0.1,
                height: 4,
                margin: EdgeInsets.symmetric(vertical: width * 0.02),
                decoration: BoxDecoration(
                  color: AppColors.greyColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(Icons.reply, color: AppColors.lightGreenColor),
                title: Text('Reply'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _replyToMessage = message;
                  });
                  _focusNode.requestFocus();
                },
              ),
              if (context.read<ChatProvider>().isCurrentUser(
                message.senderId,
              )) ...[
                ListTile(
                  leading: Icon(Icons.edit, color: AppColors.lightGreenColor),
                  title: Text('Edit Message'),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditMessageDialog(context, message);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete, color: AppColors.redColor),
                  title: Text('Delete Message'),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(context, message);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // Add delete confirmation
  void _showDeleteConfirmation(BuildContext context, Message message) {
    final width = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(width * 0.04),
          ),
          title: Text('Delete Message'),
          content: Text('Are you sure you want to delete this message?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<ChatProvider>().deleteMessage(message.id);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redColor,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
