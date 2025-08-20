import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../style/colors.dart';
import '../../style/texts.dart';
import '../services/socket_services.dart';
import '../views/all_players.dart';
import '../views/play/providers/tournament_provider.dart';
import 'chat_room.dart';
import 'chat_room_provider.dart';
import 'chat_screen.dart';

class ChatRoomsScreen extends StatefulWidget {
  final bool refresh;
  const ChatRoomsScreen({super.key, required this.refresh});

  @override
  _ChatRoomsScreenState createState() => _ChatRoomsScreenState();
}

class _ChatRoomsScreenState extends State<ChatRoomsScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatRoomsProvider>().initializeCurrentUser();
      context.read<ChatRoomsProvider>().fetchChatRooms();
      _setupSocketListeners();
      context.read<ChatRoomsProvider>().silentRefresh();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<ChatRoomsProvider>().silentRefresh();
    }
  }

  void _setupSocketListeners() async {
    if (!SocketService.instance.isConnected) {
      await SocketService.instance.connect();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    SocketService.instance.onRoomUpdated((updatedRoom) {
      if (mounted) {
        // Use addPostFrameCallback to avoid calling during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.read<ChatRoomsProvider>().refresh();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final provider = context.read<ChatRoomsProvider>();
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColors.orangeColor),
        backgroundColor: AppColors.navyBlueGrey,
        elevation: 0,
        title: Text(
          'Messages',
          style: AppTexts.emphasizedTextStyle(
            context: context,
            textColor: AppColors.orangeColor,
            fontSize: width * 0.05,
          ),
        ),
        actions: [
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, child) {
              if (_tabController.index == 0) {
                return IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (_) => AllPlayers()),
                  ),
                  icon: Container(
                    decoration: BoxDecoration(color: AppColors.orangeColor),
                    child: Icon(
                      CupertinoIcons.add,
                      color: AppColors.whiteColor,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.darkOrangeColor,
          indicatorWeight: 3,
          labelStyle: AppTexts.emphasizedTextStyle(
            context: context,
            textColor: AppColors.orangeColor,
          ),
          unselectedLabelStyle: AppTexts.bodyTextStyle(
            context: context,
            textColor: AppColors.greyColor,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Chats'),
                  if (provider.unreadDirectMessagesCount > 0) ...[
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.orangeColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${provider.unreadDirectMessagesCount}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Tournament Chats'),
                  if (provider.unreadTournamentChatsCount > 0) ...[
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.orangeColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${provider.unreadTournamentChatsCount}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: Consumer<ChatRoomsProvider>(
        builder: (context, provider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildChatList(provider.directMessages, provider, 'direct'),
              _buildChatList(provider.tournamentChats, provider, 'tournament'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChatList(
      List<ChatRoom> chatRooms,
      ChatRoomsProvider provider,
      String type,
      ) {
    final width = MediaQuery.of(context).size.width;

    // Show error state if there's an error
    if (provider.error != null) {
      return _buildErrorState(provider.friendlyError ?? provider.error!, provider);
    }

    if (!provider.isLoading && chatRooms.isEmpty) {
      return _buildEmptyState(type);
    }

    return Skeletonizer(
      enabled: provider.isLoading,
      child: RefreshIndicator(
        onRefresh: () async => provider.refresh(),
        color: AppColors.lightGreenColor,
        child: ListView.builder(
          padding: EdgeInsets.all(width * 0.04),
          itemCount: provider.isLoading ? 8 : chatRooms.length,
          itemBuilder: (context, index) {
            if (provider.isLoading) {
              return _buildSkeletonItem();
            }
            return _buildChatRoomItem(chatRooms[index], provider);
          },
        ),
      ),
    );
  }

  Widget _buildSkeletonItem() {
    final width = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(bottom: width * 0.03),
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: AppColors.darkGreyColor,
        borderRadius: BorderRadius.circular(width * 0.04),
      ),
      child: Row(
        children: [
          Container(
            width: width * 0.12,
            height: width * 0.12,
            decoration: BoxDecoration(
              color: AppColors.navyBlueGrey,
              borderRadius: BorderRadius.circular(width * 0.06),
            ),
          ),
          SizedBox(width: width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: width * 0.4,
                  height: width * 0.04,
                  decoration: BoxDecoration(
                    color: AppColors.navyBlueGrey,
                    borderRadius: BorderRadius.circular(width * 0.02),
                  ),
                ),
                SizedBox(height: width * 0.02),
                Container(
                  width: width * 0.6,
                  height: width * 0.03,
                  decoration: BoxDecoration(
                    color: AppColors.navyBlueGrey,
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

  Widget _buildChatRoomItem(ChatRoom chatRoom, ChatRoomsProvider provider) {
    final width = MediaQuery.of(context).size.width;
    final currentUserId = provider.currentUserId ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: width * 0.03),
      decoration: BoxDecoration(
        color: AppColors.navyBlueGrey,
        borderRadius: BorderRadius.circular(width * 0.04),
        boxShadow: [
          BoxShadow(
            color: AppColors.whiteColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(width * 0.04),
          onTap: () async {
            await provider.markMessagesAsRead(chatRoom.id.toString());

            if (chatRoom.type == 'tournament') {
              // For tournament chats, pass additional tournament data
              await Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => ChatScreen(
                    chatRoom: chatRoom,
                    name: chatRoom.getDisplayName(currentUserId),
                    // Tournament-specific data
                    isOrganizer: _isCurrentUserOrganizer(chatRoom, currentUserId),
                    tournamentId: chatRoom.tournamentId,
                    tournamentName: chatRoom.name,
                    tournamentStatus: _getTournamentStatus(chatRoom),
                    tournamentEndDate: _getTournamentEndDate(chatRoom),
                    tournamentStartDate: _getTournamentStartDate(chatRoom),
                  ),
                ),
              );
            } else {
              // For direct messages, use the simple navigation
              await Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => ChatScreen(
                    chatRoom: chatRoom,
                    name: chatRoom.getDisplayName(currentUserId),
                  ),
                ),
              );
            }

            if (mounted) {
              provider.silentRefresh();
            }
          },
          child: Padding(
            padding: EdgeInsets.all(width * 0.04),
            child: Row(
              children: [
                _buildAvatar(
                  chatRoom,
                  width,
                  currentUserId,
                ), // Pass current user ID
                SizedBox(width: width * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chatRoom.getDisplayName(
                          currentUserId,
                        ), // Use new method
                        style: AppTexts.emphasizedTextStyle(
                          context: context,
                          textColor: AppColors.whiteColor,
                          fontSize: width * 0.04,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: width * 0.01),
                      Builder(
                        builder: (context) {
                          final messageData = provider.getLastMessageWithSender(chatRoom, currentUserId);
                          final hasRealMessage = chatRoom.lastMessage?.content != null;

                          if (!hasRealMessage) {
                            return Text(
                              messageData['message']!,
                              style: AppTexts.bodyTextStyle(
                                context: context,
                                textColor: AppColors.greenColor,
                                fontWeight: FontWeight.w600,
                                fontSize: width * 0.032,
                              ),
                            );
                          }

                          if (messageData['sender']!.isEmpty) {
                            // No sender name (direct message from other person)
                            return Text(
                              _truncateMessage(messageData['message']!),
                              style: AppTexts.bodyTextStyle(
                                context: context,
                                textColor: AppColors.greyColor,
                                fontSize: width * 0.032,
                              ),
                            );
                          }

                          // Has sender name
                          return RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${messageData['sender']!}: ',
                                  style: AppTexts.bodyTextStyle(
                                    context: context,
                                    textColor: AppColors.greenColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: width * 0.032,
                                  ),
                                ),
                                TextSpan(
                                  text: _truncateMessage(messageData['message']!),
                                  style: AppTexts.bodyTextStyle(
                                    context: context,
                                    textColor: AppColors.greyColor,
                                    fontSize: width * 0.032,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatTime(chatRoom.lastActivity),
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.blueColor,
                        fontWeight: FontWeight.w600,
                        fontSize: width * 0.028,
                      ),
                    ),
                    if (chatRoom.unreadCount != null &&
                        chatRoom.unreadCount! > 0) ...[
                      SizedBox(height: width * 0.015),
                      Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          color: AppColors.orangeColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            chatRoom.unreadCount.toString(),
                            style: AppTexts.bodyTextStyle(
                              context: context,
                              textColor: AppColors.whiteColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ChatRoom chatRoom, double width, int currentUserId) {
    final avatarSize = width * 0.12;
    final borderRadius = width * 0.06;
    final iconSize = width * 0.06;

    if (chatRoom.type == 'tournament') {
      return Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.blueColor, AppColors.purpleColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Icon(
          Icons.emoji_events,
          color: AppColors.whiteColor,
          size: iconSize,
        ),
      );
    }

    // Direct message avatar - show the OTHER user's avatar
    final otherUser = chatRoom.getOtherUser(currentUserId);
    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.blueColor, AppColors.purpleColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: otherUser?.avatarUrl != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.network(
          otherUser!.avatarUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: Text(
              chatRoom.getInitials(currentUserId),
              style: AppTexts.emphasizedTextStyle(
                context: context,
                textColor: AppColors.whiteColor,
                fontSize: width * 0.04,
              ),
            ),
          ),
        ),
      )
          : Center(
        child: Text(
          chatRoom.getInitials(currentUserId),
          style: AppTexts.emphasizedTextStyle(
            context: context,
            textColor: AppColors.whiteColor,
            fontSize: width * 0.04,
          ),
        ),
      ),
    );
  }

  // Updated error state with provider parameter and better retry functionality
  Widget _buildErrorState(String error, ChatRoomsProvider provider) {
    final width = MediaQuery.of(context).size.width;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(width * 0.06),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: width * 0.15,
              color: AppColors.redColor,
            ),
            SizedBox(height: width * 0.04),
            Text(
              error,
              style: AppTexts.emphasizedTextStyle(
                context: context,
                textColor: AppColors.whiteColor,
                fontSize: width * 0.04,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: width * 0.06),
            SizedBox(
              width: width * 0.4,
              height: 48,
              child: ElevatedButton(
                onPressed: provider.isLoading
                    ? null
                    : () {
                  // Force refresh by resetting state
                  provider.refresh();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightGreenColor,
                  disabledBackgroundColor: AppColors.greyColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(width * 0.03),
                  ),
                ),
                child: provider.isLoading
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.whiteColor,
                    ),
                  ),
                )
                    : Text(
                  'Try Again',
                  style: AppTexts.emphasizedTextStyle(
                    context: context,
                    textColor: AppColors.whiteColor,
                    fontSize: width * 0.04,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    final width = MediaQuery.of(context).size.width;
    final config = _getEmptyStateConfig(type);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            config['icon'],
            size: width * 0.2,
            color: AppColors.greyColor.withOpacity(0.5),
          ),
          SizedBox(height: width * 0.04),
          Text(
            config['title'],
            style: AppTexts.emphasizedTextStyle(
              context: context,
              textColor: AppColors.greyColor,
              fontSize: width * 0.045,
            ),
          ),
          SizedBox(height: width * 0.02),
          Text(
            config['subtitle'],
            style: AppTexts.bodyTextStyle(
              context: context,
              textColor: AppColors.greyColor.withOpacity(0.7),
              fontSize: width * 0.035,
            ),
            textAlign: TextAlign.center,
          ),
          if (type == 'direct') ...[
            SizedBox(height: width * 0.06),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => AllPlayers()),
              ),
              icon: Icon(Icons.add, color: AppColors.whiteColor),
              label: Text(
                'Start New Chat',
                style: AppTexts.emphasizedTextStyle(
                  context: context,
                  textColor: AppColors.whiteColor,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orangeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(width * 0.03),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Map<String, dynamic> _getEmptyStateConfig(String type) {
    switch (type) {
      case 'direct':
        return {
          'title': 'No Direct Messages',
          'subtitle': 'Start a conversation with someone',
          'icon': Icons.chat_bubble_outline,
        };
      case 'tournament':
        return {
          'title': 'No Tournament Chats',
          'subtitle': 'Join a tournament to participate in discussions',
          'icon': Icons.emoji_events_outlined,
        };
      default:
        return {
          'title': 'No Messages',
          'subtitle': 'Start a new conversation',
          'icon': Icons.chat_outlined,
        };
    }
  }
  bool _isCurrentUserOrganizer(ChatRoom chatRoom, int currentUserId) {
    // Check if current user is the organizer
    return chatRoom.createdBy == currentUserId;
  }

  String _getTournamentStatus(ChatRoom chatRoom) {
    // You might need to add tournament status to your ChatRoom model
    // or fetch it from your tournament provider
    final tournamentProvider = context.read<TournamentProvider>();

    // Try to find tournament in organized tournaments
    final organizedTournament = tournamentProvider.organizedTournaments
        .where((t) => t.id == chatRoom.tournamentId)
        .firstOrNull;

    if (organizedTournament != null) {
      return organizedTournament.status;
    }

    // Try to find in all tournaments
    final allTournament = tournamentProvider.allTournaments
        .where((t) => t.id == chatRoom.tournamentId)
        .firstOrNull;

    return allTournament?.status ?? 'unknown';
  }

  DateTime? _getTournamentEndDate(ChatRoom chatRoom) {
    final tournamentProvider = context.read<TournamentProvider>();

    // Try to find tournament in organized tournaments
    final organizedTournament = tournamentProvider.organizedTournaments
        .where((t) => t.id == chatRoom.tournamentId)
        .firstOrNull;

    if (organizedTournament != null) {
      return organizedTournament.tournamentEndDate;
    }

    // Try to find in all tournaments
    final allTournament = tournamentProvider.allTournaments
        .where((t) => t.id == chatRoom.tournamentId)
        .firstOrNull;

    return allTournament?.tournamentEndDate;
  }

  DateTime? _getTournamentStartDate(ChatRoom chatRoom) {
    final tournamentProvider = context.read<TournamentProvider>();

    // Try to find tournament in organized tournaments
    final organizedTournament = tournamentProvider.organizedTournaments
        .where((t) => t.id == chatRoom.tournamentId)
        .firstOrNull;

    if (organizedTournament != null) {
      return organizedTournament.tournamentStartDate;
    }

    // Try to find in all tournaments
    final allTournament = tournamentProvider.allTournaments
        .where((t) => t.id == chatRoom.tournamentId)
        .firstOrNull;

    return allTournament?.tournamentStartDate;
  }


  String _truncateMessage(String message) {
    if (message == 'Start New Conversation') {
      return message;
    }

    final words = message.split(' ');
    if (words.length > 8) {
      return '${words.take(8).join(' ')}...';
    }

    if (message.length > 35) {
      return '${message.substring(0, 35)}...';
    }

    return message;
  }
  String _formatTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return DateFormat('MMM d').format(dateTime);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}