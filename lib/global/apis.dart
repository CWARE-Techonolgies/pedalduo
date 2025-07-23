class AppApis {
  static const String baseUrl = 'https://padelduo.duckdns.org/';
  static const String chatBaseUrl = 'https://padelduo-chat.duckdns.org/';


  static const String signUp = '${baseUrl}signup';
  static const String login = '${baseUrl}login';
  static const String userProfile = '${baseUrl}profile';
  static const String forgetPassword = '${baseUrl}forgot-password';
  static const String createTournament = '${baseUrl}tournaments';
  static const String getAllTournament = '${baseUrl}tournaments';
  static const String getMyTournaments = '${baseUrl}my-tournaments';
  static const String packageFee = '${baseUrl}payments/package-fee';
  static const String registerTeam = '${baseUrl}teams';
  static const String myTeams = '${baseUrl}my-teams';
  static const String allUsers = '${baseUrl}admin/users';
  static const String myMatches = '${baseUrl}tournaments/matches/my-matches';
  static const String registerFCM = '${baseUrl}fcm/register/';
  static const String subscribeToFCM =
      '${baseUrl}subscriptions/topics/subscribe';
  static const String unsubscribeToFCM =
      '${baseUrl}subscriptions/topics/unsubscribe';
  static const String getNotificationPreferences =
      '${baseUrl}notifications/preferences';

  ///////chats
  static const String chatRooms = '${chatBaseUrl}api/chat/rooms';
  static const String directChatWithUser =
      '${chatBaseUrl}api/chat/rooms/direct';
}
