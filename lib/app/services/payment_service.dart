import 'dart:convert';

import 'package:flutter_stripe/flutter_stripe.dart' hide PaymentMethod;
import 'package:flutter_stripe/flutter_stripe.dart' as stripe show PaymentMethod;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../data/models/deposit_model.dart';
import '../data/models/bank_model.dart';
import 'auth_service.dart';

class PaymentService extends GetxService {
  static PaymentService get to => Get.find();
  
  final AuthService _authService = AuthService.to;
  
  final RxBool _isInitialized = false.obs;
  final RxBool _isProcessing = false.obs;
  
  // Observables para métodos de pago y bancos
  final RxList<Map<String, dynamic>> _userPaymentMethods = <Map<String, dynamic>>[].obs;
  final RxList<BankModel> _availableBanks = <BankModel>[].obs;
  
  // Getters
  bool get isInitialized => _isInitialized.value;
  bool get isProcessing => _isProcessing.value;
  List<Map<String, dynamic>> get userPaymentMethods => _userPaymentMethods.toList();
  List<BankModel> get availableBanks => _availableBanks.toList();

  Future<PaymentService> init() async {
    await _initializeStripe();
    _isInitialized.value = true;
    
    // Cargar métodos de pago guardados del usuario si está autenticado
    if (_authService.isAuthenticated) {
      await loadUserPaymentMethods();
      await loadAvailableBanks();
    }
    
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
            .map((pm) => PaymentMethod.values.firstWhere(
                (e) => e.name == pm,
                orElse: () => PaymentMethod.bizum,
              ))
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
  String _getStripeErrorMessage(StripeException e) {
    switch (e.error.code) {
      case FailureCode.Canceled:
        return 'Operación cancelada por el usuario';
      case FailureCode.Failed:
        return 'Error en el procesamiento del pago';
      case FailureCode.Timeout:
        return 'La operación ha expirado';
      default:
        return e.error.localizedMessage ?? 'Error desconocido';
    }
  }
  
  // ===== MÉTODOS DE PAGO =====
  
  // Cargar métodos de pago del usuario
  Future<List<Map<String, dynamic>>> loadUserPaymentMethods() async {
    if (!_authService.isAuthenticated) {
      return [];
    }
    
    try {
      // En un caso real, esto se cargaría desde el backend
      // Por ahora, simulamos datos de ejemplo
      await Future.delayed(const Duration(milliseconds: 800)); // Simular carga
      
      // Cargar métodos guardados (en una app real, esto vendría de la base de datos)
      final List<Map<String, dynamic>> methods = [
        {
          'id': '1',
          'type': 'card',
          'last4': '4242',
          'brand': 'visa',
          'exp_month': 12,
          'exp_year': 2025,
          'card_holder': 'Usuario Demo',
          'is_default': true,
          'created_at': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        },
        {
          'id': '2',
          'type': 'bank',
          'bank_name': 'Santander',
          'account_holder': 'Usuario Demo',
          'last4': '6789',
          'is_default': false,
          'created_at': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
        },
      ];
      
      _userPaymentMethods.value = methods;
      return methods;
    } catch (e) {
      print('Error loading payment methods: $e');
      return [];
    }
  }
  
  // Obtener métodos de pago del usuario (para el controlador)
  Future<List<Map<String, dynamic>>> getUserPaymentMethods() async {
    if (_userPaymentMethods.isEmpty) {
      return await loadUserPaymentMethods();
    }
    return _userPaymentMethods.toList();
  }
  
  // Agregar un nuevo método de pago
  Future<bool> addPaymentMethod({
    required String type,
    required Map<String, dynamic> data,
  }) async {
    try {
      if (!_authService.isAuthenticated) {
        return false;
      }
      
      // Simular procesamiento
      await Future.delayed(const Duration(milliseconds: 800));
      
      // En una app real, esto se enviaría al backend
      final newMethod = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': type,
        'is_default': _userPaymentMethods.isEmpty, // Si es el primero, será el predeterminado
        'created_at': DateTime.now().toIso8601String(),
        ...data,
      };
      
      // Si es una tarjeta, agregar datos simulados
      if (type == 'card') {
        final cardNumber = data['card_number'] as String? ?? '';
        if (cardNumber.isNotEmpty) {
          newMethod['last4'] = cardNumber.replaceAll(' ', '').substring(cardNumber.length - 4);
        } else {
          newMethod['last4'] = '0000';
        }
      }
      
      _userPaymentMethods.add(newMethod);
      return true;
    } catch (e) {
      print('Error adding payment method: $e');
      return false;
    }
  }
  
