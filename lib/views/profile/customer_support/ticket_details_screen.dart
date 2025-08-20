// screens/ticket_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:pedalduo/views/profile/customer_support/support_model.dart';
import 'package:pedalduo/views/profile/customer_support/support_provider.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../../style/colors.dart';
import 'package:intl/intl.dart';

import '../../../style/texts.dart';
import '../../../utils/app_utils.dart';
import 'customer_skelton.dart';

class TicketDetailScreen extends StatefulWidget {
  final int ticketId;

  const TicketDetailScreen({Key? key, required this.ticketId}) : super(key: key);

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen>
    with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isMessageExpanded = false;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupportTicketProvider>().fetchTicketById(widget.ticketId);
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text
        .trim()
        .isEmpty) return;

    final provider = context.read<SupportTicketProvider>();
    final request = CreateMessageRequest(
        message: _messageController.text.trim());

    final success = await provider.sendMessage(widget.ticketId, request);

    if (success && mounted) {
      _messageController.clear();
      _isMessageExpanded = false;
      // AppUtils.showSuccessSnackBar(context, 'Message sent successfully!');

      // Scroll to bottom to show new message
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } else if (mounted) {
      AppUtils.showFailureSnackBar(
        context,
        provider.error ?? 'Failed to send message',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery
        .of(context)
        .size;

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
                child: Consumer<SupportTicketProvider>(
                  builder: (context, provider, _) {
                    if (provider.error != null &&
                        provider.selectedTicket == null) {
                      return _buildErrorState(context, provider.error!);
                    }

                    if (provider.isLoadingMessages &&
                        provider.selectedTicket == null) {
                      return _buildLoadingState();
                    }

                    if (provider.selectedTicket == null) {
                      return _buildEmptyState(context);
                    }

                    return AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: _buildTicketContent(
                                context, provider.selectedTicket!, screenSize),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              _buildMessageInput(context, screenSize),
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
                child: Consumer<SupportTicketProvider>(
                  builder: (context, provider, _) {
                    final ticket = provider.selectedTicket;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket?.ticketNumber ?? 'Loading...',
                          style: AppTexts.emphasizedTextStyle(
                            context: context,
                            textColor: AppColors.textPrimaryColor,
                            fontSize: screenSize.width * 0.04,
                          ),
                        ),
                        if (ticket != null)
                          Text(
                            ticket.subject,
                            style: AppTexts.bodyTextStyle(
                              context: context,
                              textColor: AppColors.textSecondaryColor,
                              fontSize: screenSize.width * 0.032,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    );
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  context.read<SupportTicketProvider>().fetchTicketById(
                      widget.ticketId);
                },
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
                    Icons.refresh_rounded,
                    color: AppColors.textSecondaryColor,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketContent(BuildContext context, SupportTicket ticket,
      Size screenSize) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTicketHeader(context, ticket, screenSize),
          const SizedBox(height: 20),
          _buildTicketDescription(context, ticket, screenSize),
          const SizedBox(height: 20),
          _buildMessagesSection(context, ticket, screenSize),
          const SizedBox(height: 100), // Extra space for message input
        ],
      ),
    );
  }

  Widget _buildTicketHeader(BuildContext context, SupportTicket ticket,
      Size screenSize) {
    final category = TicketCategory.fromValue(ticket.category);
    final priority = TicketPriority.fromValue(ticket.priority);
    final status = TicketStatus.fromValue(ticket.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      ticket.subject,
                      style: AppTexts.emphasizedTextStyle(
                        context: context,
                        textColor: AppColors.textPrimaryColor,
                        fontSize: screenSize.width * 0.042,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: status.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: status.color.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      status.displayName,
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: status.color,
                        fontSize: screenSize.width * 0.028,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.glassLightColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      category.icon,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    category.displayName,
                    style: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: AppColors.textSecondaryColor,
                      fontSize: screenSize.width * 0.032,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: priority.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: priority.color.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      priority.displayName,
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: priority.color,
                        fontSize: screenSize.width * 0.028,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    color: AppColors.textTertiaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Created ${DateFormat('MMM dd, yyyy • hh:mm a').format(
                        ticket.createdAt)}',
                    style: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: AppColors.textTertiaryColor,
                      fontSize: screenSize.width * 0.028,
                    ),
                  ),
                ],
              ),
              if (ticket.assignedAdmin != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.successColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: AppColors.successColor,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Assigned to ${ticket.assignedAdmin!.name}',
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.successColor,
                        fontSize: screenSize.width * 0.028,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketDescription(BuildContext context, SupportTicket ticket,
      Size screenSize) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorderColor, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Issue Description',
                    style: AppTexts.emphasizedTextStyle(
                      context: context,
                      textColor: AppColors.textPrimaryColor,
                      fontSize: screenSize.width * 0.038,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                ticket.description,
                style: AppTexts.bodyTextStyle(
                  context: context,
                  textColor: AppColors.textSecondaryColor,
                  fontSize: screenSize.width * 0.034,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesSection(BuildContext context, SupportTicket ticket,
      Size screenSize) {
    if (ticket.messages.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.glassColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorderColor, width: 1),
        ),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlueColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: AppColors.accentBlueColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Messages Yet',
                    style: AppTexts.emphasizedTextStyle(
                      context: context,
                      textColor: AppColors.textPrimaryColor,
                      fontSize: screenSize.width * 0.036,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start the conversation by sending a message below',
                    textAlign: TextAlign.center,
                    style: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: AppColors.textSecondaryColor,
                      fontSize: screenSize.width * 0.03,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

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
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
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
                        Icons.chat_rounded,
                        color: AppColors.accentBlueColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Messages',
                      style: AppTexts.emphasizedTextStyle(
                        context: context,
                        textColor: AppColors.textPrimaryColor,
                        fontSize: screenSize.width * 0.038,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentBlueColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${ticket.messages.length}',
                        style: AppTexts.bodyTextStyle(
                          context: context,
                          textColor: AppColors.accentBlueColor,
                          fontSize: screenSize.width * 0.026,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                color: AppColors.glassBorderColor,
                height: 1,
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: ticket.messages.map((message) {
                    return _buildMessageBubble(context, message, screenSize);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, TicketMessage message,
      Size screenSize) {
    final isUser = message.senderType == 'user';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment
            .start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.successColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.successColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.support_agent_rounded,
                color: AppColors.successColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: screenSize.width * 0.75,
              ),
              child: Column(
                crossAxisAlignment: isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? AppColors.primaryColor.withOpacity(0.2)
                          : AppColors.glassLightColor,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isUser ? const Radius.circular(4) : null,
                        bottomLeft: !isUser ? const Radius.circular(4) : null,
                      ),
                      border: Border.all(
                        color: isUser
                            ? AppColors.primaryColor.withOpacity(0.3)
                            : AppColors.glassBorderColor,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      message.message,
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.textPrimaryColor,
                        fontSize: screenSize.width * 0.032,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd • hh:mm a').format(message.createdAt),
                    style: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: AppColors.textTertiaryColor,
                      fontSize: screenSize.width * 0.026,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.person_rounded,
                color: AppColors.primaryColor,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }


  Widget _buildMessageInput(BuildContext context, Size screenSize) {
    return Consumer<SupportTicketProvider>(
      builder: (context, provider, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: BoxDecoration(
            color: AppColors.glassColor,
            border: Border(
              top: BorderSide(
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
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight: 48,
                        maxHeight: _isMessageExpanded ? 120 : 48,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.glassLightColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.glassBorderColor,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _messageController,
                        maxLines: _isMessageExpanded ? 4 : 1,
                        enabled: !provider.isSendingMessage,
                        style: AppTexts.bodyTextStyle(
                          context: context,
                          textColor: AppColors.textPrimaryColor,
                          fontSize: screenSize.width * 0.034,
                        ),
                        decoration: InputDecoration(
                          hintText: provider.isSendingMessage
                              ? 'Sending...'
                              : 'Type your message...',
                          hintStyle: AppTexts.bodyTextStyle(
                            context: context,
                            textColor: AppColors.textTertiaryColor,
                            fontSize: screenSize.width * 0.034,
                          ),
                          border: InputBorder.none,
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isMessageExpanded = !_isMessageExpanded;
                              });
                            },
                            child: Icon(
                              _isMessageExpanded
                                  ? Icons.unfold_less_rounded
                                  : Icons.unfold_more_rounded,
                              color: AppColors.textTertiaryColor,
                              size: 20,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: _messageController.text.trim().isNotEmpty && !provider.isSendingMessage
                          ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryColor,
                          AppColors.primaryLightColor,
                        ],
                      )
                          : null,
                      color: _messageController.text.trim().isEmpty || provider.isSendingMessage
                          ? AppColors.glassColor
                          : null,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _messageController.text.trim().isNotEmpty && !provider.isSendingMessage
                            ? AppColors.primaryColor.withOpacity(0.3)
                            : AppColors.glassBorderColor,
                        width: 1,
                      ),
                      boxShadow: _messageController.text.trim().isNotEmpty && !provider.isSendingMessage
                          ? [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: _messageController.text.trim().isNotEmpty && !provider.isSendingMessage
                                ? _sendMessage
                                : null,
                            child: Container(
                              width: 48,
                              height: 48,
                              child: provider.isSendingMessage
                                  ? Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.textTertiaryColor,
                                    ),
                                  ),
                                ),
                              )
                                  : Icon(
                                Icons.send_rounded,
                                color: _messageController.text.trim().isNotEmpty
                                    ? AppColors.whiteColor
                                    : AppColors.textTertiaryColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
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

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Skeleton
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.glassColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorderColor, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: SkeletonLoader(
                              height: 20,
                              width: double.infinity,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(width: 16),
                          SkeletonLoader(
                            height: 24,
                            width: 80,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          SkeletonLoader(
                            height: 36,
                            width: 36,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          const SizedBox(width: 12),
                          SkeletonLoader(
                            height: 16,
                            width: 120,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          const Spacer(),
                          SkeletonLoader(
                            height: 20,
                            width: 60,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SkeletonLoader(
                        height: 12,
                        width: 200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      
            const SizedBox(height: 20),
      
            // Description Skeleton
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.glassColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorderColor, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SkeletonLoader(
                            height: 34,
                            width: 34,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          const SizedBox(width: 12),
                          SkeletonLoader(
                            height: 18,
                            width: 140,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SkeletonLoader(
                        height: 14,
                        width: double.infinity,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(height: 8),
                      SkeletonLoader(
                        height: 14,
                        width: double.infinity,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(height: 8),
                      SkeletonLoader(
                        height: 14,
                        width: 250,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      
            const SizedBox(height: 20),
      
            // Messages Skeleton
            Container(
              decoration: BoxDecoration(
                color: AppColors.glassColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorderColor, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            SkeletonLoader(
                              height: 34,
                              width: 34,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            const SizedBox(width: 12),
                            SkeletonLoader(
                              height: 18,
                              width: 80,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            const Spacer(),
                            SkeletonLoader(
                              height: 20,
                              width: 20,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        color: AppColors.glassBorderColor,
                        height: 1,
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: List.generate(3, (index) =>
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  mainAxisAlignment: index.isEven
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  children: [
                                    if (index.isOdd) ...[
                                      SkeletonLoader(
                                        height: 32,
                                        width: 32,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: index.isEven
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                        children: [
                                          SkeletonLoader(
                                            height: 40,
                                            width: 200 + (index * 30).toDouble(),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          const SizedBox(height: 4),
                                          SkeletonLoader(
                                            height: 10,
                                            width: 80,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (index.isEven) ...[
                                      const SizedBox(width: 8),
                                      SkeletonLoader(
                                        height: 32,
                                        width: 32,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ],
                                  ],
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
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.glassColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorderColor, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.errorColor,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Something went wrong',
                    style: AppTexts.emphasizedTextStyle(
                      context: context,
                      textColor: AppColors.textPrimaryColor,
                      fontSize: MediaQuery.of(context).size.width * 0.042,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    error,
                    textAlign: TextAlign.center,
                    style: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: AppColors.textSecondaryColor,
                      fontSize: MediaQuery.of(context).size.width * 0.032,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
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
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<SupportTicketProvider>().clearError();
                        context.read<SupportTicketProvider>().fetchTicketById(widget.ticketId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: AppColors.whiteColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Try Again',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
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
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.glassColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorderColor, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlueColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.support_agent_rounded,
                      color: AppColors.accentBlueColor,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Ticket Not Found',
                    style: AppTexts.emphasizedTextStyle(
                      context: context,
                      textColor: AppColors.textPrimaryColor,
                      fontSize: MediaQuery.of(context).size.width * 0.042,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The support ticket you\'re looking for doesn\'t exist or has been removed.',
                    textAlign: TextAlign.center,
                    style: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: AppColors.textSecondaryColor,
                      fontSize: MediaQuery.of(context).size.width * 0.032,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
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
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: AppColors.whiteColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_back_rounded,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Go Back',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
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
    );
  }
}