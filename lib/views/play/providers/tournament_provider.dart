import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:pedalduo/payments/easy_paisa_payment_provider.dart';
import 'package:pedalduo/views/play/models/tournaments_model.dart';
import 'package:pedalduo/views/play/providers/team_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../../global/apis.dart';
import '../../../utils/app_utils.dart';
import '../models/my_tournament_models.dart';

class TournamentProvider with ChangeNotifier {
  // Current selected tab index
  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;
  // Add these cache flags
  bool _allTournamentsLoaded = false;
  bool _myTournamentsLoaded = false;

  bool get allTournamentsLoaded => _allTournamentsLoaded;
  bool get myTournamentsLoaded => _myTournamentsLoaded;
  // Current selected sub tab (0: My Tournaments, 1: All Tournaments)
  int _selectedSubTabIndex = 0;
  int get selectedSubTabIndex => _selectedSubTabIndex;

  String _imageUrl = '';
  String get imageUrl => _imageUrl;

  // Tournament lists
  List<Tournament> _allTournaments = [];
  List<Tournament> _myTournaments = [];

  // Add these variables to your TournamentProvider class
  List<MyTournament> _organizedTournaments = [];
  List<MyTournament> _playedTournaments = [];

  // Getters
  List<MyTournament> get organizedTournaments => _organizedTournaments;
  List<MyTournament> get playedTournaments => _playedTournaments;
  List<Tournament> get allTournaments => _allTournaments;
  List<Tournament> get myTournaments => _myTournaments;

  // Tournament creation form data
  String _title = '';
  String _location = '';
  int _playersPerTeam = 0;
  int _totalTeams = 0;
  String _packageType = 'Basic - 5000 PKR';
  double _playerFee = 0.0;
  String _gender = 'Male';
  DateTime? _registrationEndDate;
  DateTime? _tournamentStartDate;
  DateTime? _tournamentEndDate;
  String _description = '';
  String _rulesAndRegulations = '';

  // Form validation error
  String _totalTeamsError = '';
  String get totalTeamsError => _totalTeamsError;

  // Loading states
  bool _isLoading = false;
  bool _isCancelLoading = false;
  bool _isLoadingTournaments = false;
  bool get isLoading => _isLoading;
  bool get isCancelLoading => _isCancelLoading;
  bool get isLoadingTournaments => _isLoadingTournaments;

  // Error handling
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Lists (keeping for backward compatibility)
  final List<String> _tournaments = [];
  final List<String> _teams = [];
  final List<String> _matches = [];

  List<String> get tournaments => _tournaments;
  List<String> get teams => _teams;
  List<String> get matches => _matches;