  // Obtener bancos disponibles para depósitos
  Future<List<BankModel>> getBanks() async {
    try {
      if (_availableBanks.isNotEmpty) {
        return _availableBanks.toList();
      }
      
      await loadAvailableBanks();
      return _availableBanks.toList();
    } catch (e) {
      print('Error obteniendo bancos: $e');
      return [];
    }
  }
  
  // Cargar bancos disponibles
  Future<void> loadAvailableBanks() async {
    try {
      if (!_authService.isAuthenticated) return;
      
      // Aquí normalmente se haría una llamada al backend para obtener los bancos
      // Por ahora simulamos una respuesta con datos de prueba
      await Future.delayed(const Duration(milliseconds: 800));
      
      final List<BankModel> banks = [
        BankModel(
          id: 'bank_1',
          name: 'Banco Santander',
          accountNumber: '0049 1234 56 7890123456',
          owner: 'SorteosMicro S.L.',
          logoUrl: 'https://example.com/logos/santander.png',
        ),
        BankModel(
          id: 'bank_2',
          name: 'BBVA',
          accountNumber: '0182 1234 56 7890123456',
          owner: 'SorteosMicro S.L.',
          logoUrl: 'https://example.com/logos/bbva.png',
        ),
        BankModel(
          id: 'bank_3',
          name: 'CaixaBank',
          accountNumber: '2100 1234 56 7890123456',
          owner: 'SorteosMicro S.L.',
          logoUrl: 'https://example.com/logos/caixabank.png',
        ),
        BankModel(
          id: 'bank_4',
          name: 'Sabadell',
          accountNumber: '0081 1234 56 7890123456',
          owner: 'SorteosMicro S.L.',
          logoUrl: 'https://example.com/logos/sabadell.png',
        ),
      ];
      
      _availableBanks.assignAll(banks);
    } catch (e) {
      print('Error cargando bancos: $e');
    }
  }
  
  // Eliminar un método de pago
  Future<bool> removePaymentMethod(String id) async {
    try {
      if (!_authService.isAuthenticated) {
        return false;
      }
      
      // Simular procesamiento
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Buscar el método a eliminar
      final methodIndex = _userPaymentMethods.indexWhere((m) => m['id'] == id);
      if (methodIndex == -1) {
        return false;
      }
      
      // Verificar si es el método predeterminado
      final isDefault = _userPaymentMethods[methodIndex]['is_default'] ?? false;
      
      // Eliminar el método
      _userPaymentMethods.removeAt(methodIndex);
      
      // Si era el predeterminado y hay otros métodos, establecer uno nuevo como predeterminado
      if (isDefault && _userPaymentMethods.isNotEmpty) {
        _userPaymentMethods[0]['is_default'] = true;
      }
      
      return true;
    } catch (e) {
      print('Error removing payment method: $e');
      return false;
    }
  }
  
  // Establecer un método de pago como predeterminado
  Future<bool> setDefaultPaymentMethod(String id) async {
    try {
      if (!_authService.isAuthenticated) {
        return false;
      }
      
      // Simular procesamiento
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Buscar el método a establecer como predeterminado
      final methodIndex = _userPaymentMethods.indexWhere((m) => m['id'] == id);
      if (methodIndex == -1) {
        return false;
      }
      
      // Quitar la marca de predeterminado de todos los métodos
      for (final method in _userPaymentMethods) {
        method['is_default'] = false;
      }
      
      // Establecer el nuevo método predeterminado
      _userPaymentMethods[methodIndex]['is_default'] = true;
      
      // Actualizar la lista para reflejar los cambios
      _userPaymentMethods.refresh();
      
      return true;
    } catch (e) {
      print('Error setting default payment method: $e');
      return false;
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