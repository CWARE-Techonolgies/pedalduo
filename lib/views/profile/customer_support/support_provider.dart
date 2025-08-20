// providers/support_ticket_provider.dart
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:pedalduo/global/apis.dart';
import 'package:pedalduo/views/profile/customer_support/support_model.dart';
import '../../../services/shared_preference_service.dart';

class SupportTicketProvider with ChangeNotifier {
  static const String baseUrl = AppApis.baseUrl;

  List<SupportTicket> _tickets = [];
  SupportTicket? _selectedTicket;
  bool _isLoading = false;
  bool _isLoadingMessages = false;
  bool _isCreatingTicket = false;
  bool _isSendingMessage = false;
  String _selectedStatus = 'all';
  String _selectedCategory = 'all';
  String _selectedPriority = 'all';
  String? _error;
  String? _authToken;

  // Getters
  List<SupportTicket> get tickets => _tickets;
  SupportTicket? get selectedTicket => _selectedTicket;
  bool get isLoading => _isLoading;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isCreatingTicket => _isCreatingTicket;
  bool get isSendingMessage => _isSendingMessage;
  String get selectedStatus => _selectedStatus;
  String get selectedCategory => _selectedCategory;
  String get selectedPriority => _selectedPriority;
  String? get error => _error;

  List<SupportTicket> get filteredTickets {
    return _tickets.where((ticket) {
      bool statusMatch =
          _selectedStatus == 'all' || ticket.status == _selectedStatus;
      bool categoryMatch =
          _selectedCategory == 'all' || ticket.category == _selectedCategory;
      bool priorityMatch =
          _selectedPriority == 'all' || ticket.priority == _selectedPriority;

      return statusMatch && categoryMatch && priorityMatch;
    }).toList();
  }

  // Initialize provider with token
  Future<void> initialize() async {
    _authToken = await SharedPreferencesService.getToken();
  }

  // API Headers with token
  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };
  }

  // Filter methods
  void setStatusFilter(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setCategoryFilter(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setPriorityFilter(String priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  void clearFilters() {
    _selectedStatus = 'all';
    _selectedCategory = 'all';
    _selectedPriority = 'all';
    notifyListeners();
  }

  // Get device metadata
  Future<Map<String, dynamic>> _getDeviceMetadata() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    Map<String, dynamic> metadata = {};

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        metadata = {
          'device': 'Android',
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'version': androidInfo.version.release,
        };
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        metadata = {
          'device': 'iOS',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'version': iosInfo.systemVersion,
        };
      }
    } catch (e) {
      metadata = {'device': 'Unknown', 'error': e.toString()};
    }

    return metadata;
  }

  // Fetch all tickets
  Future<void> fetchTickets() async {
    if (_isLoading) return;

    // Ensure token is loaded
    if (_authToken == null) {
      await initialize();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${baseUrl}tickets'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _tickets = (data['data'] as List)
              .map((ticket) => SupportTicket.fromJson(ticket))
              .toList();
          _error = null;
        } else {
          _error = data['message'] ?? 'Failed to fetch tickets';
        }
      } else if (response.statusCode == 401) {
        _error = 'Session expired. Please login again.';
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new ticket
  Future<bool> createTicket(CreateTicketRequest request) async {
    if (_isCreatingTicket) return false;

    // Ensure token is loaded
    if (_authToken == null) {
      await initialize();
    }

    _isCreatingTicket = true;
    _error = null;
    notifyListeners();

    try {
      // Add device metadata
      Map<String, dynamic> requestData = request.toJson();
      if (requestData['metadata'] == null) {
        requestData['metadata'] = await _getDeviceMetadata();
      } else {
        Map<String, dynamic> deviceData = await _getDeviceMetadata();
        requestData['metadata'] = {...requestData['metadata'], ...deviceData};
      }

      final response = await http.post(
        Uri.parse('${baseUrl}tickets'),
        headers: _headers,
        body: json.encode(requestData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          SupportTicket newTicket = SupportTicket.fromJson(data['data']);
          _tickets.insert(0, newTicket);
          _error = null;
          return true;
        } else {
          _error = data['message'] ?? 'Failed to create ticket';
        }
      } else if (response.statusCode == 401) {
        _error = 'Session expired. Please login again.';
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
    } finally {
      _isCreatingTicket = false;
      notifyListeners();
    }
    return false;
  }

  // Fetch ticket by ID
  Future<void> fetchTicketById(int ticketId) async {
    if (_isLoadingMessages) return;

    // Ensure token is loaded
    if (_authToken == null) {
      await initialize();
    }

    _isLoadingMessages = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${baseUrl}tickets/$ticketId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _selectedTicket = SupportTicket.fromJson(data['data']);

          // Update ticket in the list as well
          int index = _tickets.indexWhere((t) => t.id == ticketId);
          if (index != -1) {
            _tickets[index] = _selectedTicket!;
          }

          _error = null;
        } else {
          _error = data['message'] ?? 'Failed to fetch ticket';
        }
      } else if (response.statusCode == 401) {
        _error = 'Session expired. Please login again.';
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
    } finally {
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  // Send message to ticket
  Future<bool> sendMessage(int ticketId, CreateMessageRequest request) async {
    if (_isSendingMessage) return false;

    // Ensure token is loaded
    if (_authToken == null) {
      await initialize();
    }

    _isSendingMessage = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${baseUrl}tickets/$ticketId/messages'),
        headers: _headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Refresh the ticket to get updated messages
          await fetchTicketById(ticketId);
          _error = null;
          return true;
        } else {
          _error = data['message'] ?? 'Failed to send message';
        }
      } else if (response.statusCode == 401) {
        _error = 'Session expired. Please login again.';
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
    } finally {
      _isSendingMessage = false;
      notifyListeners();
    }
    return false;
  }

  // Select ticket
  void selectTicket(SupportTicket ticket) {
    _selectedTicket = ticket;
    notifyListeners();
  }

  // Clear selected ticket
  void clearSelectedTicket() {
    _selectedTicket = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh tickets (pull to refresh)
  Future<void> refreshTickets() async {
    await fetchTickets();
  }

  // Get ticket count by status
  int getTicketCountByStatus(String status) {
    if (status == 'all') return _tickets.length;
    return _tickets.where((ticket) => ticket.status == status).length;
  }

  // Get unread messages count (assuming user messages are always read)
  int getUnreadMessagesCount(SupportTicket ticket) {
    return ticket.messages
        .where((msg) => msg.senderType == 'admin' && !msg.isInternal)
        .length;
  }

  @override
  void dispose() {
    super.dispose();
  }
}