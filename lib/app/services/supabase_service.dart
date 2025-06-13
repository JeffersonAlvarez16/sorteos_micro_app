import 'dart:convert';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../data/models/raffle_model.dart';
import '../data/models/deposit_model.dart';
import '../data/models/user_model.dart';
import 'auth_service.dart';

class SupabaseService extends GetxService {
  static SupabaseService get to => Get.find();
  
  final SupabaseClient _client = Supabase.instance.client;
  final AuthService _authService = AuthService.to;
  
  final RxBool _isInitialized = false.obs;
  
  // Getters
  bool get isInitialized => _isInitialized.value;
  SupabaseClient get client => _client;

  Future<SupabaseService> init() async {
    _isInitialized.value = true;
    return this;
  }

  // ==================== RAFFLES ====================
  
  // Obtener sorteos activos
  Future<List<RaffleModel>> getActiveRaffles() async {
    try {
      final response = await _client
          .from('raffles')
          .select('''
            *,
            tickets:tickets(count),
            participants:tickets(user_id).user_id
          ''')
          .eq('status', 'active')
          .order('created_at', ascending: false);

      return response.map((json) => RaffleModel.fromJson(json)).toList();
    } catch (e) {
      print('Error getting active raffles: $e');
      return [];
    }
  }

  // Obtener sorteo por ID
  Future<RaffleModel?> getRaffleById(String raffleId) async {
    try {
      final response = await _client
          .from('raffles')
          .select('''
            *,
            tickets:tickets(*),
            winner:users!raffles_winner_id_fkey(*)
          ''')
          .eq('id', raffleId)
          .single();

      return RaffleModel.fromJson(response);
    } catch (e) {
      print('Error getting raffle by ID: $e');
      return null;
    }
  }

  // Obtener sorteos completados
  Future<List<RaffleModel>> getCompletedRaffles({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _client
          .from('raffles')
          .select('''
            *,
            winner:users!raffles_winner_id_fkey(*),
            tickets:tickets(count)
          ''')
          .eq('status', 'completed')
          .order('end_date', ascending: false)
          .range(offset, offset + limit - 1);

      return response.map((json) => RaffleModel.fromJson(json)).toList();
    } catch (e) {
      print('Error getting completed raffles: $e');
      return [];
    }
  }

  // Obtener tickets del usuario para un sorteo
  Future<List<String>> getUserTicketsForRaffle(String raffleId) async {
    try {
      if (_authService.currentUser == null) return [];

      final response = await _client
          .from('tickets')
          .select('ticket_number')
          .eq('raffle_id', raffleId)
          .eq('user_id', _authService.currentUser!.id);

      return response.map((ticket) => ticket['ticket_number'] as String).toList();
    } catch (e) {
      print('Error getting user tickets: $e');
      return [];
    }
  }

