import 'dart:convert';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../data/models/deposit_model.dart';
import 'auth_service.dart';

class PaymentService extends GetxService {
  static PaymentService get to => Get.find();
  
  final AuthService _authService = AuthService.to;
  
  final RxBool _isInitialized = false.obs;
  final RxBool _isProcessing = false.obs;
  
  // Getters
  bool get isInitialized => _isInitialized.value;
  bool get isProcessing => _isProcessing.value;

  Future<PaymentService> init() async {
    await _initializeStripe();
    _isInitialized.value = true;
    return this;
  }

  // Inicializar Stripe
  Future<void> _initializeStripe() async {
    try {
      Stripe.publishableKey = AppConfig.stripePublishableKey;
      await Stripe.instance.applySettings();
      print('Stripe initialized successfully');
    } catch (e) {
      print('Error initializing Stripe: $e');
    }
  }

  // Procesar depósito con tarjeta
  Future<PaymentResult> processCardDeposit({
    required double amount,
    required String currency,
    String? description,
  }) async {
    try {
      _isProcessing.value = true;

      // Validaciones
      if (amount < AppConfig.minDepositAmount) {
        return PaymentResult.error(
          'El monto mínimo de depósito es €${AppConfig.minDepositAmount}'
        );
      }

      if (amount > AppConfig.maxDepositAmount) {
        return PaymentResult.error(
          'El monto máximo de depósito es €${AppConfig.maxDepositAmount}'
        );
      }

      if (_authService.currentUser == null) {
        return PaymentResult.error('Usuario no autenticado');
      }

      // Crear Payment Intent
      final paymentIntent = await _createPaymentIntent(
        amount: amount,
        currency: currency,
        description: description ?? 'Depósito SorteosMicro',
      );

      if (paymentIntent == null) {
        return PaymentResult.error('Error creando intención de pago');
      }

      // Inicializar Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: AppConfig.appName,
          customerId: paymentIntent['customer'],
          customerEphemeralKeySecret: paymentIntent['ephemeral_key'],
          style: ThemeMode.system,
          billingDetails: BillingDetails(
            name: _authService.currentUser?.fullName,
            email: _authService.currentUser?.email,
            phone: _authService.currentUser?.phone,
          ),
        ),
      );

