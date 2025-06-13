enum RaffleStatus {
  scheduled,
  active,
  drawing,
  completed,
  cancelled,
}

class RaffleModel {
  final String id;
  final String title;
  final String description;
  final double prizeAmount;
  final double ticketPrice;
  final int maxTickets;
  final int soldTickets;
  final DateTime startTime;
  final DateTime endTime;
  final RaffleStatus status;
  final String? winnerId;
  final String? winnerName;
  final String? winningTicket;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? metadata;
  final List<RaffleParticipant> participants;

  RaffleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.prizeAmount,
    required this.ticketPrice,
    required this.maxTickets,
    this.soldTickets = 0,
    required this.startTime,
    required this.endTime,
    this.status = RaffleStatus.scheduled,
    this.winnerId,
    this.winnerName,
    this.winningTicket,
    required this.createdAt,
    this.completedAt,
    this.metadata,
    this.participants = const [],
  });

  factory RaffleModel.fromJson(Map<String, dynamic> json) {
    // Handle different response formats from Supabase
    // For tickets count format
    int soldTicketsCount = 0;
    if (json['tickets'] != null && json['tickets'] is List) {
      // This might be empty list
      soldTicketsCount = (json['tickets'] as List).length;
    } else if (json['tickets'] != null && json['tickets'] is Map && json['tickets']['count'] != null) {
      // This is the count response format
      soldTicketsCount = json['tickets']['count'] as int? ?? 0;
    } else {
      soldTicketsCount = json['sold_tickets'] ?? 0;
    }
    
    // Participants handling
    List<RaffleParticipant> participantsList = [];
    if (json['participants'] != null && json['participants'] is List) {
      // Direct participants list format
      participantsList = (json['participants'] as List)
          .map((p) => RaffleParticipant.fromJson(p))
          .toList();
    } else if (json['participants'] != null && json['participants'] is Map) {
      // This might be a specific format with user_id as key
      final userIds = (json['participants'] as Map).keys.toList();
      participantsList = userIds.map((id) => 
          RaffleParticipant(
            userId: id.toString(),
            userName: 'Participant', // We don't have the name in this format
            ticketCount: 1, // Default count
            tickets: ['Unknown'], // We don't have ticket numbers in this format
            purchaseTime: DateTime.now(),
            amountPaid: 0.0, // We don't have this info in this format
          )
      ).toList();
    }

    // Handle the winner data which could be in a nested format
    String? winnerIdValue;
    String? winnerNameValue;
    
    if (json['winner'] != null && json['winner'] is Map<String, dynamic>) {
      winnerIdValue = json['winner']['id'];
      winnerNameValue = json['winner']['full_name'];
    } else {
      winnerIdValue = json['winner_id'];
      winnerNameValue = json['winner_name'];
    }
    
    return RaffleModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      prizeAmount: (json['prize_amount'] ?? 0.0).toDouble(),
      ticketPrice: (json['ticket_price'] ?? 0.0).toDouble(),
      maxTickets: json['max_tickets'] ?? 0,
      soldTickets: soldTicketsCount,
      startTime: json['start_time'] != null ? DateTime.parse(json['start_time']) : DateTime.now(),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : DateTime.now().add(const Duration(days: 1)),
      status: RaffleStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? ''),
        orElse: () => RaffleStatus.scheduled,
      ),
      winnerId: winnerIdValue,
      winnerName: winnerNameValue,
      winningTicket: json['winning_ticket'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      metadata: json['metadata'],
      participants: participantsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'prize_amount': prizeAmount,
      'ticket_price': ticketPrice,
      'max_tickets': maxTickets,
      'sold_tickets': soldTickets,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': status.name,
      'winner_id': winnerId,
      'winner_name': winnerName,
      'winning_ticket': winningTicket,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'metadata': metadata,
      'participants': participants.map((p) => p.toJson()).toList(),
    };
  }

  RaffleModel copyWith({
    String? id,
    String? title,
    String? description,
    double? prizeAmount,
    double? ticketPrice,
    int? maxTickets,
    int? soldTickets,
    DateTime? startTime,
    DateTime? endTime,
    RaffleStatus? status,
    String? winnerId,
    String? winnerName,
    String? winningTicket,
    DateTime? createdAt,
    DateTime? completedAt,
    Map<String, dynamic>? metadata,
    List<RaffleParticipant>? participants,
  }) {
    return RaffleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      prizeAmount: prizeAmount ?? this.prizeAmount,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      maxTickets: maxTickets ?? this.maxTickets,
      soldTickets: soldTickets ?? this.soldTickets,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      winnerId: winnerId ?? this.winnerId,
      winnerName: winnerName ?? this.winnerName,
      winningTicket: winningTicket ?? this.winningTicket,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      metadata: metadata ?? this.metadata,
      participants: participants ?? this.participants,
    );
  }

  // Getters calculados
  bool get isActive => status == RaffleStatus.active;
  bool get isCompleted => status == RaffleStatus.completed;
  bool get isCancelled => status == RaffleStatus.cancelled;
  bool get isDrawing => status == RaffleStatus.drawing;
  bool get isScheduled => status == RaffleStatus.scheduled;
  
  bool get hasStarted => DateTime.now().isAfter(startTime);
  bool get hasEnded => DateTime.now().isAfter(endTime);
  bool get isLive => hasStarted && !hasEnded && isActive;
  
  int get availableTickets => maxTickets - soldTickets;
  bool get isSoldOut => soldTickets >= maxTickets;
  double get fillPercentage => soldTickets / maxTickets;
  
  Duration get timeUntilStart => startTime.difference(DateTime.now());
  Duration get timeUntilEnd => endTime.difference(DateTime.now());
  Duration get timeRemaining => isLive ? timeUntilEnd : Duration.zero;
  
  double get totalRevenue => soldTickets * ticketPrice;
  double get profitMargin => (totalRevenue - prizeAmount) / totalRevenue;
  
  // Getters adicionales para compatibilidad
  DateTime get endDate => endTime;
  int get participantCount => participants.length;
  int get userTicketCount => 0; // Placeholder - needs userId to be accurate
  
  String get statusText {
    switch (status) {
      case RaffleStatus.scheduled:
        return 'Programado';
      case RaffleStatus.active:
        return 'Activo';
      case RaffleStatus.drawing:
        return 'Sorteando';
      case RaffleStatus.completed:
        return 'Completado';
      case RaffleStatus.cancelled:
        return 'Cancelado';
    }
  }

  

  String get timeRemainingText {
    if (!isLive) return '';
    
    final duration = timeRemaining;
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  // Métodos de utilidad
  int getUserTicketCount(String userId) {
    return participants
        .where((p) => p.userId == userId)
        .fold(0, (sum, p) => sum + p.ticketCount);
  }

  List<String> getUserTickets(String userId) {
    return participants
        .where((p) => p.userId == userId)
        .expand((p) => p.tickets)
        .toList();
  }

  double getUserInvestment(String userId) {
    return getUserTicketCount(userId) * ticketPrice;
  }

  bool hasUserParticipated(String userId) {
    return participants.any((p) => p.userId == userId);
  }

  @override
  String toString() {
    return 'RaffleModel(id: $id, title: $title, prize: €$prizeAmount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RaffleModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class RaffleParticipant {
  final String userId;
  final String userName;
  final String? userAvatar;
  final int ticketCount;
  final List<String> tickets;
  final DateTime purchaseTime;
  final double amountPaid;

  RaffleParticipant({
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.ticketCount,
    required this.tickets,
    required this.purchaseTime,
    required this.amountPaid,
  });

  factory RaffleParticipant.fromJson(Map<String, dynamic> json) {
    return RaffleParticipant(
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      userAvatar: json['user_avatar'],
      ticketCount: json['ticket_count'] ?? 0,
      tickets: List<String>.from(json['tickets'] ?? []),
      purchaseTime: DateTime.parse(json['purchase_time']),
      amountPaid: (json['amount_paid'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'ticket_count': ticketCount,
      'tickets': tickets,
      'purchase_time': purchaseTime.toIso8601String(),
      'amount_paid': amountPaid,
    };
  }

  RaffleParticipant copyWith({
    String? userId,
    String? userName,
    String? userAvatar,
    int? ticketCount,
    List<String>? tickets,
    DateTime? purchaseTime,
    double? amountPaid,
  }) {
    return RaffleParticipant(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      ticketCount: ticketCount ?? this.ticketCount,
      tickets: tickets ?? this.tickets,
      purchaseTime: purchaseTime ?? this.purchaseTime,
      amountPaid: amountPaid ?? this.amountPaid,
    );
  }

  @override
  String toString() {
    return 'RaffleParticipant(userId: $userId, userName: $userName, tickets: $ticketCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RaffleParticipant && 
           other.userId == userId && 
           other.purchaseTime == purchaseTime;
  }

  @override
  int get hashCode => Object.hash(userId, purchaseTime);
} 