  // Comprar tickets
  Future<Map<String, dynamic>?> purchaseTickets({
    required String raffleId,
    required int ticketCount,
  }) async {
    try {
      if (_authService.currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Llamar función de Supabase para comprar tickets
      final response = await _client.rpc('purchase_tickets', params: {
        'p_raffle_id': raffleId,
        'p_user_id': _authService.currentUser!.id,
        'p_ticket_count': ticketCount,
      });

      return response;
    } catch (e) {
      print('Error purchasing tickets: $e');
      throw e;
    }
  }

  // Obtener estadísticas de sorteo
  Future<Map<String, dynamic>> getRaffleStats(String raffleId) async {
    try {
      final response = await _client.rpc('get_raffle_stats', params: {
        'p_raffle_id': raffleId,
      });

      return response;
    } catch (e) {
      print('Error getting raffle stats: $e');
      return {};
    }
  }

  // ==================== DEPOSITS ====================
  
  // Crear solicitud de depósito
  Future<DepositModel?> createDepositRequest({
    required double amount,
    required String paymentMethod,
    required String paymentProof,
    String? referenceCode,
  }) async {
    try {
      if (_authService.currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _client
          .from('deposits')
          .insert({
            'user_id': _authService.currentUser!.id,
            'amount': amount,
            'payment_method': paymentMethod,
            'payment_proof': paymentProof,
            'reference_code': referenceCode ?? _generateReferenceCode(),
            'status': 'pending',
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return DepositModel.fromJson(response);
    } catch (e) {
      print('Error creating deposit request: $e');
      return null;
    }
  }

  // Obtener depósitos del usuario
  Future<List<DepositModel>> getUserDeposits({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      if (_authService.currentUser == null) return [];

      final response = await _client
          .from('deposits')
          .select('*')
          .eq('user_id', _authService.currentUser!.id)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.map((json) => DepositModel.fromJson(json)).toList();
    } catch (e) {
      print('Error getting user deposits: $e');
      return [];
    }
  }

  // Subir comprobante de pago
  Future<String?> uploadPaymentProof(String filePath, String fileName) async {
    try {
      if (_authService.currentUser == null) return null;

      final file = await _client.storage
          .from('payment-proofs')
          .upload('${_authService.currentUser!.id}/$fileName', filePath);

      return _client.storage
          .from('payment-proofs')
          .getPublicUrl('${_authService.currentUser!.id}/$fileName');
    } catch (e) {
      print('Error uploading payment proof: $e');
      return null;
    }
  }

  // ==================== USER STATS ====================
  
  // Obtener estadísticas del usuario
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      if (_authService.currentUser == null) return {};

      final response = await _client
          .from('user_stats')
          .select('*')
          .eq('user_id', _authService.currentUser!.id)
          .single();

      return response;
    } catch (e) {
      print('Error getting user stats: $e');
      return {};
    }
  }

  // Obtener historial de participaciones
  Future<List<Map<String, dynamic>>> getUserParticipationHistory({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      if (_authService.currentUser == null) return [];

      final response = await _client
          .from('tickets')
          .select('''
            *,
            raffle:raffles(*)
          ''')
          .eq('user_id', _authService.currentUser!.id)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response;
    } catch (e) {
      print('Error getting participation history: $e');
      return [];
    }
  }

  // Obtener historial de ganancias
  Future<List<Map<String, dynamic>>> getUserWinnings({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      if (_authService.currentUser == null) return [];

      final response = await _client
          .from('raffles')
          .select('''
            *,
            winning_ticket:tickets!raffles_winning_ticket_id_fkey(*)
          ''')
          .eq('winner_id', _authService.currentUser!.id)
          .order('end_date', ascending: false)
          .range(offset, offset + limit - 1);

      return response;
    } catch (e) {
      print('Error getting user winnings: $e');
      return [];
    }
  }

  // ==================== NOTIFICATIONS ====================
  
  // Obtener notificaciones del usuario
  Future<List<Map<String, dynamic>>> getUserNotifications({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      if (_authService.currentUser == null) return [];

      final response = await _client
          .from('notifications')
          .select('*')
          .eq('user_id', _authService.currentUser!.id)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response;
    } catch (e) {
      print('Error getting user notifications: $e');
      return [];
    }
  }

  // Marcar notificación como leída
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);

      return true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // ==================== REAL-TIME SUBSCRIPTIONS ====================
  
  // Suscribirse a cambios en sorteos activos
  RealtimeChannel subscribeToActiveRaffles(Function(List<RaffleModel>) onUpdate) {
    return _client
        .channel('active_raffles')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'raffles',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'status',
            value: 'active',
          ),
          callback: (payload) async {
            final raffles = await getActiveRaffles();
            onUpdate(raffles);
          },
        )
        .subscribe();
  }

  // Suscribirse a cambios en un sorteo específico
  RealtimeChannel subscribeToRaffle(String raffleId, Function(RaffleModel?) onUpdate) {
    return _client
        .channel('raffle_$raffleId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'raffles',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: raffleId,
          ),
          callback: (payload) async {
            final raffle = await getRaffleById(raffleId);
            onUpdate(raffle);
          },
        )
        .subscribe();
  }

  // Suscribirse a tickets de un sorteo
  RealtimeChannel subscribeToRaffleTickets(String raffleId, Function() onUpdate) {
    return _client
        .channel('raffle_tickets_$raffleId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'tickets',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'raffle_id',
            value: raffleId,
          ),
          callback: (payload) => onUpdate(),
        )
        .subscribe();
  }

  // Suscribirse a depósitos del usuario
  RealtimeChannel subscribeToUserDeposits(Function() onUpdate) {
    if (_authService.currentUser == null) {
      throw Exception('Usuario no autenticado');
    }

    return _client
        .channel('user_deposits')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'deposits',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: _authService.currentUser!.id,
          ),
          callback: (payload) => onUpdate(),
        )
        .subscribe();
  }

  // ==================== UTILITY METHODS ====================
  
  // Generar código de referencia único
  String _generateReferenceCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'DEP$random';
  }

  // Ejecutar función RPC personalizada
  Future<dynamic> callFunction(String functionName, Map<String, dynamic> params) async {
    try {
      return await _client.rpc(functionName, params: params);
    } catch (e) {
      print('Error calling function $functionName: $e');
      throw e;
    }
  }

  // Obtener URL pública de archivo
  String getPublicUrl(String bucket, String path) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  // Verificar conectividad
  Future<bool> checkConnection() async {
    try {
      await _client.from('raffles').select('id').limit(1);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Limpiar suscripciones
  void removeAllSubscriptions() {
    _client.removeAllChannels();
  }
} 