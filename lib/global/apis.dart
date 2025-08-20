class AppApis {

  //1
  // static const String baseUrl = 'https://padelduo.duckdns.org/';
  // static const String chatBaseUrl = 'https://padelduo-chat.duckdns.org/';

  //2
  static const String baseUrl = 'https://api.padel-duo.com/';
  static const String chatBaseUrl = 'https://chat.padel-duo.com/';

 //3
 //  static const String baseUrl = 'http://54.73.38.172/padel-duo/';
 //  static const String chatBaseUrl = 'http://54.73.38.172/padel-duo/chat/';


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



  //clubs teams auth_token for all from shared preferences
static const String createClubTeam = "${baseUrl}club-teams"; //post {
//   "name": "Test Club Team",
//   "is_private": false,
//   "avatar": "base64 of image"
// }
static const String userClubTeam = "${baseUrl}club-teams/my-team"; //get
static const String publicTeamsTeam = "${baseUrl}club-teams/public-teams"; //get
static const String getClubTeamById = "${baseUrl}club-teams/id"; //get and in the end id will come like club-teams/1
static const String joinPublicTeam = "${baseUrl}club-teams//request-join"; //post, and between 2 // the id will come, no body
static const String transferCaptaincy = "${baseUrl}club-teams//transfer-captain"; // put, and between 2 // the id will come and body is {
//   "new_captain_id": 2
// }
static const String teamPrivacyUpdate = "${baseUrl}club-teams/id/privacy"; //put , body {
//   "is_private": true
// }
static const String removeMemberFromTeam = "${baseUrl}club-teams/id/members/id"; //delete
static const String leaveClubTeam = "${baseUrl}club-teams/id/leave";

  //////////
  static const String subscribeToFCM =
      '${baseUrl}subscriptions/topics/subscribe';
  static const String unsubscribeToFCM =
      '${baseUrl}subscriptions/topics/unsubscribe';
  static const String sentInvitations =
      '${baseUrl}my-sent-invitations';
  static const String recievedInvitations =
      '${baseUrl}my-received-invitations';
  static const String registerFCM = '${baseUrl}fcm/register/';
  static const String getNotificationPreferences = '${baseUrl}notifications/preferences';
  static const String updateNotificationPreferences = '${baseUrl}notifications/preferences';
  static const String logoutFCM = '${baseUrl}fcm/logout';

  ///////chats
  static const String chatRooms = '${chatBaseUrl}api/chat/rooms';
  static const String directChatWithUser =
      '${chatBaseUrl}api/chat/rooms/direct';
}