      // Presentar Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // Si llegamos aquí, el pago fue exitoso
      return PaymentResult.success(
        'Pago procesado exitosamente',
        paymentIntentId: paymentIntent['id'],
      );

    } on StripeException catch (e) {
      return PaymentResult.error(_getStripeErrorMessage(e));
    } catch (e) {
      return PaymentResult.error('Error inesperado: $e');
    } finally {
      _isProcessing.value = false;
    }
  }

  // Crear Payment Intent en el backend
  Future<Map<String, dynamic>?> _createPaymentIntent({
    required double amount,
    required String currency,
    required String description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.backendUrl}/create-payment-intent'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.currentUser?.id}',
        },
        body: jsonEncode({
          'amount': (amount * 100).round(), // Stripe usa centavos
          'currency': currency.toLowerCase(),
          'description': description,
          'user_id': _authService.currentUser?.id,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error creating payment intent: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating payment intent: $e');
      return null;
    }
  }

  // Procesar compra de tickets
  Future<PaymentResult> purchaseTickets({
    required String raffleId,
    required int ticketCount,
    required double totalAmount,
  }) async {
    try {
      _isProcessing.value = true;

      if (_authService.currentUser == null) {
        return PaymentResult.error('Usuario no autenticado');
      }

      // Verificar balance suficiente
      if (_authService.currentUser!.balance < totalAmount) {
        return PaymentResult.error('Saldo insuficiente');
      }

      // Procesar compra en el backend
      final response = await http.post(
        Uri.parse('${AppConfig.backendUrl}/purchase-tickets'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.currentUser?.id}',
        },
        body: jsonEncode({
          'raffle_id': raffleId,
          'ticket_count': ticketCount,
          'total_amount': totalAmount,
          'user_id': _authService.currentUser?.id,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        
        // Actualizar usuario
        await _authService.refreshUser();
        
        return PaymentResult.success(
          'Tickets comprados exitosamente',
          data: result,
        );
      } else {
        final error = jsonDecode(response.body);
        return PaymentResult.error(error['message'] ?? 'Error en la compra');
      }

    } catch (e) {
      return PaymentResult.error('Error inesperado: $e');
    } finally {
      _isProcessing.value = false;
    }
  }

  // Validar tarjeta
  Future<bool> validateCard({
    required String cardNumber,
    required String expiryDate,
    required String cvv,
  }) async {
    try {
      // Validar número de tarjeta
      if (!_isValidCardNumber(cardNumber)) {
        return false;
      }

      // Validar fecha de expiración
      if (!_isValidExpiryDate(expiryDate)) {
        return false;
      }

      // Validar CVV
      if (!_isValidCvv(cvv)) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Obtener métodos de pago guardados
  Future<List<PaymentMethod>> getSavedPaymentMethods() async {
    try {
      if (_authService.currentUser == null) {
        return [];
      }

      final response = await http.get(
        Uri.parse('${AppConfig.backendUrl}/payment-methods'),
        headers: {
          'Authorization': 'Bearer ${_authService.currentUser?.id}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['payment_methods'] as List)
            .map((pm) => PaymentMethod.fromJson(pm))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error getting saved payment methods: $e');
      return [];
    }
  }

  // Eliminar método de pago
  Future<bool> deletePaymentMethod(String paymentMethodId) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.backendUrl}/payment-methods/$paymentMethodId'),
        headers: {
          'Authorization': 'Bearer ${_authService.currentUser?.id}',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting payment method: $e');
      return false;
    }
  }

  // Obtener historial de transacciones
  Future<List<TransactionModel>> getTransactionHistory({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      if (_authService.currentUser == null) {
        return [];
      }

      final response = await http.get(
        Uri.parse('${AppConfig.backendUrl}/transactions?limit=$limit&offset=$offset'),
        headers: {
          'Authorization': 'Bearer ${_authService.currentUser?.id}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['transactions'] as List)
            .map((t) => TransactionModel.fromJson(t))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error getting transaction history: $e');
      return [];
    }
  }

  // Validaciones privadas
  bool _isValidCardNumber(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (cleanNumber.length < 13 || cleanNumber.length > 19) {
      return false;
    }
    
    // Algoritmo de Luhn
    int sum = 0;
    bool alternate = false;
    
    for (int i = cleanNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cleanNumber[i]);
      
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }
      
      sum += digit;
      alternate = !alternate;
    }
    
    return sum % 10 == 0;
  }

  bool _isValidExpiryDate(String expiryDate) {
    final parts = expiryDate.split('/');
    if (parts.length != 2) return false;
    
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    
    if (month == null || year == null) return false;
    if (month < 1 || month > 12) return false;
    
    final now = DateTime.now();
    final expiry = DateTime(2000 + year, month);
    
    return expiry.isAfter(now);
  }

  bool _isValidCvv(String cvv) {
    return cvv.length >= 3 && cvv.length <= 4 && int.tryParse(cvv) != null;
  }

  // Obtener mensaje de error de Stripe
  String _getStripeErrorMessage(StripeException error) {
    switch (error.error.code) {
      case FailureCode.Canceled:
        return 'Pago cancelado por el usuario';
      case FailureCode.Failed:
        return 'El pago falló. Intenta con otra tarjeta';
      case FailureCode.InvalidRequestError:
        return 'Solicitud inválida';
      case FailureCode.CardDeclined:
        return 'Tarjeta rechazada';
      case FailureCode.ExpiredCard:
        return 'Tarjeta expirada';
      case FailureCode.IncorrectCvc:
        return 'Código CVC incorrecto';
      case FailureCode.InsufficientFunds:
        return 'Fondos insuficientes';
      case FailureCode.ProcessingError:
        return 'Error procesando el pago';
      default:
        return error.error.localizedMessage ?? 'Error en el pago';
    }
  }
}

// Clase para resultados de pago
class PaymentResult {
  final bool success;
  final String message;
  final String? paymentIntentId;
  final Map<String, dynamic>? data;

  PaymentResult._({
    required this.success,
    required this.message,
    this.paymentIntentId,
    this.data,
  });

  factory PaymentResult.success(
    String message, {
    String? paymentIntentId,
    Map<String, dynamic>? data,
  }) =>
      PaymentResult._(
        success: true,
        message: message,
        paymentIntentId: paymentIntentId,
        data: data,
      );

  factory PaymentResult.error(String message) => PaymentResult._(
        success: false,
        message: message,
      );
}

// Modelo de transacción
class TransactionModel {
  final String id;
  final String type;
  final double amount;
  final String currency;
  final String status;
  final String description;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.status,
    required this.description,
    required this.createdAt,
    this.metadata,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      type: json['type'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      status: json['status'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      metadata: json['metadata'],
    );
  }
} 