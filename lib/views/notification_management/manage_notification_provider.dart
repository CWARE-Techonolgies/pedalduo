import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:pedalduo/providers/navigation_provider.dart';
import 'package:pedalduo/utils/app_utils.dart';
import 'package:pedalduo/views/home_screen/views/highlighst_screen.dart';
import 'package:pedalduo/views/play/providers/tournament_provider.dart';
import 'package:pedalduo/views/play/views/play_screen.dart';
import 'package:provider/provider.dart';
import '../../enums/notification_loading_state.dart';
import 'notification_model.dart';
import 'notification_services.dart';

class ManageNotificationProvider with ChangeNotifier {
  List<NotificationModel> _allNotifications = [];
  List<NotificationModel> _filteredNotifications = [];
  NotificationLoadingState _loadingState = NotificationLoadingState.idle;
  String _errorMessage = '';
  int _unreadCount = 0;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;
  bool _isInitialLoad = true;
  String _selectedFilter =
      'all'; // 'all', 'marketing_updates', 'payment_confirmations', etc.

  // Preference type options for dropdown
  final List<String> _preferenceTypes = [
    'all',
    'general_announcements',
    'marketing_updates',
    'payment_confirmations',
    'team_updates',
    'match_notifications',
    'tournament_updates',
  ];

  // Getters
  List<NotificationModel> get notifications => _filteredNotifications;
  List<NotificationModel> get allNotifications => _allNotifications;
  NotificationLoadingState get loadingState => _loadingState;
  String get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  bool get isInitialLoad => _isInitialLoad;
  String get selectedFilter => _selectedFilter;
  List<String> get preferenceTypes => _preferenceTypes;

  // Get display name for preference types
  String getFilterDisplayName(String filter) {
    switch (filter) {
      case 'all':
        return 'All Notifications';
      case 'general_announcements':
        return 'General Announcements';
      case 'marketing_updates':
        return 'Marketing Updates';
      case 'payment_confirmations':
        return 'Payment Confirmations';
      case 'team_updates':
        return 'Team Updates';
      case 'match_notifications':
        return 'Match Notifications';
      case 'tournament_updates':
        return 'Tournament Updates';
      default:
        return filter
            .replaceAll('_', ' ')
            .split(' ')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_selectedFilter == 'all') {
      _filteredNotifications = List.from(_allNotifications);
    } else {
      _filteredNotifications =
          _allNotifications
              .where(
                (notification) =>
                    notification.data.preferenceType == _selectedFilter,
              )
              .toList();
    }
  }

  void _resetPagination() {
    _currentPage = 1;
    _hasMore = true;
    _allNotifications.clear();
    _filteredNotifications.clear();
  }

  void _setLoadingState(NotificationLoadingState state) {
    _loadingState = state;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _loadingState = NotificationLoadingState.error;
    notifyListeners();
  }

  Future<void> loadNotifications({bool loadMore = false}) async {
    if (!loadMore) {
      _resetPagination();
      _setLoadingState(NotificationLoadingState.loading);
    } else if (!_hasMore) {
      return;
    }

    try {
      final response = await NotificationService.getAllNotifications(
        page: _currentPage,
        limit: 20,
        unreadOnly: false, // Always load all notifications
      );

      if (loadMore) {
        _allNotifications.addAll(response.notifications);
      } else {
        _allNotifications = response.notifications;
      }

      _unreadCount = response.unreadCount;
      _totalPages = response.pagination.totalPages;
      _hasMore = _currentPage < _totalPages;
      _currentPage++;

      // Apply current filter
      _applyFilter();

      _loadingState = NotificationLoadingState.loaded;
      _isInitialLoad = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Load notifications error: $e');
      _setError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> loadUnreadCount() async {
    try {
      _unreadCount = await NotificationService.getUnreadCount();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Load unread count error: $e');
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await NotificationService.markAsRead(notificationId);

      // Update local state in both all and filtered lists
      final allIndex = _allNotifications.indexWhere(
        (n) => n.id == notificationId,
      );
      if (allIndex != -1 && !_allNotifications[allIndex].isRead) {
        _allNotifications[allIndex] = _allNotifications[allIndex].copyWith(
          isRead: true,
          readAt: DateTime.now().toIso8601String(),
        );
        _unreadCount = (_unreadCount > 0) ? _unreadCount - 1 : 0;
      }

      final filteredIndex = _filteredNotifications.indexWhere(
        (n) => n.id == notificationId,
      );
      if (filteredIndex != -1 &&
          !_filteredNotifications[filteredIndex].isRead) {
        _filteredNotifications[filteredIndex] =
            _filteredNotifications[filteredIndex].copyWith(
              isRead: true,
              readAt: DateTime.now().toIso8601String(),
            );
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Mark as read error: $e');
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await NotificationService.markAllAsRead();

      // Update local state
      _allNotifications =
          _allNotifications
              .map(
                (n) => n.copyWith(
                  isRead: true,
                  readAt: DateTime.now().toIso8601String(),
                ),
              )
              .toList();

      _filteredNotifications =
          _filteredNotifications
              .map(
                (n) => n.copyWith(
                  isRead: true,
                  readAt: DateTime.now().toIso8601String(),
                ),
              )
              .toList();

      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Mark all as read error: $e');
      rethrow;
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      await NotificationService.deleteNotification(notificationId);

      // Update local state
      final notification = _allNotifications.firstWhere(
        (n) => n.id == notificationId,
      );
      _allNotifications.removeWhere((n) => n.id == notificationId);
      _filteredNotifications.removeWhere((n) => n.id == notificationId);

      if (!notification.isRead) {
        _unreadCount = (_unreadCount > 0) ? _unreadCount - 1 : 0;
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Delete notification error: $e');
      rethrow;
    }
  }

  Future<void> deleteAllNotifications() async {
    try {
      await NotificationService.deleteAllNotifications();

      // Update local state
      _allNotifications.clear();
      _filteredNotifications.clear();
      _unreadCount = 0;
      _resetPagination();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Delete all notifications error: $e');
      rethrow;
    }
  }

  Future<void> refreshNotifications() async {
    _isInitialLoad = false;
    await loadNotifications();
  }

  // Navigation helper method
  String? getNavigationRoute(
    NotificationModel notification,
    BuildContext context,
  ) {
    final preferenceType = notification.data.preferenceType;

    switch (preferenceType) {
      case 'marketing_updates':
        // TODO: Navigate to Marketing/Promotions screen
        context.read<NavigationProvider>().goToTab(context, 0);
        return '/marketing';
      //marketing done here

      case 'payment_confirmations':
        AppUtils.showInfoDialog(
          context,
          'Payment Information',
          'This is an upcoming feature',
        );
        return '/payment-history';
      //payment done here

      case 'team_updates':
        context.read<NavigationProvider>().goToTab(context, 1);
        return '/team-management';
      //team done here

      case 'match_notifications':
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => const PlayScreen(initialTabIndex: 1),
          ),
        );
        return '/matches';
      //matches done here

      case 'tournament_updates':
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => const PlayScreen(initialTabIndex: 0),
          ),
        );
        return '/tournament-details';
      //tournament done here

      case 'general_announcements':
      default:
        return null;
    }
  }
}
