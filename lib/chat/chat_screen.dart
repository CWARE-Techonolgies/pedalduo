import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pedalduo/chat/widgets/chat_dialogues.dart';
import 'package:pedalduo/chat/widgets/show_message_action.dart';
import 'package:pedalduo/chat/widgets/swipe_to_reply_bubble.dart';
import 'package:pedalduo/providers/navigation_provider.dart';
import 'package:pedalduo/views/play/brackets/all_brackets_views.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../style/colors.dart';
import '../../style/texts.dart';
import '../global/apis.dart';
import '../global/images.dart';
import '../views/play/providers/tournament_provider.dart';
import 'chat_provider.dart';
import 'chat_room.dart';
import 'chat_room_provider.dart';
import 'message_model.dart';

class ChatScreen extends StatefulWidget {
  final ChatRoom chatRoom;
  final String? name;
  final int? id;

  final bool? isOrganizer;
  final int? tournamentId;
  final String? tournamentName;
  final String? tournamentStatus;
  final DateTime? tournamentEndDate;
  final DateTime? tournamentStartDate;

  const ChatScreen({
    super.key,
    required this.chatRoom,
    this.name,
    this.id,
    this.isOrganizer,
    this.tournamentId,
    this.tournamentName,
    this.tournamentStatus,
    this.tournamentEndDate,
    this.tournamentStartDate,
  });

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
  late int _currentChatRoomId;

  Timer? _chatRefreshTimer;

