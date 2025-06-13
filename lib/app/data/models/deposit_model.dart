enum DepositStatus {
  pending,
  approved,
  rejected,
  cancelled,
}

enum PaymentMethod {
  bizum,
  transfer,
  paypal,
}

class DepositModel {
  final String id;
  final String userId;
  final double amount;
  final PaymentMethod paymentMethod;
  final DepositStatus status;
  final String referenceCode;
  final String? paymentProof;
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? processedBy;
  final Map<String, dynamic>? paymentDetails;

  DepositModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    this.status = DepositStatus.pending,
    required this.referenceCode,
    this.paymentProof,
    this.adminNotes,
    required this.createdAt,
    this.processedAt,
    this.processedBy,
    this.paymentDetails,
  });

  factory DepositModel.fromJson(Map<String, dynamic> json) {
    return DepositModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == json['payment_method'],
        orElse: () => PaymentMethod.bizum,
      ),
      status: DepositStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DepositStatus.pending,
      ),
      referenceCode: json['reference_code'] ?? '',
      paymentProof: json['payment_proof'],
      adminNotes: json['admin_notes'],
      createdAt: DateTime.parse(json['created_at']),
      processedAt: json['processed_at'] != null 
          ? DateTime.parse(json['processed_at']) 
          : null,
      processedBy: json['processed_by'],
      paymentDetails: json['payment_details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'payment_method': paymentMethod.name,
      'status': status.name,
      'reference_code': referenceCode,
      'payment_proof': paymentProof,
      'admin_notes': adminNotes,
      'created_at': createdAt.toIso8601String(),
      'processed_at': processedAt?.toIso8601String(),
      'processed_by': processedBy,
      'payment_details': paymentDetails,
    };
  }

  DepositModel copyWith({
    String? id,
    String? userId,
    double? amount,
    PaymentMethod? paymentMethod,
    DepositStatus? status,
    String? referenceCode,
    String? paymentProof,
    String? adminNotes,
    DateTime? createdAt,
    DateTime? processedAt,
    String? processedBy,
    Map<String, dynamic>? paymentDetails,
  }) {
    return DepositModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      referenceCode: referenceCode ?? this.referenceCode,
      paymentProof: paymentProof ?? this.paymentProof,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      processedBy: processedBy ?? this.processedBy,
      paymentDetails: paymentDetails ?? this.paymentDetails,
    );
  }

  // Getters calculados
  bool get isPending => status == DepositStatus.pending;
  bool get isApproved => status == DepositStatus.approved;
  bool get isRejected => status == DepositStatus.rejected;
  bool get isCancelled => status == DepositStatus.cancelled;
  bool get isProcessed => isApproved || isRejected;
  String? get notes => adminNotes; // Alias para compatibilidad

  String get statusText {
    switch (status) {
      case DepositStatus.pending:
        return 'Pendiente';
      case DepositStatus.approved:
        return 'Aprobado';
      case DepositStatus.rejected:
        return 'Rechazado';
      case DepositStatus.cancelled:
        return 'Cancelado';
    }
  }

  String get paymentMethodText {
    switch (paymentMethod) {
      case PaymentMethod.bizum:
        return 'Bizum';
      case PaymentMethod.transfer:
        return 'Transferencia';
      case PaymentMethod.paypal:
        return 'PayPal';
    }
  }

  String get paymentMethodIcon {
    switch (paymentMethod) {
      case PaymentMethod.bizum:
        return '📱';
      case PaymentMethod.transfer:
        return '🏦';
      case PaymentMethod.paypal:
        return '💳';
    }
  }

  Duration get timeSinceCreated => DateTime.now().difference(createdAt);
  Duration? get processingTime => processedAt?.difference(createdAt);

  String get timeSinceCreatedText {
    final duration = timeSinceCreated;
    if (duration.inDays > 0) {
      return 'hace ${duration.inDays} día${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return 'hace ${duration.inHours} hora${duration.inHours > 1 ? 's' : ''}';
    } else if (duration.inMinutes > 0) {
      return 'hace ${duration.inMinutes} minuto${duration.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'hace unos segundos';
    }
  }

  // Métodos de utilidad
  Map<String, String> getPaymentInstructions() {
    switch (paymentMethod) {
      case PaymentMethod.bizum:
        return {
          'title': 'Instrucciones para Bizum',
          'phone': '612345678',
          'concept': 'Depósito $referenceCode',
          'steps': 'Envía €${amount.toStringAsFixed(2)} al número 612345678 con el concepto "Depósito $referenceCode"',
        };
      case PaymentMethod.transfer:
        return {
          'title': 'Instrucciones para Transferencia',
          'iban': 'ES12 1234 5678 9012 3456 7890',
          'concept': 'Depósito $referenceCode',
          'steps': 'Realiza una transferencia de €${amount.toStringAsFixed(2)} al IBAN ES12 1234 5678 9012 3456 7890 con el concepto "Depósito $referenceCode"',
        };
      case PaymentMethod.paypal:
        return {
          'title': 'Instrucciones para PayPal',
          'email': 'pagos@sorteosmicro.com',
          'concept': 'Depósito $referenceCode',
          'steps': 'Envía €${amount.toStringAsFixed(2)} a pagos@sorteosmicro.com con el concepto "Depósito $referenceCode"',
        };
    }
  }

  @override
  String toString() {
    return 'DepositModel(id: $id, amount: €$amount, method: $paymentMethod, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DepositModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Clase para estadísticas de depósitos
class DepositStats {
  final int totalDeposits;
  final double totalAmount;
  final int pendingDeposits;
  final double pendingAmount;
  final int approvedDeposits;
  final double approvedAmount;
  final int rejectedDeposits;
  final double rejectedAmount;
  final double averageAmount;
  final Duration averageProcessingTime;

  DepositStats({
    this.totalDeposits = 0,
    this.totalAmount = 0.0,
    this.pendingDeposits = 0,
    this.pendingAmount = 0.0,
    this.approvedDeposits = 0,
    this.approvedAmount = 0.0,
    this.rejectedDeposits = 0,
    this.rejectedAmount = 0.0,
    this.averageAmount = 0.0,
    this.averageProcessingTime = Duration.zero,
  });

  factory DepositStats.fromJson(Map<String, dynamic> json) {
    return DepositStats(
      totalDeposits: json['total_deposits'] ?? 0,
      totalAmount: (json['total_amount'] ?? 0.0).toDouble(),
      pendingDeposits: json['pending_deposits'] ?? 0,
      pendingAmount: (json['pending_amount'] ?? 0.0).toDouble(),
      approvedDeposits: json['approved_deposits'] ?? 0,
      approvedAmount: (json['approved_amount'] ?? 0.0).toDouble(),
      rejectedDeposits: json['rejected_deposits'] ?? 0,
      rejectedAmount: (json['rejected_amount'] ?? 0.0).toDouble(),
      averageAmount: (json['average_amount'] ?? 0.0).toDouble(),
      averageProcessingTime: Duration(
        seconds: json['average_processing_time_seconds'] ?? 0,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_deposits': totalDeposits,
      'total_amount': totalAmount,
      'pending_deposits': pendingDeposits,
      'pending_amount': pendingAmount,
      'approved_deposits': approvedDeposits,
      'approved_amount': approvedAmount,
      'rejected_deposits': rejectedDeposits,
      'rejected_amount': rejectedAmount,
      'average_amount': averageAmount,
      'average_processing_time_seconds': averageProcessingTime.inSeconds,
    };
  }

  double get approvalRate => 
      totalDeposits > 0 ? approvedDeposits / totalDeposits : 0.0;
  
  double get rejectionRate => 
      totalDeposits > 0 ? rejectedDeposits / totalDeposits : 0.0;
} 