class AppApis {
  // FOR TESTING/DEVELOPMENT - Use these URLs
  // static const String baseUrl = 'https://apitest.padel-duo.com/';
  // static const String chatBaseUrl = 'https://chattest.padel-duo.com/';
  // static const bool isProduction = false;

  // FOR PRODUCTION - Comment above and uncomment below when deploying
  static const String baseUrl = 'https://api.padel-duo.com/';
  static const String chatBaseUrl = 'https://chat.padel-duo.com/';
  static const bool isProduction = true;

  // All your existing APIs (no changes needed)
  static const String signUp = '${baseUrl}signup';
  static const String login = '${baseUrl}login';
  static const String userProfile = '${baseUrl}profile';
  static const String forgetPassword = '${baseUrl}forgot-password';
  static const String updateResetPassword = '${baseUrl}reset-password';
  static const String changePassword = '${baseUrl}password';
  static const String createTournament = '${baseUrl}tournaments';
  static const String getAllTournament = '${baseUrl}tournaments';
  static const String getMyTournaments = '${baseUrl}my-tournaments';
  static const String packageFee = '${baseUrl}payments/package-fee';
  static const String registerTeam = '${baseUrl}teams';
  static const String myTeams = '${baseUrl}my-teams';
  static const String allUsers = '${baseUrl}admin/users';
  static const String eligibleUsers = '${baseUrl}eligible/users';
  static const String sendEmailOtp = '${baseUrl}send-email-otp';
  static const String verifyEmailOtp = '${baseUrl}verify-email-otp';
  static const String sendPhoneOtp = '${baseUrl}send-phone-otp';
  static const String verifyPhoneOtp = '${baseUrl}verify-phone-otp';
  static const String myMatches = '${baseUrl}tournaments/matches/my-matches';
  static const String checkDeletionValidation =
      '${baseUrl}user/active-participation';
  static const String deleteAccount = '${baseUrl}user/delete-account';

  // Club Teams APIs
  static const String createClubTeam = "${baseUrl}club-teams";
  static const String userClubTeam = "${baseUrl}club-teams/my-team";
  static const String publicTeamsTeam = "${baseUrl}club-teams/public-teams";
  static String getClubTeamById(int id) => "${baseUrl}club-teams/$id";
  static String joinPublicTeam(int id) =>
      "${baseUrl}club-teams/$id/request-join";
  static String transferCaptaincy(int id) =>
      "${baseUrl}club-teams/$id/transfer-captain";
  static String teamPrivacyUpdate(int id) => "${baseUrl}club-teams/$id/privacy";
  static String removeMemberFromTeam(int teamId, int memberId) =>
      "${baseUrl}club-teams/$teamId/members/$memberId";
  static String leaveClubTeam(int id) => "${baseUrl}club-teams/$id/leave";

  // FCM APIs
  static const String subscribeToFCM =
      '${baseUrl}subscriptions/topics/subscribe';
  static const String unsubscribeToFCM =
      '${baseUrl}subscriptions/topics/unsubscribe';
  static const String sentInvitations = '${baseUrl}my-sent-invitations';
  static const String recievedInvitations = '${baseUrl}my-received-invitations';
  static const String registerFCM = '${baseUrl}fcm/register/';
  static const String getNotificationPreferences =
      '${baseUrl}notifications/preferences';
  static const String updateNotificationPreferences =
      '${baseUrl}notifications/preferences';
  static const String logoutFCM = '${baseUrl}fcm/logout';

  // Chat APIs
  static const String chatRooms = '${chatBaseUrl}api/chat/rooms';
  static const String directChatWithUser =
      '${chatBaseUrl}api/chat/rooms/direct';

  //manage notifications
  static const String unreadNotifications =
      "${baseUrl}notifications/unread-count"; //get
  static const String getAllNotifications = "${baseUrl}notifications/"; //get
  static const String readOneNotification =
      "${baseUrl}notifications/"; //patch id/read/ after slash
  static const String readAllNotification =
      "${baseUrl}notifications/read-all"; //patch
  static const String deleteOneNotification =
      "${baseUrl}notifications/"; //delete id after slash
  static const String deleteALlNotification =
      "${baseUrl}notifications"; //delete
}