  @override
  void initState() {
    super.initState();
    _currentChatRoomId = widget.chatRoom.id;
    // Check if this is a tournament chat
    if (widget.chatRoom.type == 'tournament') {
      // Access tournament-specific data
      final isOrganizer = widget.isOrganizer ?? false;
      final tournamentId = widget.tournamentId;
      final tournamentName = widget.tournamentName;
      final tournamentStatus = widget.tournamentStatus;
      final tournamentEndDate = widget.tournamentEndDate;
      final tournamentStartDate = widget.tournamentStartDate;

      // Use this data as needed in your chat screen
      print(
        'Tournament Chat - Organizer: $isOrganizer, Status: $tournamentStatus , tournament ID: $tournamentId, tournament name: $tournamentName, start date : $tournamentStartDate, end date : $tournamentEndDate',
      );
    }
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });

    _scrollController.addListener(() {
      if (_scrollController.hasClients &&
          _scrollController.position.pixels <= 100) {
        _markLastMessageAsRead();
      }
    });
  }

  void _initializeChat() async {
    try {
      final provider = context.read<ChatProvider>();
      final roomProvider = context.read<ChatRoomsProvider>();

      await provider.initializeCurrentUser();
      await roomProvider.markMessagesAsRead(widget.chatRoom.id.toString());
      if (widget.chatRoom.id == 0) {
        debugPrint('🚫 Chat room ID is 0, ready for chat creation');
        return;
      }

      debugPrint('🚀 Initializing chat for room: ${widget.chatRoom.id}');

      await provider.fetchMessages(widget.chatRoom.id);

      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) _scrollToBottom(animate: false);
      });

      _markLastMessageAsRead();

      debugPrint('✅ Chat initialized successfully');

      // 👇 Start periodic silent refresh every 2 seconds
      _chatRefreshTimer?.cancel();
      _chatRefreshTimer = Timer.periodic(Duration(seconds: 2), (timer) {
        if (mounted) {
          provider.fetchMessages(widget.chatRoom.id, silent: true);
        }
      });
    } catch (e) {
      debugPrint('❌ Error initializing chat: $e');
    }
  }

  int _calculateMessageIndex(ChatProvider provider, int listIndex) {
    if (provider.messages.isEmpty) {
      return -1; // Invalid index for empty list
    }

    // If loading more indicator is shown, adjust for it
    if (provider.isLoadingMore && listIndex >= provider.messages.length) {
      return -1; // This is the loading indicator, not a message
    }

    // Calculate reverse index (because reverse: true)
    int messageIndex = provider.messages.length - 1 - listIndex;

    // Additional safety check
    if (messageIndex < 0 || messageIndex >= provider.messages.length) {
      return -1;
    }

    return messageIndex;
  }

  int _calculateItemCount(ChatProvider provider) {
    if (provider.isLoading) {
      return 10; // Show 10 skeleton items while loading
    }

    int count = provider.messages.length;
    if (provider.isLoadingMore && count > 0) {
      count += 1;
    }

    return count;
  }

  Widget _buildMessagesList(BuildContext context, ChatProvider provider) {
    final width = MediaQuery.of(context).size.width;
    if (_currentChatRoomId == 0) {
      return _buildEmptyMessagesPlaceholder(context);
    }

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
                  bottom: width * 0.04,
                ),
                itemCount: _calculateItemCount(provider),
                itemBuilder: (context, index) {
                  // Handle loading skeleton
                  if (provider.isLoading) {
                    return _buildSkeletonMessage(context, index % 2 == 0);
                  }

                  // Early return for empty messages
                  if (provider.messages.isEmpty) {
                    return SizedBox.shrink();
                  }

                  // Handle loading more indicator
                  if (provider.isLoadingMore &&
                      index >= provider.messages.length) {
                    return _buildLoadingMoreIndicator(context);
                  }

                  // Calculate message index safely
                  final messageIndex = _calculateMessageIndex(provider, index);

                  // Validate message index
                  if (messageIndex < 0 ||
                      messageIndex >= provider.messages.length) {
                    debugPrint(
                      'Invalid message index: $messageIndex, messages length: ${provider.messages.length}, list index: $index',
                    );
                    return SizedBox.shrink();
                  }

                  try {
                    final message = provider.messages[messageIndex];
                    final isCurrentUser = provider.isCurrentUser(
                      message.senderId,
                    );

                    // Check if we need to show date separator
                    final shouldShowDate = _shouldShowDateSeparator(
                      provider.messages,
                      messageIndex,
                    );

                    return Column(
                      children: [
                        // Date separator (show at top of new day)
                        if (shouldShowDate)
                          _buildDateSeparator(context, message.createdAt),

                        // Message bubble
                        _buildMessageBubble(context, message, isCurrentUser),
                      ],
                    );
                  } catch (e) {
                    debugPrint('Error building message bubble: $e');
                    return SizedBox.shrink();
                  }
                },
              ),
    );
  }

  // 4. Additional safety in _markLastMessageAsRead
  void _markLastMessageAsRead() {
    final provider = context.read<ChatProvider>();
    final roomId = provider.currentRoomId ?? _currentChatRoomId;

    // Skip if room ID is 0 and no current room ID from provider
    if (roomId == 0) {
      return;
    }

    // Additional safety checks
    if (provider.messages.isNotEmpty &&
        provider.currentUser != null &&
        provider.messages.length > 0) {
      try {
        final lastMessage = provider.messages.last;
        // Only mark as read if it's not from current user
        if (lastMessage.senderId != provider.currentUser!.id) {
          provider.markMessagesAsRead(roomId, lastMessage.id);
        }
      } catch (e) {
        debugPrint('Error marking message as read: $e');
      }
    }
  }

  // 5. Safe scroll to bottom
  void _scrollToBottom({bool animate = true}) {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        try {
          if (animate) {
            _scrollController.animateTo(
              0.0,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          } else {
            _scrollController.jumpTo(0.0);
          }
        } catch (e) {
          debugPrint('Error scrolling to bottom: $e');
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Store the provider reference safely
    _chatProvider = context.read<ChatProvider>();
  }

  void _updateChatRoomId(int newChatRoomId) {
    if (_currentChatRoomId != newChatRoomId) {
      setState(() {
        _currentChatRoomId = newChatRoomId;
      });
      debugPrint('🔄 Updated current chat room ID to: $_currentChatRoomId');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _chatRefreshTimer?.cancel();
    _scrollController.dispose();
    _focusNode.dispose();
    _typingTimer?.cancel();
    _chatProvider?.leaveRoom();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final provider = context.read<ChatProvider>();

    switch (state) {
      case AppLifecycleState.paused:
        // Use current chat room ID instead of widget.chatRoom.id
        final roomId = provider.currentRoomId ?? _currentChatRoomId;
        if (roomId != 0) {
          provider.stopTyping(roomId);
        }
        break;
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.detached:
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatRoomsProvider = context.watch<ChatRoomsProvider>();
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(context, chatRoomsProvider),
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
          _buildMessageInputWithReply(context, chatRoomsProvider),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ChatRoomsProvider provider,
  ) {
    final width = MediaQuery.of(context).size.width;
    final currentUserId = provider.currentUserId ?? 0;
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
          _buildAppBarAvatar(context, currentUserId),
          SizedBox(width: width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name ?? widget.chatRoom.getDisplayName(currentUserId),
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
      // actions: [
      //   Visibility(
      //     visible: !widget.chatRoom.isDirectMessage,
      //     child: PopupMenuButton<String>(
      //       icon: Icon(Icons.more_vert, color: AppColors.whiteColor),
      //       color: Colors.transparent,
      //       elevation: 0,
      //       offset: Offset(0, 50),
      //       itemBuilder:
      //           (BuildContext context) => [
      //             PopupMenuItem<String>(
      //               value: 'view_members',
      //               child: Container(
      //                 padding: EdgeInsets.symmetric(
      //                   horizontal: width * 0.04,
      //                   vertical: width * 0.02,
      //                 ),
      //                 decoration: BoxDecoration(
      //                   color: Colors.black.withOpacity(0.8),
      //                   borderRadius: BorderRadius.circular(width * 0.03),
      //                   border: Border.all(
      //                     color: Colors.white.withOpacity(0.2),
      //                     width: 1,
      //                   ),
      //                 ),
      //                 child: Row(
      //                   mainAxisSize: MainAxisSize.min,
      //                   children: [
      //                     Icon(
      //                       Icons.group,
      //                       color: AppColors.whiteColor,
      //                       size: width * 0.04,
      //                     ),
      //                     SizedBox(width: width * 0.02),
      //                     Text(
      //                       'View All Members',
      //                       style: AppTexts.bodyTextStyle(
      //                         context: context,
      //                         textColor: AppColors.whiteColor,
      //                         fontSize: width * 0.035,
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //             ),
      //           ],
      //       onSelected: (String value) {
      //         if (value == 'view_members') {
      //           _showMembersDialog(context);
      //         }
      //       },
      //     ),
      //   ),
      // ],
    );
  }

  void _showMembersDialog(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: width * 0.85,
            constraints: BoxConstraints(maxHeight: width * 1.2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(width * 0.05),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(width * 0.05),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.group,
                        color: AppColors.lightOrangeColor,
                        size: width * 0.06,
                      ),
                      SizedBox(width: width * 0.03),
                      Expanded(
                        child: Text(
                          'Members (${widget.chatRoom.participants.length})',
                          style: AppTexts.emphasizedTextStyle(
                            context: context,
                            textColor: AppColors.whiteColor,
                            fontSize: width * 0.045,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close,
                          color: AppColors.whiteColor.withOpacity(0.7),
                          size: width * 0.05,
                        ),
                      ),
                    ],
                  ),
                ),

                // Members List
                Flexible(
                  child: Consumer<ChatRoomsProvider>(
                    builder: (context, chatRoomsProvider, child) {
                      final currentUserId =
                          chatRoomsProvider.currentUserId ?? 0;

                      debugPrint('=== MEMBERS DEBUG ===');
                      debugPrint('Current User ID: $currentUserId');
                      debugPrint(
                        'Chat Room Creator ID: ${widget.chatRoom.createdBy}',
                      );
                      debugPrint(
                        'Participants count: ${widget.chatRoom.participants.length}',
                      );
                      debugPrint(
                        'Participant count field: ${widget.chatRoom.participantCount}',
                      );

                      for (
                        int i = 0;
                        i < widget.chatRoom.participants.length;
                        i++
                      ) {
                        final p = widget.chatRoom.participants[i];
                        debugPrint(
                          'Participant $i: ${p.user.name} (ID: ${p.userId}) - Role: ${p.role}',
                        );
                      }
                      debugPrint('===================');

                      if (widget.chatRoom.participants.isEmpty) {
                        return Container(
                          padding: EdgeInsets.all(width * 0.1),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.group_off,
                                  color: AppColors.greyColor,
                                  size: width * 0.1,
                                ),
                                SizedBox(height: width * 0.04),
                                Text(
                                  'No participants found',
                                  style: AppTexts.bodyTextStyle(
                                    context: context,
                                    textColor: AppColors.greyColor,
                                    fontSize: width * 0.035,
                                  ),
                                ),
                                Text(
                                  'Participant count: ${widget.chatRoom.participantCount}',
                                  style: AppTexts.bodyTextStyle(
                                    context: context,
                                    textColor: AppColors.greyColor.withOpacity(
                                      0.7,
                                    ),
                                    fontSize: width * 0.03,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(vertical: width * 0.02),
                        itemCount: widget.chatRoom.participants.length,
                        itemBuilder: (context, index) {
                          final participant =
                              widget.chatRoom.participants[index];
                          final isCurrentUser =
                              currentUserId == participant.userId;
                          final isCreator =
                              widget.chatRoom.createdBy == participant.userId;

                          return Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: width * 0.04,
                              vertical: width * 0.01,
                            ),
                            padding: EdgeInsets.all(width * 0.04),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(width * 0.03),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Avatar
                                Container(
                                  width: width * 0.1,
                                  height: width * 0.1,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.blueColor,
                                        AppColors.purpleColor,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      width * 0.05,
                                    ),
                                  ),
                                  child:
                                      participant.user.avatarUrl != null &&
                                              participant
                                                  .user
                                                  .avatarUrl!
                                                  .isNotEmpty
                                          ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              width * 0.05,
                                            ),
                                            child: Image.network(
                                              participant.user.avatarUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return Center(
                                                  child: Text(
                                                    participant.user.initials,
                                                    style:
                                                        AppTexts.emphasizedTextStyle(
                                                          context: context,
                                                          textColor:
                                                              AppColors
                                                                  .whiteColor,
                                                          fontSize:
                                                              width * 0.03,
                                                        ),
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                          : Center(
                                            child: Text(
                                              participant.user.initials,
                                              style:
                                                  AppTexts.emphasizedTextStyle(
                                                    context: context,
                                                    textColor:
                                                        AppColors.whiteColor,
                                                    fontSize: width * 0.03,
                                                  ),
                                            ),
                                          ),
                                ),

                                SizedBox(width: width * 0.04),

                                // User Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              participant.user.name.isNotEmpty
                                                  ? participant.user.name
                                                  : 'Unknown User',
                                              style: AppTexts.bodyTextStyle(
                                                context: context,
                                                textColor: AppColors.whiteColor,
                                                fontSize: width * 0.038,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          // Show tags
                                          if (isCurrentUser)
                                            Container(
                                              margin: EdgeInsets.only(
                                                left: width * 0.02,
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: width * 0.02,
                                                vertical: width * 0.005,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors
                                                    .lightOrangeColor
                                                    .withOpacity(0.8),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      width * 0.02,
                                                    ),
                                              ),
                                              child: Text(
                                                'You',
                                                style: AppTexts.bodyTextStyle(
                                                  context: context,
                                                  textColor:
                                                      AppColors.whiteColor,
                                                  fontSize: width * 0.025,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          if (isCreator)
                                            Container(
                                              margin: EdgeInsets.only(
                                                left: width * 0.02,
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: width * 0.02,
                                                vertical: width * 0.005,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.lightGreenColor
                                                    .withOpacity(0.8),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      width * 0.02,
                                                    ),
                                              ),
                                              child: Text(
                                                'Organizer',
                                                style: AppTexts.bodyTextStyle(
                                                  context: context,
                                                  textColor:
                                                      AppColors.whiteColor,
                                                  fontSize: width * 0.025,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: width * 0.005),
                                      if (participant.user.email.isNotEmpty)
                                        Text(
                                          participant.user.email,
                                          style: AppTexts.bodyTextStyle(
                                            context: context,
                                            textColor: AppColors.greyColor,
                                            fontSize: width * 0.032,
                                          ),
                                        ),
                                      // Show role only if it's not 'member' and not creator
                                      if (participant.role != 'member' &&
                                          !isCreator)
                                        Text(
                                          participant.role.toUpperCase(),
                                          style: AppTexts.bodyTextStyle(
                                            context: context,
                                            textColor:
                                                AppColors.lightGreenColor,
                                            fontSize: width * 0.028,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // Online/Offline indicator
                                Container(
                                  width: width * 0.025,
                                  height: width * 0.025,
                                  decoration: BoxDecoration(
                                    color:
                                        participant.isActive
                                            ? AppColors.lightGreenColor
                                            : AppColors.greyColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Add this helper method to format date separators
  String _formatDateSeparator(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final difference = today.difference(messageDate).inDays;

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (difference < 7) {
      // Show day name for this week
      return DateFormat('EEEE').format(dateTime); // Monday, Tuesday, etc.
    } else if (difference < 365) {
      // Show date for this year
      return DateFormat('MMM dd').format(dateTime); // Jan 15, Feb 22, etc.
    } else {
      // Show full date for older messages
      return DateFormat('MMM dd, yyyy').format(dateTime); // Jan 15, 2023
    }
  }

  // Check if we need to show date separator
  // Check if we need to show date separator
  bool _shouldShowDateSeparator(List<Message> messages, int index) {
    // Always show for the first message (oldest in reversed list)
    if (index == 0) return true;

    final currentMessage = messages[index];
    final previousMessage = messages[index - 1];

    final currentDate = DateTime(
      currentMessage.createdAt.year,
      currentMessage.createdAt.month,
      currentMessage.createdAt.day,
    );

    final previousDate = DateTime(
      previousMessage.createdAt.year,
      previousMessage.createdAt.month,
      previousMessage.createdAt.day,
    );

    // Show separator when the date changes from previous message
    return !currentDate.isAtSameMomentAs(previousDate);
  }

  // Build date separator widget
  Widget _buildDateSeparator(BuildContext context, DateTime dateTime) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.symmetric(vertical: width * 0.04),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.white.withOpacity(0.2)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: width * 0.04),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(width * 0.05),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.04,
                    vertical: width * 0.025,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(width * 0.05),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: Offset(0, 2),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 2,
                        spreadRadius: 0,
                        offset: Offset(0, -1),
                      ),
                    ],
                  ),
                  child: Text(
                    _formatDateSeparator(dateTime),
                    style: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: Colors.white.withOpacity(0.9),
                      fontSize: width * 0.032,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.2), Colors.transparent],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarAvatar(BuildContext context, int currentUserId) {
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
                  widget.name?[0] ?? widget.chatRoom.getInitials(currentUserId),
                  style: AppTexts.emphasizedTextStyle(
                    context: context,
                    textColor: AppColors.whiteColor,
                    fontSize: width * 0.03,
                  ),
                ),
              ),
    );
  }

  String _getInitialsFromUser(User user) {
    try {
      if (user.name.trim().isEmpty) return '';

      final nameParts = user.name.trim().split(' ');
      if (nameParts.isEmpty) return '';

      if (nameParts.length == 1) {
        return nameParts[0].isNotEmpty ? nameParts[0][0].toUpperCase() : '';
      } else {
        final firstInitial = nameParts[0].isNotEmpty ? nameParts[0][0] : '';
        final lastInitial =
            nameParts[nameParts.length - 1].isNotEmpty
                ? nameParts[nameParts.length - 1][0]
                : '';
        return (firstInitial + lastInitial).toUpperCase();
      }
    } catch (e) {
      debugPrint(
        'Error extracting initials from user name: ${user.name}, error: $e',
      );
      return '';
    }
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
                color: AppColors.darkGreyColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(width * 0.04),
              ),
            ),
            SizedBox(width: width * 0.02),
          ],
          Container(
            constraints: BoxConstraints(maxWidth: width * 0.7),
            padding: EdgeInsets.all(width * 0.04),
            decoration: BoxDecoration(
              color: AppColors.darkGreyColor,
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
    final provider = context.read<ChatProvider>();

    // Check if this is a system message for tournament
    if (message.sender.id == 0 && widget.chatRoom.isTournamentChat) {
      return _buildTournamentSystemMessage(context, message);
    }

    // Your existing message bubble code for regular messages
    return SwipeToReplyWrapper(
      isCurrentUser: isCurrentUser,
      onReply: () {
        setState(() {
          _replyToMessage = message;
        });
        _focusNode.requestFocus();
      },
      child: GestureDetector(
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: AppColors.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(MediaQuery.of(context).size.width * 0.05),
              ),
            ),
            builder: (context) => ShowMessageAction(message: message),
          ).then((result) {
            if (result != null) {
              if (result["action"] == "reply") {
                setState(() {
                  _replyToMessage = result["message"];
                });
                _focusNode.requestFocus();
              } else if (result["action"] == "edit") {
                _showEditMessageDialog(context, result["message"]);
              } else if (result["action"] == "delete") {
                ChatDialogues().showDeleteConfirmation(context, result["message"]);
              }
            }
          });
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
                      if (!isCurrentUser &&
                          !widget.chatRoom.isDirectMessage) ...[
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
                      if (message.isReply &&
                          message.repliedMessage != null) ...[
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
      ),
    );
  }

  Widget _buildTournamentSystemMessage(BuildContext context, Message message) {
    final width = MediaQuery.of(context).size.width;
    final bool isApproved = message.content.toLowerCase().contains('approved');

    return Container(
      margin: EdgeInsets.only(bottom: width * 0.03),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(width * 0.04),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              constraints: BoxConstraints(maxWidth: width * 0.85),
              padding: EdgeInsets.all(width * 0.04),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.darkSecondaryColor.withOpacity(0.8),
                    AppColors.darkTertiaryColor.withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(width * 0.04),
                border: Border.all(color: AppColors.glassBorderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blackColor.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with avatar and name
                  Row(
                    children: [
                      Container(
                        width: width * 0.08,
                        height: width * 0.08,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryColor,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            AppImages.logoImage2,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: width * 0.03),
                      Text(
                        'Padel Duo',
                        style: AppTexts.bodyTextStyle(
                          context: context,
                          textColor: AppColors.primaryColor,
                          fontSize: width * 0.032,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.campaign_rounded,
                        color: AppColors.primaryColor,
                        size: width * 0.05,
                      ),
                    ],
                  ),
                  SizedBox(height: width * 0.03),

                  // Message content
                  Container(
                    padding: EdgeInsets.all(width * 0.03),
                    decoration: BoxDecoration(
                      color: AppColors.glassColor,
                      borderRadius: BorderRadius.circular(width * 0.03),
                      border: Border.all(
                        color: AppColors.glassBorderColor.withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      message.content,
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.textPrimaryColor,
                        fontSize: width * 0.035,
                        // height: 1.4,
                      ),
                    ),
                  ),

                  SizedBox(height: width * 0.04),

                  // Action button
                  Container(
                    width: double.infinity,
                    child: Consumer<NavigationProvider>(
                      builder: (
                        BuildContext context,
                        NavigationProvider navProvider,
                        Widget? child,
                      ) {
                        return ElevatedButton(
                          onPressed: ()async {
                            if (isApproved) {
                              // Navigate to register team
                              navProvider.goToTab(context, 1);
                            } else {
                              // First check if we have the required tournament data
                              if (widget.tournamentId != null &&
                                  widget.tournamentName != null &&
                                  widget.tournamentStatus != null &&
                                  widget.tournamentStartDate != null &&
                                  widget.tournamentEndDate != null) {

                                // Safe navigation with confirmed non-null values
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (_) => AllBracketsViews(
                                      isOrganizer: widget.isOrganizer ?? false,
                                      tournamentId: widget.tournamentId.toString(),
                                      tournamentName: widget.tournamentName!,
                                      tournamentStatus: widget.tournamentStatus!,
                                      tournamentStartDate: widget.tournamentStartDate!,
                                      tournamentEndDate: widget.tournamentEndDate!,
                                    ),
                                  ),
                                );
                              } else {
                                // If tournament data is missing, fetch it first
                                await _fetchAndNavigateToBrackets();
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: AppColors.whiteColor,
                            elevation: 8,
                            shadowColor: AppColors.primaryColor.withOpacity(
                              0.5,
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: width * 0.035,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(width * 0.03),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isApproved
                                    ? Icons.group_add_rounded
                                    : Icons.track_changes_rounded,
                                size: width * 0.045,
                              ),
                              SizedBox(width: width * 0.02),
                              Text(
                                isApproved
                                    ? 'Register Team'
                                    : 'Track Tournament',
                                style: AppTexts.bodyTextStyle(
                                  context: context,
                                  textColor: AppColors.whiteColor,
                                  fontSize: width * 0.035,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: width * 0.02),

                  // Timestamp
                  Center(
                    child: Text(
                      _formatMessageTime(message.createdAt),
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.textTertiaryColor,
                        fontSize: width * 0.025,
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

  Widget _buildMessageInputWithReply(
    BuildContext context,
    ChatRoomsProvider provider,
  ) {
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
          _buildMessageInput(context, provider),
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
  Future<void> _fetchAndNavigateToBrackets() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.navyBlueGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.orangeColor),
                SizedBox(height: 16),
                Text(
                  'Loading tournament data...',
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.whiteColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final tournamentProvider = context.read<TournamentProvider>();

      // Ensure tournament data is loaded
      await Future.wait([
        tournamentProvider.fetchAllTournaments(forceRefresh: true),
        tournamentProvider.fetchMyTournaments(forceRefresh: true),
      ]);

      // Get tournament data
      final tournamentData = await _getTournamentDataFromProvider();

      // Close loading dialog
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Navigate with fetched data
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => AllBracketsViews(
            isOrganizer: tournamentData['isOrganizer'] ?? false,
            tournamentId: (tournamentData['tournamentId'] ?? widget.chatRoom.id).toString(),
            tournamentName: tournamentData['tournamentName'] ?? widget.chatRoom.name,
            tournamentStatus: tournamentData['tournamentStatus'] ?? 'unknown',
            tournamentStartDate: tournamentData['tournamentStartDate'] ?? DateTime.now(),
            tournamentEndDate: tournamentData['tournamentEndDate'] ?? DateTime.now().add(Duration(days: 7)),
          ),
        ),
      );
    } catch (e) {
      print('Error fetching tournament data: $e');

      // Close loading dialog if open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load tournament data: ${e.toString()}'),
          backgroundColor: AppColors.redColor,
        ),
      );
    }
  }
  Future<Map<String, dynamic>> _getTournamentDataFromProvider() async {
    try {
      final tournamentProvider = context.read<TournamentProvider>();
      final currentUserId = context.read<ChatRoomsProvider>().currentUserId;

      Map<String, dynamic> result = {
        'isOrganizer': widget.chatRoom.createdBy == currentUserId,
        'tournamentId': widget.chatRoom.tournamentId,
        'tournamentName': widget.chatRoom.name,
        'tournamentStatus': 'unknown',
        'tournamentStartDate': null,
        'tournamentEndDate': null,
      };

      if (widget.chatRoom.tournamentId == null) {
        return result;
      }

      // Try organized tournaments first
      final organizedTournament = tournamentProvider.organizedTournaments
          .where((t) => t.id == widget.chatRoom.tournamentId)
          .firstOrNull;

      if (organizedTournament != null) {
        result.addAll({
          'tournamentName': organizedTournament.title,
          'tournamentStatus': organizedTournament.status,
          'tournamentStartDate': organizedTournament.tournamentStartDate,
          'tournamentEndDate': organizedTournament.tournamentEndDate,
        });
        return result;
      }

      // Try all tournaments
      final allTournament = tournamentProvider.allTournaments
          .where((t) => t.id == widget.chatRoom.tournamentId)
          .firstOrNull;

      if (allTournament != null) {
        result.addAll({
          'tournamentName': allTournament.title,
          'tournamentStatus': allTournament.status,
          'tournamentStartDate': allTournament.tournamentStartDate,
          'tournamentEndDate': allTournament.tournamentEndDate,
        });
        return result;
      }

      // If still not found, make direct API call
      result = await _fetchTournamentFromAPI(widget.chatRoom.tournamentId!, result);

      return result;
    } catch (e) {
      print('Error in _getTournamentDataFromProvider: $e');
      throw e;
    }
  }
  Future<Map<String, dynamic>> _fetchTournamentFromAPI(
      int tournamentId,
      Map<String, dynamic> defaultData
      ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('${AppApis.baseUrl}tournaments/$tournamentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          final tournament = responseData['data'];

          return {
            ...defaultData,
            'tournamentName': tournament['title'] ?? defaultData['tournamentName'],
            'tournamentStatus': tournament['status'] ?? defaultData['tournamentStatus'],
            'tournamentStartDate': tournament['tournament_start_date'] != null
                ? DateTime.parse(tournament['tournament_start_date'])
                : defaultData['tournamentStartDate'],
            'tournamentEndDate': tournament['tournament_end_date'] != null
                ? DateTime.parse(tournament['tournament_end_date'])
                : defaultData['tournamentEndDate'],
          };
        }
      }

      return defaultData;
    } catch (e) {
      print('Error fetching tournament from API: $e');
      return defaultData;
    }
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
          user.avatarUrl != null && user.avatarUrl!.isNotEmpty
              ? ClipRRect(
                borderRadius: BorderRadius.circular(width * 0.04),
                child: Image.network(
                  user.avatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        _getSafeInitialsForUser(user),
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
                  _getSafeInitialsForUser(user),
                  style: AppTexts.emphasizedTextStyle(
                    context: context,
                    textColor: AppColors.whiteColor,
                    fontSize: width * 0.025,
                  ),
                ),
              ),
    );
  }

  String _getSafeInitialsForUser(User user) {
    return _getInitialsFromUser(user).isNotEmpty
        ? _getInitialsFromUser(user)
        : '?';
  }

  Widget _buildMessageInput(BuildContext context, ChatRoomsProvider provider) {
    final width = MediaQuery.of(context).size.width;
    final currentUserId = provider.currentUserId ?? 0;
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
                  constraints: BoxConstraints(maxHeight: width * 0.3),
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
                      // Use current chat room ID for typing indicator
                      final roomId =
                          context.read<ChatProvider>().currentRoomId ??
                          _currentChatRoomId;
                      if (roomId != 0) {
                        context.read<ChatProvider>().onTypingChanged(
                          value,
                          roomId,
                        );
                      }
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
                                    _isSending)
                                ? null
                                : () async {
                                  // Prevent multiple taps
                                  if (_isSending) return;

                                  setState(() {
                                    _isSending = true;
                                  });

                                  final message =
                                      _messageController.text.trim();
                                  final replyToId = _replyToMessage?.id;

                                  debugPrint('🚀 Sending message: "$message"');

                                  // Clear input immediately for better UX
                                  _messageController.clear();
                                  setState(() {
                                    _replyToMessage = null;
                                  });

                                  try {
                                    final provider =
                                        context.read<ChatProvider>();

                                    int? otherUserId;

                                    if (_currentChatRoomId == 0) {
                                      if (widget
                                          .chatRoom
                                          .participants
                                          .isNotEmpty) {
                                        otherUserId =
                                            widget.chatRoom
                                                .getOtherUser(currentUserId)
                                                ?.id ??
                                            widget.id;
                                      }

                                      if (otherUserId == null) {
                                        throw Exception(
                                          'Cannot determine other user ID',
                                        );
                                      }

                                      debugPrint(
                                        '🆕 Creating new chat with user: $otherUserId',
                                      );
                                    }

                                    // Send message - the provider will handle chat creation if needed
                                    await provider.sendMessage(
                                      _currentChatRoomId, // Use current chat room ID
                                      message,
                                      replyToMessageId: replyToId,
                                      otherUserId: otherUserId,
                                    );

                                    // Update the chat room ID after successful message send
                                    if (provider.currentRoomId != null &&
                                        provider.currentRoomId !=
                                            _currentChatRoomId) {
                                      _updateChatRoomId(
                                        provider.currentRoomId!,
                                      );

                                      // Fetch messages for the new chat room to ensure UI is updated
                                      await provider.fetchMessages(
                                        provider.currentRoomId!,
                                      );

                                      // Auto-scroll to bottom
                                      Future.delayed(
                                        Duration(milliseconds: 300),
                                        () {
                                          if (mounted)
                                            _scrollToBottom(animate: true);
                                        },
                                      );
                                    }

                                    // Use the current room ID from provider for typing indicator
                                    final roomId =
                                        provider.currentRoomId ??
                                        _currentChatRoomId;
                                    if (roomId != 0) {
                                      provider.stopTyping(roomId);
                                    }

                                    // Hide keyboard
                                    _focusNode.unfocus();

                                    debugPrint('✅ Message sent successfully');
                                  } catch (e) {
                                    debugPrint('❌ Failed to send message: $e');

                                    // Show error and restore message to input
                                    if (mounted) {
                                      _messageController.text = message;
                                      setState(() {
                                        _replyToMessage =
                                            replyToId != null
                                                ? context
                                                    .read<ChatProvider>()
                                                    .messages
                                                    .firstWhere(
                                                      (msg) =>
                                                          msg.id == replyToId,
                                                      orElse:
                                                          () =>
                                                              _replyToMessage!,
                                                    )
                                                : null;
                                      });

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to send message: ${e.toString()}',
                                          ),
                                          backgroundColor: AppColors.redColor,
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _isSending = false;
                                      });
                                    }
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
                width: width * 0.06,
                height: width * 0.02,
                child: SpinKitThreeBounce(
                  color: AppColors.greenColor,
                  size: width * 0.015,
                ),
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


  // Add delete confirmation
}
