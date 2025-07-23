import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../style/colors.dart';
import '../../style/texts.dart';
import '../services/socket_services.dart';
import '../views/all_players.dart';
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
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _groupTabController;
  void _setupSocketListeners() async {
    // Ensure socket is connected first
    if (!SocketService.instance.isConnected) {
      await SocketService.instance.connect();
      // Wait a bit for connection to establish
      await Future.delayed(Duration(milliseconds: 500));
    }

    print('Setting up room_updated listener...');

    // Listen for room updates
    SocketService.instance.onRoomUpdated((updatedRoom) {
      print('Room updated event received: $updatedRoom');
      // Refresh the chat rooms list when a room is updated
      if (mounted) {
        context.read<ChatRoomsProvider>().refresh();
      }
    });
  }
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _groupTabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return; // avoid redundant rebuilds
      setState(() {}); // triggers rebuild for the AppBar icon
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.refresh) {
        context.read<ChatRoomsProvider>().refresh();
      }
      context.read<ChatRoomsProvider>().fetchChatRooms();
      _setupSocketListeners();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _groupTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
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
          Visibility(
            visible: _tabController.index == 0,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (_) => AllPlayers()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Container(
                  decoration: BoxDecoration(color: AppColors.orangeColor),
                  child: Icon(CupertinoIcons.add, color: AppColors.whiteColor),
                ),
              ),
            ),
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
          tabs: [Tab(text: 'Direct Messages'), Tab(text: 'Group Chats')],
        ),
      ),
      body: Consumer<ChatRoomsProvider>(
        builder: (context, provider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              // Direct Messages Tab
              _buildChatList(
                context,
                provider.directMessages,
                provider.isLoading,
                provider.error,
                'direct',
              ),
              // Group Chats Tab with nested tabs
              buildGroupChatsTab(provider),
            ],
          );
        },
      ),
    );
  }

  Widget buildGroupChatsTab(ChatRoomsProvider provider) {
    return Column(
      children: [
        Container(
          color: AppColors.backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TabBar(
            controller: _groupTabController,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.orangeColor,
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.all(4),
            labelStyle: AppTexts.emphasizedTextStyle(
              context: context,
              textColor: Colors.white,
            ).copyWith(fontWeight: FontWeight.w600, fontSize: 16),
            unselectedLabelStyle: AppTexts.bodyTextStyle(
              context: context,
              textColor: AppColors.greyColor,
            ).copyWith(fontWeight: FontWeight.w500, fontSize: 15),
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.greyColor,
            dividerColor: Colors.transparent,
            tabs: [
              Tab(height: 44, child: Center(child: Text('Team'))),
              Tab(height: 44, child: Center(child: Text('Tournament'))),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _groupTabController,
            children: [
              // Team Chats
              _buildChatList(
                context,
                provider.teamChats,
                provider.isLoading,
                provider.error,
                'team',
              ),
              // Tournament Chats
              _buildChatList(
                context,
                provider.tournamentChats,
                provider.isLoading,
                provider.error,
                'tournament',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatList(
    BuildContext context,
    List<ChatRoom> chatRooms,
    bool isLoading,
    String? error,
    String type,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;

    if (error != null) {
      return _buildErrorState(context, error);
    }
    if (!isLoading && chatRooms.isEmpty) {
      return _buildEmptyState(context, type);
    }
    return Skeletonizer(
      enabled: isLoading,
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<ChatRoomsProvider>().refresh();
        },
        color: AppColors.lightGreenColor,
        child: ListView.builder(
          padding: EdgeInsets.all(width * 0.04),
          itemCount: isLoading ? 8 : chatRooms.length,
          itemBuilder: (context, index) {
            if (isLoading) {
              return _buildSkeletonItem(context);
            }

            final chatRoom = chatRooms[index];
            return _buildChatRoomItem(context, chatRoom);
          },
        ),
      ),
    );
  }

  Widget _buildSkeletonItem(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(bottom: width * 0.03),
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: AppColors.darkGreyColor,
        borderRadius: BorderRadius.circular(width * 0.04),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyBlueGrey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
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
          Container(
            width: width * 0.15,
            height: width * 0.03,
            decoration: BoxDecoration(
              color: AppColors.navyBlueGrey,
              borderRadius: BorderRadius.circular(width * 0.015),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatRoomItem(BuildContext context, ChatRoom chatRoom) {
    final width = MediaQuery.of(context).size.width;

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
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Consumer<ChatRoomsProvider>(
        builder: (
          BuildContext context,
          ChatRoomsProvider value,
          Widget? child,
        ) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(width * 0.04),
              onTap: () async {
                await value.markMessagesAsRead(chatRoom.id.toString());
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => ChatScreen(chatRoom: chatRoom),
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(width * 0.04),
                child: Row(
                  children: [
                    _buildAvatar(context, chatRoom),
                    SizedBox(width: width * 0.04),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  chatRoom.displayName,
                                  style: AppTexts.emphasizedTextStyle(
                                    context: context,
                                    textColor: AppColors.whiteColor,
                                    fontSize: width * 0.04,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: width * 0.01),
                          Text(
                            chatRoom.lastMessage?.content ??
                                'Start New Conversation',
                            style: AppTexts.bodyTextStyle(
                              context: context,
                              textColor:
                                  chatRoom.lastMessage?.content != null
                                      ? AppColors.greyColor
                                      : AppColors.greenColor,
                              fontWeight:
                                  chatRoom.lastMessage?.content != null
                                      ? FontWeight.normal
                                      : FontWeight.w600,
                              fontSize: width * 0.032,
                            ),
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
                        SizedBox(height: width * 0.015),
                        if (chatRoom.unreadCount != null &&
                            chatRoom.unreadCount! > 0)
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
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, ChatRoom chatRoom) {
    final width = MediaQuery.of(context).size.width;

    if (chatRoom.type == 'team') {
      return Container(
        width: width * 0.12,
        height: width * 0.12,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.orangeColor, AppColors.lightOrangeColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(width * 0.06),
        ),
        child: Icon(
          Icons.group,
          color: AppColors.whiteColor,
          size: width * 0.06,
        ),
      );
    } else if (chatRoom.type == 'tournament') {
      return Container(
        width: width * 0.12,
        height: width * 0.12,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.blueColor, AppColors.purpleColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(width * 0.06),
        ),
        child: Icon(
          Icons.emoji_events,
          color: AppColors.whiteColor,
          size: width * 0.06,
        ),
      );
    } else {
      // For direct messages, show user avatar
      final user = chatRoom.user2 ?? chatRoom.user1;
      return Container(
        width: width * 0.12,
        height: width * 0.12,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.blueColor, AppColors.purpleColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(width * 0.06),
        ),
        child:
            user?.avatarUrl != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(width * 0.06),
                  child: Image.network(
                    user!.avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildInitialsAvatar(context, user);
                    },
                  ),
                )
                : _buildInitialsAvatar(context, user),
      );
    }
  }

  Widget _buildInitialsAvatar(BuildContext context, User? user) {
    final width = MediaQuery.of(context).size.width;

    return Center(
      child: Text(
        user?.initials ?? '?',
        style: AppTexts.emphasizedTextStyle(
          context: context,
          textColor: AppColors.whiteColor,
          fontSize: width * 0.04,
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
              textColor: AppColors.whiteColor,
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
              context.read<ChatRoomsProvider>().refresh();
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

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

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
  Widget _buildEmptyState(BuildContext context, String type) {
    final width = MediaQuery.of(context).size.width;

    String title;
    String subtitle;
    IconData icon;

    switch (type) {
      case 'direct':
        title = 'No Direct Messages';
        subtitle = 'Start a conversation with someone';
        icon = Icons.chat_bubble_outline;
        break;
      case 'team':
        title = 'No Team Chats';
        subtitle = 'Join a team to start chatting';
        icon = Icons.group_outlined;
        break;
      case 'tournament':
        title = 'No Tournament Chats';
        subtitle = 'Join a tournament to participate in discussions';
        icon = Icons.emoji_events_outlined;
        break;
      default:
        title = 'No Messages';
        subtitle = 'Start a new conversation';
        icon = Icons.chat_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: width * 0.2,
            color: AppColors.greyColor.withOpacity(0.5),
          ),
          SizedBox(height: width * 0.04),
          Text(
            title,
            style: AppTexts.emphasizedTextStyle(
              context: context,
              textColor: AppColors.greyColor,
              fontSize: width * 0.045,
            ),
          ),
          SizedBox(height: width * 0.02),
          Text(
            subtitle,
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
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (_) => AllPlayers()),
                );
              },
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
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.08,
                  vertical: width * 0.04,
                ),
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
}
