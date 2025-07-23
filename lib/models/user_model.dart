class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String country;
  final String gender;
  final bool isFirstTournament;
  final int tournamentsPlayed;
  final int tournamentsOrganized;
  final int firstPlaceWins;
  final int secondPlaceWins;
  final String averageRating;
  final String walletBalance;
  final String? imageUrl;
  final String? passwordResetToken;
  final String? passwordResetExpires;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.country,
    required this.gender,
    required this.isFirstTournament,
    required this.tournamentsPlayed,
    required this.tournamentsOrganized,
    required this.firstPlaceWins,
    required this.secondPlaceWins,
    required this.averageRating,
    required this.walletBalance,
    this.imageUrl,
    this.passwordResetToken,
    this.passwordResetExpires,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      country: json['country'],
      gender: json['gender'],
      isFirstTournament: json['is_first_tournament'] ?? true,
      tournamentsPlayed: json['tournaments_played'] ?? 0,
      tournamentsOrganized: json['tournaments_organized'] ?? 0,
      firstPlaceWins: json['first_place_wins'] ?? 0,
      secondPlaceWins: json['second_place_wins'] ?? 0,
      averageRating: json['average_rating'] ?? '0.00',
      walletBalance: json['wallet_balance'] ?? '0.00',
      imageUrl: json['image_url'],
      passwordResetToken: json['password_reset_token'],
      passwordResetExpires: json['password_reset_expires'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'country': country,
      'gender': gender,
      'is_first_tournament': isFirstTournament,
      'tournaments_played': tournamentsPlayed,
      'tournaments_organized': tournamentsOrganized,
      'first_place_wins': firstPlaceWins,
      'second_place_wins': secondPlaceWins,
      'average_rating': averageRating,
      'wallet_balance': walletBalance,
      'image_url': imageUrl,
      'password_reset_token': passwordResetToken,
      'password_reset_expires': passwordResetExpires,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? country,
    String? gender,
    bool? isFirstTournament,
    int? tournamentsPlayed,
    int? tournamentsOrganized,
    int? firstPlaceWins,
    int? secondPlaceWins,
    String? averageRating,
    String? walletBalance,
    String? imageUrl,
    String? passwordResetToken,
    String? passwordResetExpires,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      gender: gender ?? this.gender,
      isFirstTournament: isFirstTournament ?? this.isFirstTournament,
      tournamentsPlayed: tournamentsPlayed ?? this.tournamentsPlayed,
      tournamentsOrganized: tournamentsOrganized ?? this.tournamentsOrganized,
      firstPlaceWins: firstPlaceWins ?? this.firstPlaceWins,
      secondPlaceWins: secondPlaceWins ?? this.secondPlaceWins,
      averageRating: averageRating ?? this.averageRating,
      walletBalance: walletBalance ?? this.walletBalance,
      imageUrl: imageUrl ?? this.imageUrl,
      passwordResetToken: passwordResetToken ?? this.passwordResetToken,
      passwordResetExpires: passwordResetExpires ?? this.passwordResetExpires,
    );
  }
}