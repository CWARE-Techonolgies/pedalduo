// Add Players Screen - Dark Glassmorphism Theme
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../global/apis.dart';
import '../../../style/colors.dart';
import '../../../style/fonts_sizes.dart';
import '../../../style/texts.dart';
import '../models/add_players_model.dart';

class AddPlayersScreen extends StatefulWidget {
  final String teamId;
  final String baseUrl;

  const AddPlayersScreen({
    super.key,
    required this.teamId,
    required this.baseUrl,
  });

  @override
  State<AddPlayersScreen> createState() => _AddPlayersScreenState();
}

class _AddPlayersScreenState extends State<AddPlayersScreen> {
  List<AllPlayersModel> _players = [];
  List<AllPlayersModel> _filteredPlayers = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
    _searchController.addListener(_filterPlayers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPlayers() async {
    try {
      final response = await http.get(Uri.parse(AppApis.allUsers));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _players =
              (data['data'] as List)
                  .map((player) => AllPlayersModel.fromJson(player))
                  .toList();
          _filteredPlayers = _players;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load players');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage('Error loading players: ${e.toString()}');
    }
  }

  void _filterPlayers() {
    setState(() {
      _isSearching = _searchController.text.isNotEmpty;
      if (_searchController.text.isEmpty) {
        _filteredPlayers = _players;
      } else {
        _filteredPlayers =
            _players
                .where(
                  (player) =>
              player.name.toLowerCase().contains(
                _searchController.text.toLowerCase(),
              ) ||
                  player.email.toLowerCase().contains(
                    _searchController.text.toLowerCase(),
                  ) ||
                  player.phone.contains(_searchController.text),
            )
                .toList();
      }
    });
  }

  Future<void> _addPlayer(int playerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('${widget.baseUrl}teams/${widget.teamId}/players'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'playerId': playerId}),
      );

      if (response.statusCode == 200) {
        _showSuccessMessage('Player added successfully!');
      } else {
        _showErrorMessage('Failed to add player. Please try again.');
      }
    } catch (e) {
      _showErrorMessage('Error adding player: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.darkPrimaryColor,
      appBar: AppBar(
        title: Text(
          'Add Players',
          style: AppTexts.emphasizedTextStyle(
            context: context,
            textColor: AppColors.textPrimaryColor,
            fontSize: AppFontSizes(context).size18,
          ),
        ),
        backgroundColor: AppColors.darkSecondaryColor,
        foregroundColor: AppColors.textPrimaryColor,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.primaryGradient.cast<Color>(),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkSecondaryColor,
              AppColors.darkPrimaryColor,
              AppColors.darkTertiaryColor,
            ],
          ),
        ),
        child: Column(
          children: [
            // Search Header with Glass Effect
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.glassColor,
                  borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  border: Border.all(
                    color: AppColors.glassBorderColor,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search players by name, email, or phone',
                    hintStyle: AppTexts.bodyTextStyle(
                      context: context,
                      textColor: AppColors.textTertiaryColor,
                      fontSize: AppFontSizes(context).size14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.primaryColor,
                      size: screenWidth * 0.05,
                    ),
                    suffixIcon:
                    _isSearching
                        ? IconButton(
                      icon: Icon(Icons.clear, color: AppColors.textSecondaryColor),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.015,
                    ),
                  ),
                  style: AppTexts.bodyTextStyle(
                    context: context,
                    textColor: AppColors.textPrimaryColor,
                    fontSize: AppFontSizes(context).size14,
                  ),
                ),
              ),
            ),

            // Players List
            Expanded(
              child:
              _isLoading
                  ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryColor,
                  ),
                ),
              )
                  : _filteredPlayers.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: screenWidth * 0.15,
                      color: AppColors.textTertiaryColor,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      _isSearching
                          ? 'No players found'
                          : 'No players available',
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.textSecondaryColor,
                        fontSize: AppFontSizes(context).size16,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.all(screenWidth * 0.04),
                itemCount: _filteredPlayers.length,
                itemBuilder: (context, index) {
                  final player = _filteredPlayers[index];
                  return _buildPlayerCard(
                    player,
                    screenWidth,
                    screenHeight,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCard(
      AllPlayersModel player,
      double screenWidth,
      double screenHeight,
      ) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: AppColors.glassColor,
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          border: Border.all(
            color: AppColors.glassBorderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Player Avatar with Gradient
            Container(
              width: screenWidth * 0.12,
              height: screenWidth * 0.12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentBlueColor,
                    AppColors.accentPurpleColor,
                  ],
                ),
                border: Border.all(
                  color: AppColors.glassBorderColor,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.person,
                color: AppColors.textPrimaryColor,
                size: screenWidth * 0.06,
              ),
            ),
            SizedBox(width: screenWidth * 0.03),

            // Player Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    style: AppTexts.emphasizedTextStyle(
                      context: context,
                      textColor: AppColors.textPrimaryColor,
                      fontSize: AppFontSizes(context).size16,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Row(
                    children: [
                      Icon(
                        Icons.email,
                        color: AppColors.textTertiaryColor,
                        size: screenWidth * 0.035,
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Expanded(
                        child: Text(
                          player.email,
                          style: AppTexts.bodyTextStyle(
                            context: context,
                            textColor: AppColors.textSecondaryColor,
                            fontSize: AppFontSizes(context).size12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.003),
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        color: AppColors.textTertiaryColor,
                        size: screenWidth * 0.035,
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        player.phone,
                        style: AppTexts.bodyTextStyle(
                          context: context,
                          textColor: AppColors.textSecondaryColor,
                          fontSize: AppFontSizes(context).size12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.003),
                  Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: AppColors.primaryColor,
                        size: screenWidth * 0.035,
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        '${player.totalTournaments} tournaments',
                        style: AppTexts.bodyTextStyle(
                          context: context,
                          textColor: AppColors.primaryColor,
                          fontSize: AppFontSizes(context).size12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Add Button with Glass Effect
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor,
                    AppColors.primaryLightColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => _addPlayer(player.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppColors.textPrimaryColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.01,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: screenWidth * 0.04),
                    SizedBox(width: screenWidth * 0.01),
                    Text(
                      'Add',
                      style: AppTexts.bodyTextStyle(
                        context: context,
                        textColor: AppColors.textPrimaryColor,
                        fontSize: AppFontSizes(context).size12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: AppColors.textPrimaryColor),
        ),
        backgroundColor: AppColors.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: AppColors.textPrimaryColor),
        ),
        backgroundColor: AppColors.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }
}