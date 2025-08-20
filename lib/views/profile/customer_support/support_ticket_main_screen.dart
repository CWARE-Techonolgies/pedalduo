// screens/support_ticket_screen.dart
import 'package:flutter/material.dart';
import 'package:pedalduo/views/profile/customer_support/support_model.dart';
import 'package:pedalduo/views/profile/customer_support/support_provider.dart';
import 'package:pedalduo/views/profile/customer_support/ticket_details_screen.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../../style/colors.dart';
import '../../../style/texts.dart';
import 'package:intl/intl.dart';

import 'create_ticket_screen.dart';
import 'customer_skelton.dart';

class SupportTicketScreen extends StatefulWidget {
  const SupportTicketScreen({Key? key}) : super(key: key);

  @override
  State<SupportTicketScreen> createState() => _SupportTicketScreenState();
}

class _SupportTicketScreenState extends State<SupportTicketScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey _filterButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // Load tickets on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupportTicketProvider>().fetchTickets();
    });

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        final provider = context.read<SupportTicketProvider>();
        switch (_tabController.index) {
          case 0:
            provider.setStatusFilter('all');
            break;
          case 1:
            provider.setStatusFilter('open');
            break;
          case 2:
            provider.setStatusFilter('in_progress');
            break;
          case 3:
            provider.setStatusFilter('resolved');
            break;
          case 4:
            provider.setStatusFilter('closed');
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showFilterMenu() {
    final RenderBox renderBox = _filterButtonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx - 200, // Adjust to show menu to the left of the button
        offset.dy + size.height + 8,
        offset.dx + size.width,
        offset.dy + size.height + 400,
      ),
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      items: [
        PopupMenuItem<String>(
          enabled: false,
          child: _buildFilterMenuContent(),
        ),
      ],
    );
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
              _buildTabBar(context),
              Expanded(child: _buildTicketsList(context, screenSize)),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildCreateTicketFAB(context),
    );
  }

  Widget _buildAppBar(BuildContext context, Size screenSize) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        border: Border(
          bottom: BorderSide(color: AppColors.glassBorderColor, width: 1),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.support_agent_rounded,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Support Center',
                      style: AppTexts.emphasizedTextStyle(
                        context: context,
                        textColor: AppColors.textPrimaryColor,
                        fontSize: screenSize.width * 0.045,
                      ),
                    ),
                    Consumer<SupportTicketProvider>(
                      builder: (context, provider, _) {
                        return Text(
                          '${provider.tickets.length} tickets',
                          style: AppTexts.bodyTextStyle(
                            context: context,
                            textColor: AppColors.textSecondaryColor,
                            fontSize: screenSize.width * 0.032,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Consumer<SupportTicketProvider>(
                builder: (context, provider, _) {
                  final hasActiveFilters = provider.selectedCategory != 'all';

                  return IconButton(
                    key: _filterButtonKey,
                    onPressed: _showFilterMenu,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: hasActiveFilters
                            ? AppColors.primaryColor.withOpacity(0.2)
                            : AppColors.glassColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: hasActiveFilters
                              ? AppColors.primaryColor.withOpacity(0.3)
                              : AppColors.glassBorderColor,
                          width: 1,
                        ),
                        boxShadow: hasActiveFilters
                            ? [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                            : [],
                      ),
                      child: Stack(
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            color: hasActiveFilters
                                ? AppColors.primaryColor
                                : AppColors.textSecondaryColor,
                            size: 20,
                          ),
                          if (hasActiveFilters)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: AppColors.whiteColor,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  context.read<SupportTicketProvider>().refreshTickets();
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
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.glassColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorderColor, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: TabBar(
              dividerColor: Colors.transparent,
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorPadding: const EdgeInsets.all(4),
              labelColor: AppColors.whiteColor,
              unselectedLabelColor: AppColors.textSecondaryColor,
              labelStyle: AppTexts.bodyTextStyle(
                context: context,
                textColor: AppColors.whiteColor,
                fontWeight: FontWeight.w600,
                fontSize: MediaQuery.of(context).size.width * 0.028,
              ),
              unselectedLabelStyle: AppTexts.bodyTextStyle(
                context: context,
                textColor: AppColors.textSecondaryColor,
                fontSize: MediaQuery.of(context).size.width * 0.028,
              ),
              tabs: [
                Consumer<SupportTicketProvider>(
                  builder: (context, provider, _) {
                    return Tab(
                      child: _buildTabContent(
                        'All',
                        provider.getTicketCountByStatus('all'),
                      ),
                    );
                  },
                ),
                Consumer<SupportTicketProvider>(
                  builder: (context, provider, _) {
                    return Tab(
                      child: _buildTabContent(
                        'Open',
                        provider.getTicketCountByStatus('open'),
                      ),
                    );
                  },
                ),
                Consumer<SupportTicketProvider>(
                  builder: (context, provider, _) {
                    return Tab(
                      child: _buildTabContent(
                        'Progress',
                        provider.getTicketCountByStatus('in_progress'),
                      ),
                    );
                  },
                ),
                Consumer<SupportTicketProvider>(
                  builder: (context, provider, _) {
                    return Tab(
                      child: _buildTabContent(
                        'Resolved',
                        provider.getTicketCountByStatus('resolved'),
                      ),
                    );
                  },
                ),
                Consumer<SupportTicketProvider>(
                  builder: (context, provider, _) {
                    return Tab(
                      child: _buildTabContent(
                        'Closed',
                        provider.getTicketCountByStatus('closed'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(String title, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title),
        if (count > 0) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.whiteColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.whiteColor,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFilterMenuContent() {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.glassColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.glassBorderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterMenuHeader(),
              const SizedBox(height: 16),
              _buildFilterMenuChips(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterMenuHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.filter_alt_rounded,
            color: AppColors.primaryColor,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Filter by Category',
            style: AppTexts.emphasizedTextStyle(
              context: context,
              textColor: AppColors.textPrimaryColor,
              fontSize: MediaQuery.of(context).size.width * 0.038,
            ),
          ),
        ),
        Consumer<SupportTicketProvider>(
          builder: (context, provider, _) {
            return GestureDetector(
              onTap: () {
                provider.clearFilters();
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Clear',
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.primaryColor,
                    fontSize: MediaQuery.of(context).size.width * 0.030,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilterMenuChips() {
    return Consumer<SupportTicketProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterMenuChip(
                  'All Categories',
                  'all',
                  provider.selectedCategory,
                      (value) {
                    provider.setCategoryFilter(value);
                    Navigator.pop(context);
                  },
                  icon: Icons.all_inclusive_rounded,
                  count: _getTicketCountByCategory(provider, 'all'),
                ),
                ...TicketCategory.values.map(
                      (category) => _buildFilterMenuChip(
                    category.displayName,
                    category.value,
                    provider.selectedCategory,
                        (value) {
                      provider.setCategoryFilter(value);
                      Navigator.pop(context);
                    },
                    icon: category.icon,
                    count: _getTicketCountByCategory(provider, category.value),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Helper method to get ticket count by category
  int _getTicketCountByCategory(SupportTicketProvider provider, String category) {
    if (category == 'all') {
      return provider.tickets.length;
    }
    return provider.tickets.where((ticket) => ticket.category == category).length;
  }

  Widget _buildFilterMenuChip(
      String label,
      String value,
      String selectedValue,
      Function(String) onSelected, {
        IconData? icon,
        int count = 0,
      }) {
    final isSelected = selectedValue == value;

    return GestureDetector(
      onTap: () => onSelected(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.15)
              : AppColors.glassLightColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor.withOpacity(0.4)
                : AppColors.glassBorderColor,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isSelected
                    ? AppColors.primaryColor
                    : AppColors.textSecondaryColor,
                size: 16,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: AppTexts.bodyTextStyle(
                context: context,
                textColor: isSelected
                    ? AppColors.primaryColor
                    : AppColors.textSecondaryColor,
                fontSize: MediaQuery.of(context).size.width * 0.030,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryColor.withOpacity(0.2)
                      : AppColors.textSecondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.primaryColor
                        : AppColors.textSecondaryColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTicketsList(BuildContext context, Size screenSize) {
    return Consumer<SupportTicketProvider>(
      builder: (context, provider, _) {
        if (provider.error != null) {
          return _buildErrorState(context, provider.error!);
        }

        if (provider.isLoading) {
          return _buildLoadingState();
        }

        final filteredTickets = provider.filteredTickets;

        if (filteredTickets.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: provider.refreshTickets,
          backgroundColor: AppColors.glassColor,
          color: AppColors.primaryColor,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: filteredTickets.length,
            itemBuilder: (context, index) {
              return _buildTicketCard(
                context,
                filteredTickets[index],
                screenSize,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTicketCard(
      BuildContext context,
      SupportTicket ticket,
      Size screenSize,
      ) {
    final category = TicketCategory.fromValue(ticket.category);
    final priority = TicketPriority.fromValue(ticket.priority);
    final status = TicketStatus.fromValue(ticket.status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder:
                        (context, animation, secondaryAnimation) =>
                        TicketDetailScreen(ticketId: ticket.id),
                    transitionsBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                        ) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;

                      var tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            ticket.ticketNumber,
                            style: AppTexts.bodyTextStyle(
                              context: context,
                              textColor: AppColors.textSecondaryColor,
                              fontSize: screenSize.width * 0.028,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
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
                              fontSize: screenSize.width * 0.026,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ticket.subject,
                      style: AppTexts.emphasizedTextStyle(
                        context: context,
                        textColor: AppColors.textPrimaryColor,
                        fontSize: screenSize.width * 0.038,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ticket.description,
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.textSecondaryColor,
                        fontSize: screenSize.width * 0.032,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.glassLightColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            category.icon,
                            color: AppColors.primaryColor,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category.displayName,
                          style: AppTexts.bodyTextStyle(
                            context: context,
                            textColor: AppColors.textSecondaryColor,
                            fontSize: screenSize.width * 0.028,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
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
                              fontSize: screenSize.width * 0.026,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat(
                            'MMM dd, yyyy • hh:mm a',
                          ).format(ticket.createdAt),
                          style: AppTexts.bodyTextStyle(
                            context: context,
                            textColor: AppColors.textTertiaryColor,
                            fontSize: screenSize.width * 0.026,
                          ),
                        ),
                        if (ticket.messages.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentBlueColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  color: AppColors.accentBlueColor,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  ticket.messages.length.toString(),
                                  style: AppTexts.bodyTextStyle(
                                    context: context,
                                    textColor: AppColors.accentBlueColor,
                                    fontSize: screenSize.width * 0.024,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: 5,
      itemBuilder: (context, index) => const TicketCardSkeleton(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
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
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.support_agent_rounded,
                    size: 48,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'No Tickets Found',
                  style: AppTexts.emphasizedTextStyle(
                    context: context,
                    textColor: AppColors.textPrimaryColor,
                    fontSize: MediaQuery.of(context).size.width * 0.045,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You haven\'t created any support tickets yet.\nTap the + button to get started!',
                  textAlign: TextAlign.center,
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.textSecondaryColor,
                    fontSize: MediaQuery.of(context).size.width * 0.032,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
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
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.errorColor,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Something went wrong',
                  style: AppTexts.emphasizedTextStyle(
                    context: context,
                    textColor: AppColors.textPrimaryColor,
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.textSecondaryColor,
                    fontSize: MediaQuery.of(context).size.width * 0.032,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<SupportTicketProvider>().fetchTickets();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.whiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateTicketFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryColor, AppColors.primaryLightColor],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
              const CreateTicketScreen(),
              transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                  ) {
                const begin = Offset(0.0, 1.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                var tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: AppColors.whiteColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'New Ticket',
              style: AppTexts.bodyTextStyle(
                context: context,
                textColor: AppColors.whiteColor,
                fontSize: MediaQuery.of(context).size.width * 0.032,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}