  // Package options with pricing
  set selectedTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners(); // Don't forget this!
  }

  final List<String> _packageTypes = [
    'Basic - 5000 PKR',
    'Premium - 10000 PKR',
    'VIP - 15000 PKR',
  ];
  List<String> get packageTypes => _packageTypes;

  // Gender options
  final List<String> _genderOptions = ['Male', 'Female', 'Mixed'];
  List<String> get genderOptions => _genderOptions;

  // Getters for form data
  String get title => _title;
  String get location => _location;
  int get playersPerTeam => _playersPerTeam;
  int get totalTeams => _totalTeams;
  String get packageType => _packageType;
  double get playerFee => _playerFee;
  String get gender => _gender;
  DateTime? get registrationEndDate => _registrationEndDate;
  DateTime? get tournamentStartDate => _tournamentStartDate;
  DateTime? get tournamentEndDate => _tournamentEndDate;
  String get description => _description;
  String get rulesAndRegulations => _rulesAndRegulations;

  // Get package price based on current package type
  double get packagePrice {
    switch (_packageType) {
      case 'Basic - 5000 PKR':
        return 5000.0;
      case 'Premium - 10000 PKR':
        return 10000.0;
      case 'VIP - 15000 PKR':
        return 15000.0;
      default:
        return 5000.0;
    }
  }

  double getPackagePrice(bool isFirstTournament) {
    if (isFirstTournament) return 0.0;

    switch (_packageType) {
      case 'Basic - 5000 PKR':
        return 5000.0;
      case 'Premium - 10000 PKR':
        return 10000.0;
      case 'VIP - 15000 PKR':
        return 15000.0;
      default:
        return 5000.0;
    }
  }

  // Set image URL method
  void setImageUrl(String value) {
    _imageUrl = value;
    notifyListeners();
  }

  // Tab navigation methods
  void setSelectedTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void setSelectedSubTab(int index) {
    _selectedSubTabIndex = index;
    notifyListeners();
  }

  Future<void> fetchAllTournaments({
    String? apiUrl,
    bool forceRefresh = false,
  }) async {
    // Don't fetch if already loaded unless force refresh
    if (_allTournamentsLoaded && !forceRefresh) return;

    _isLoadingTournaments = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final url = AppApis.getAllTournament;
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final List<dynamic> tournamentList = responseData['data'];
          _allTournaments =
              tournamentList.map((json) => Tournament.fromJson(json)).toList();
          _allTournamentsLoaded = true; // Mark as loaded
          _errorMessage = '';
        } else {
          print('error');
          _errorMessage = 'Failed to load tournaments';
        }
      } else if (response.statusCode == 401) {
        print('error');
        _errorMessage = 'Authentication failed. Please login again.';
      } else {
        print('error');
        _errorMessage = 'Failed to load tournaments. Please try again.';
      }
    } catch (e) {
      print('error $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        _errorMessage = 'Network error. Please check your internet connection.';
      } else {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      }
    } finally {
      _isLoadingTournaments = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyTournaments({bool forceRefresh = false}) async {
    if (_myTournamentsLoaded && !forceRefresh) return;

    _isLoadingTournaments = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        _errorMessage = 'Authentication token not found. Please login again.';
        _isLoadingTournaments = false;
        notifyListeners();
        return;
      }

      final url = AppApis.getMyTournaments;
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final data = responseData['data'];

          // Parse organized tournaments
          final organizedList = data['organized'] as List? ?? [];
          _organizedTournaments =
              organizedList.map((json) => MyTournament.fromJson(json)).toList();

          _myTournamentsLoaded = true;
          _errorMessage = '';
        } else {
          _errorMessage = 'Failed to load your tournaments';
        }
      } else if (response.statusCode == 401) {
        _errorMessage = 'Authentication failed. Please login again.';
      } else {
        _errorMessage = 'Failed to load your tournaments. Please try again.';
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        _errorMessage = 'Network error. Please check your internet connection.';
      } else {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      }
    } finally {
      _isLoadingTournaments = false;
      notifyListeners();
    }
  }

  // Method to clear cache when needed (e.g., after creating new tournament)
  void clearTournamentCache() {
    _allTournamentsLoaded = false;
    _myTournamentsLoaded = false;
  }

  Future<void> pickAndCompressImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800, // Reduce resolution to decrease size
        maxHeight: 800,
        imageQuality: 70, // Compress image quality (0-100)
      );

      if (pickedFile != null) {
        // Read image bytes
        final Uint8List imageBytes = await pickedFile.readAsBytes();

        // Further compress the image using the image package
        final img.Image? originalImage = img.decodeImage(imageBytes);
        if (originalImage != null) {
          // Resize image if it's too large
          final img.Image resizedImage = img.copyResize(
            originalImage,
            width: originalImage.width > 600 ? 600 : originalImage.width,
            height: originalImage.height > 600 ? 600 : originalImage.height,
          );

          // Encode as JPEG with compression
          final List<int> compressedBytes = img.encodeJpg(
            resizedImage,
            quality: 60,
          );

          // Convert to base64 with proper prefix
          final String base64String = base64Encode(compressedBytes);
          final String imageDataUrl = 'data:image/jpeg;base64,$base64String';

          // Update the image URL
          setImageUrl(imageDataUrl);

          if (kDebugMode) {
            print('Original size: ${imageBytes.length} bytes');
            print('Compressed size: ${compressedBytes.length} bytes');
            print(
              'Compression ratio: ${((imageBytes.length - compressedBytes.length) / imageBytes.length * 100).toStringAsFixed(1)}%',
            );
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking/compressing image: $e');
      }
      _errorMessage = 'Failed to select image. Please try again.';
      notifyListeners();
    }
  }

  // Form data setters
  void setTitle(String value) {
    _title = value;
    notifyListeners();
  }

  void setPlayersPerTeam(int value) {
    _playersPerTeam = value;
    notifyListeners();
  }

  void setTotalTeams(int value) {
    _totalTeams = value;
    _validateTotalTeams();
    _autoSelectPackage();
    notifyListeners();
  }

  void setPackageType(String value) {
    _packageType = value;
    notifyListeners();
  }

  void setPlayerFee(double value) {
    _playerFee = value;
    notifyListeners();
  }

  void setGender(String value) {
    _gender = value;
    notifyListeners();
  }

  void setRegistrationEndDate(DateTime date) {
    _registrationEndDate = date;
    notifyListeners();
  }

  void setTournamentStartDate(DateTime date) {
    _tournamentStartDate = date;
    notifyListeners();
  }

  void setTournamentEndDate(DateTime date) {
    _tournamentEndDate = date;
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void setRulesAndRegulations(String value) {
    _rulesAndRegulations = value;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Get token from SharedPreferences
  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      if (kDebugMode) {
        print('Error getting token: $e');
      }
      return null;
    }
  }

  // Save token to SharedPreferences
  Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving token: $e');
      }
    }
  }

  // Auto-select package based on number of teams
  void _autoSelectPackage() {
    if (_totalTeams >= 4 && _totalTeams <= 7) {
      _packageType = 'Basic - 5000 PKR';
    } else if (_totalTeams > 8 && _totalTeams <= 16) {
      _packageType = 'Premium - 10000 PKR';
    } else if (_totalTeams >= 17 && _totalTeams <= 32) {
      _packageType = 'VIP - 15000 PKR';
    }
  }

  // Validation methods
  void _validateTotalTeams() {
    if (_totalTeams > 0 && _totalTeams < 4) {
      _totalTeamsError = "Total teams can't be less than 4.";
    } else if (_totalTeams > 32) {
      _totalTeamsError = "Total teams can't be more than 32.";
    } else {
      _totalTeamsError = '';
    }
  }

  bool get isFormValid {
    return _title.isNotEmpty &&
        _location.isNotEmpty &&
        _totalTeams >= 4 &&
        _totalTeams <= 32 &&
        _registrationEndDate != null &&
        _tournamentStartDate != null &&
        _tournamentEndDate != null &&
        _totalTeamsError.isEmpty;
  }

  // Create tournament method with API integration
  Future<bool> createTournament({
    String? apiUrl,
    bool isFirstTournament = false,
    required BuildContext
    context, // added context so we can read PaymentProvider
  }) async {
    if (!isFormValid) {
      _errorMessage = 'Please fill all required fields correctly.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        _errorMessage = 'Authentication token not found. Please login again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final Map<String, dynamic> tournamentData = {
        'title': _title,
        'description':
            _description.isEmpty
                ? 'Tournament created via mobile app'
                : _description,
        'location': _location,
        'players_per_team': 2,
        'total_teams': _totalTeams,
        'player_fee': _playerFee,
        'gender': _gender.toLowerCase(),
        'registration_end_date': _registrationEndDate!.toIso8601String(),
        'tournament_start_date': _tournamentStartDate!.toIso8601String(),
        'tournament_end_date': _tournamentEndDate!.toIso8601String(),
        'rules_and_regulations':
            _rulesAndRegulations.isEmpty
                ? 'Standard tournament rules apply'
                : _rulesAndRegulations,
        'package_type':
            _packageType == 'Basic - 5000 PKR'
                ? 'Package 8'
                : _packageType == 'Premium - 10000 PKR'
                ? 'Package 16'
                : 'Package 32',
        'package_price': getPackagePrice(isFirstTournament),
        'image_url': _imageUrl,
        'is_first_tournament': isFirstTournament,
      };

      final url = apiUrl ?? AppApis.createTournament;
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(tournamentData),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final tournamentId = responseData['data']?['id'];
        if (tournamentId != null) {
          await context
              .read<EasyPaisaPaymentProvider>()
              .confirmPaymentWithBackend(tournamentId, context);
        } else {
          _errorMessage = 'Tournament created but ID not found in response.';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        _tournaments.add(_title);
        _resetForm();
        clearTournamentCache();
        await fetchMyTournaments();

        _isLoading = false;
        notifyListeners();
        return true;
      } else if (response.statusCode == 401) {
        _errorMessage = 'Authentication failed. Please login again.';
        _isLoading = false;
        notifyListeners();
        return false;
      } else {
        _errorMessage =
            responseData['message'] ??
            'Failed to create tournament. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        _errorMessage = 'Network error. Please check your internet connection.';
      } else {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearImage() {
    _imageUrl = '';
    notifyListeners();
  }

  void _resetForm() {
    _title = '';
    _location = '';
    _playersPerTeam = 0;
    _totalTeams = 0;
    _packageType = 'Basic - 5000 PKR';
    _playerFee = 0.0;
    _gender = 'Male';
    _registrationEndDate = null;
    _tournamentStartDate = null;
    _tournamentEndDate = null;
    _description = '';
    _rulesAndRegulations = '';
    _totalTeamsError = '';
    _imageUrl = '';
    _errorMessage = '';
  }

  Future<void> registerTeam({
    required BuildContext context,
    required int tournamentId,
    required String teamName,
    String? teamAvatar,
  }) async {
    print('id is ${tournamentId.toString()}');
    print('name is ${teamName.toString()}');
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Authentication required')));
        return;
      }

      final response = await http.post(
        Uri.parse(AppApis.registerTeam),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'tournament_id': tournamentId,
          'name': teamName,
          'team_avatar':
              teamAvatar != null ? 'data:image/png;base64,$teamAvatar' : null,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode <= 300) {
        final responseData = jsonDecode(response.body);
        final teamId = responseData['data']['id'].toString();
        await _processPayment(teamId);
        AppUtils.showSuccessSnackBar(context, 'Team registered successfully!');
        print('New Team ID: $teamId');
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['message'] ?? 'Registration failed';

        print('Registration Failed: $errorMessage');
        AppUtils.showFailureSnackBar(context, errorMessage);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _processPayment(String teamId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('${AppApis.baseUrl}teams/$teamId/payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('wow done');
      } else {
        print('error in response ${response.body}');
        // _showErrorMessage('Payment failed. Please try again.');
      }
    } catch (e) {
      print('error in e: $e');
      // _showErrorMessage('Error processing payment: ${e.toString()}');
    } finally {
      // setState(() {
      //   _isProcessing = false;
      // });
    }
  }

  final List<Map<String, dynamic>> _padelCourts = [
    {"name": "Padel Arena", "location": "Model Town", "courts": 2},
    {"name": "Lets Padel", "location": "Packages Mall", "courts": 2},
    {"name": "Club Padel", "location": "DHA Phase 4", "courts": 3},
    {"name": "Padel In", "location": "DHA Phase 5", "courts": 9},
    {"name": "Padel Pro", "location": "DHA Phase 5", "courts": 2},
    {"name": "Padel Star", "location": "DHA Phase 5", "courts": 1},
    {"name": "The Big Game", "location": "DHA Phase 5", "courts": 2},
    {"name": "Padel Park", "location": "DHA Phase 5", "courts": 2},
    {"name": "Padel Club", "location": "DHA Phase 5", "courts": 2},
    {"name": "Padel Hub", "location": "DHA Phase 5", "courts": 2},
    {"name": "Space Padel", "location": "DHA Phase 5", "courts": 2},
    {"name": "Padel Connect", "location": "DHA Phase 5", "courts": 2},
    {"name": "Mega Arena", "location": "DHA Phase 5", "courts": 6},
    {"name": "Futsal Range", "location": "DHA Phase 5", "courts": 2},
    {"name": "5th Generation", "location": "DHA Phase 6", "courts": 1},
    {"name": "Jumbo Jump Padel", "location": "DHA Phase 8", "courts": 6},
    {"name": "Padel Rush", "location": "DHA Phase 9", "courts": 2},
    {"name": "Palm Padel", "location": "Bedian Road", "courts": 2},
    {"name": "Fusion Station", "location": "Bedian Road", "courts": 2},
    {"name": "Padel Pro", "location": "Barki Road", "courts": 2},
    {"name": "Padel Mania", "location": "Barki Road", "courts": 2},
    {"name": "The Courts", "location": "Gulberg", "courts": 1},
    {"name": "Sky Padel", "location": "Gulberg", "courts": 2},
    {"name": "Padel Central", "location": "Gulberg", "courts": 2},
    {"name": "Lot Six", "location": "Gulberg", "courts": 1},
    {"name": "Padel Social", "location": "Gulberg", "courts": 2},
    {"name": "Padellina", "location": "Barkat Market", "courts": 1},
    {"name": "Padel X", "location": "Johar Town", "courts": 1},
    {"name": "Padelland", "location": "Johar Town", "courts": 1},
    {"name": "Beach Club Padel", "location": "Johar Town", "courts": 1},
    {"name": "Arena 360", "location": "Johar Town", "courts": 1},
    {"name": "Padel Shadel", "location": "Wapda Town", "courts": 2},
    {"name": "Cross Courts", "location": "Valencia", "courts": 2},
    {"name": "Wynn Sports Arena", "location": "Valencia", "courts": 2},
    {"name": "Pro Ball Arena", "location": "Valencia", "courts": 2},
    {"name": "Futsal Range", "location": "Valencia", "courts": 2},
    {"name": "The Box", "location": "Pine Avenue", "courts": 2},
    {"name": "Padel Next", "location": "Pine Avenue", "courts": 1},
    {"name": "Padel Play", "location": "Bahria Town", "courts": 2},
    {"name": "Pulse Active", "location": "Bahria Town", "courts": 3},
    {"name": "Padel Plus", "location": "DHA EME", "courts": 2},
    {"name": "The Mad Padel", "location": "DHA EME", "courts": 1},
    {"name": "Padel Cafe", "location": "DHA Phase 6", "courts": 2},
  ];
  List<Map<String, dynamic>> get padelCourts => _padelCourts;
  Map<String, dynamic>? _selectedCourt;
  Map<String, dynamic>? get selectedCourt => _selectedCourt;

  // Update the setLocation method
  void setLocation(Map<String, dynamic>? court) {
    _selectedCourt = court;
    _location = court != null ? "${court['name']} - ${court['location']}" : '';
    notifyListeners();
  }

  Future<bool> cancelTournament({
    required BuildContext context,
    required int tournamentId,
  }) async {
    _isCancelLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        _errorMessage = 'Authentication token not found. Please login again.';
        _isCancelLoading = false;
        notifyListeners();
        return false;
      }

      final url = '${AppApis.baseUrl}tournaments/$tournamentId/cancel';
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Clear cache to refresh tournaments
        clearTournamentCache();

        // Refresh tournaments list
        await fetchMyTournaments(forceRefresh: true);

        _isCancelLoading = false;
        notifyListeners();

        // Check if context is still mounted before showing snackbar
        if (context.mounted) {
          AppUtils.showSuccessSnackBar(
            context,
            'Tournament cancelled successfully!',
          );
        }
        return true;
      } else if (response.statusCode == 401) {
        _errorMessage = 'Authentication failed. Please login again.';
        if (context.mounted) {
          AppUtils.showFailureSnackBar(context, _errorMessage);
        }
      } else {
        final errorData = json.decode(response.body);
        _errorMessage = errorData['message'] ?? 'Failed to cancel tournament.';
        if (context.mounted) {
          AppUtils.showFailureSnackBar(context, _errorMessage);
        }
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        _errorMessage = 'Network error. Please check your internet connection.';
      } else {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      }
      if (context.mounted) {
        AppUtils.showFailureSnackBar(context, _errorMessage);
      }
    }

    _isCancelLoading = false;
    notifyListeners();
    return false;
  }

  // List<String> _selectedStatuses = ['ongoing', 'approved']; // Default filter
  bool _showFilterOptions = false;

  // Available status options
  final List<Map<String, String>> _statusOptions = [
    {'value': 'ongoing', 'display': 'Ongoing'},
    {'value': 'approved', 'display': 'Up Coming'},
    {'value': 'completed', 'display': 'Completed'},
    {'value': 'under review', 'display': 'Under Review'},
    {'value': 'rejected', 'display': 'Rejected'},
    {'value': 'cancelled', 'display': 'Cancelled'},
  ];

  // Getters
  // List<String> get selectedStatuses => _selectedStatuses;
  bool get showFilterOptions => _showFilterOptions;
  List<Map<String, String>> get statusOptions => _statusOptions;

  // Filter methods
  // void toggleStatusFilter(String status) {
  //   if (_selectedStatuses.contains(status)) {
  //     if (_selectedStatuses.length > 1) {
  //       // Don't allow empty filter
  //       _selectedStatuses.remove(status);
  //     }
  //   } else {
  //     _selectedStatuses.add(status);
  //   }
  //   notifyListeners();
  // }

  void toggleFilterOptions() {
    _showFilterOptions = !_showFilterOptions;
    notifyListeners();
  }

  // void resetFilters() {
  //   _selectedStatuses = ['ongoing', 'approved'];
  //   notifyListeners();
  // }

  // Filtered tournament lists
  // List<Tournament> get filteredAllTournaments {
  //   return _allTournaments.where((tournament) {
  //     return _selectedStatuses.contains(tournament.status.toLowerCase());
  //   }).toList();
  // }
  //
  // List<MyTournament> get filteredOrganizedTournaments {
  //   return _organizedTournaments.where((tournament) {
  //     return _selectedStatuses.contains(tournament.status.toLowerCase());
  //   }).toList();
  // }

  // List<MyTournament> get filteredPlayedTournaments {
  //   return _playedTournaments.where((tournament) {
  //     return _selectedStatuses.contains(tournament.status.toLowerCase());
  //   }).toList();
  // }

  // Empty state checks
  bool get hasTournaments => _tournaments.isNotEmpty;
  bool get hasTeams => _teams.isNotEmpty;
  bool get hasMatches => _matches.isNotEmpty;
  // For tournaments tab - check if user has created tournaments
  bool get hasMyTournaments => _myTournaments.isNotEmpty;
  bool get hasAllTournaments => _allTournaments.isNotEmpty;
}
