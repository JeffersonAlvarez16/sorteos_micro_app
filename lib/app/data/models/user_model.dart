class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? phone;
  final String? avatar;
  final double balance;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive;
  final bool emailVerified;
  final String? fcmToken;
  final Map<String, dynamic>? preferences;
  final UserStats stats;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    this.avatar,
    this.balance = 0.0,
    required this.createdAt,
    this.lastLogin,
    this.isActive = true,
    this.emailVerified = false,
    this.fcmToken,
    this.preferences,
    required this.stats,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'],
      phone: json['phone'],
      avatar: json['avatar'],
      balance: (json['balance'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      lastLogin: json['last_login'] != null 
          ? DateTime.parse(json['last_login']) 
          : null,
      isActive: json['is_active'] ?? true,
      emailVerified: json['email_verified'] ?? false,
      fcmToken: json['fcm_token'],
      preferences: json['preferences'],
      stats: UserStats.fromJson(json['stats'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'avatar': avatar,
      'balance': balance,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'is_active': isActive,
      'email_verified': emailVerified,
      'fcm_token': fcmToken,
      'preferences': preferences,
      'stats': stats.toJson(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? avatar,
    double? balance,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive,
    bool? emailVerified,
    String? fcmToken,
    Map<String, dynamic>? preferences,
    UserStats? stats,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      emailVerified: emailVerified ?? this.emailVerified,
      fcmToken: fcmToken ?? this.fcmToken,
      preferences: preferences ?? this.preferences,
      stats: stats ?? this.stats,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName, balance: $balance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class UserStats {
  final int totalTicketsPurchased;
  final int totalRafflesParticipated;
  final int totalWins;
  final double totalWinnings;
  final double totalSpent;
  final int currentStreak;
  final int maxStreak;
  final DateTime? lastWin;
  final double winRate;

  UserStats({
    this.totalTicketsPurchased = 0,
    this.totalRafflesParticipated = 0,
    this.totalWins = 0,
    this.totalWinnings = 0.0,
    this.totalSpent = 0.0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.lastWin,
    this.winRate = 0.0,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalTicketsPurchased: json['total_tickets_purchased'] ?? 0,
      totalRafflesParticipated: json['total_raffles_participated'] ?? 0,
      totalWins: json['total_wins'] ?? 0,
      totalWinnings: (json['total_winnings'] ?? 0.0).toDouble(),
      totalSpent: (json['total_spent'] ?? 0.0).toDouble(),
      currentStreak: json['current_streak'] ?? 0,
      maxStreak: json['max_streak'] ?? 0,
      lastWin: json['last_win'] != null 
          ? DateTime.parse(json['last_win']) 
          : null,
      winRate: (json['win_rate'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_tickets_purchased': totalTicketsPurchased,
      'total_raffles_participated': totalRafflesParticipated,
      'total_wins': totalWins,
      'total_winnings': totalWinnings,
      'total_spent': totalSpent,
      'current_streak': currentStreak,
      'max_streak': maxStreak,
      'last_win': lastWin?.toIso8601String(),
      'win_rate': winRate,
    };
  }

  UserStats copyWith({
    int? totalTicketsPurchased,
    int? totalRafflesParticipated,
    int? totalWins,
    double? totalWinnings,
    double? totalSpent,
    int? currentStreak,
    int? maxStreak,
    DateTime? lastWin,
    double? winRate,
  }) {
    return UserStats(
      totalTicketsPurchased: totalTicketsPurchased ?? this.totalTicketsPurchased,
      totalRafflesParticipated: totalRafflesParticipated ?? this.totalRafflesParticipated,
      totalWins: totalWins ?? this.totalWins,
      totalWinnings: totalWinnings ?? this.totalWinnings,
      totalSpent: totalSpent ?? this.totalSpent,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStreak: maxStreak ?? this.maxStreak,
      lastWin: lastWin ?? this.lastWin,
      winRate: winRate ?? this.winRate,
    );
  }

  double get profitLoss => totalWinnings - totalSpent;
  bool get isProfitable => profitLoss > 0;
} 