import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/models/deposit_model.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import '../services/payment_service.dart';
import '../config/app_config.dart';

class DepositController extends GetxController {
  static DepositController get to => Get.find();

  // Services
  final AuthService _authService = AuthService.to;
  final SupabaseService _supabaseService = SupabaseService.to;
  final PaymentService _paymentService = PaymentService.to;
  final ImagePicker _imagePicker = ImagePicker();

  // Form controllers
  final TextEditingController amountController = TextEditingController();
  final TextEditingController referenceController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // Form key
  final GlobalKey<FormState> depositFormKey = GlobalKey<FormState>();

  // Observable variables
  final RxList<DepositModel> _deposits = <DepositModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isSubmitting = false.obs;
  final RxString _selectedPaymentMethod = ''.obs;
  final Rx<File?> _selectedProofImage = Rx<File?>(null);
  final RxString _proofImageUrl = ''.obs;
  final RxDouble _depositAmount = 0.0.obs;
  final RxBool _showInstructions = false.obs;
  final RxInt _currentStep = 0.obs;

  // Getters
  List<DepositModel> get deposits => _deposits;
  List<DepositModel> get pendingDeposits => 
      _deposits.where((d) => d.status == 'pending').toList();
  List<DepositModel> get approvedDeposits => 
      _deposits.where((d) => d.status == 'approved').toList();
  List<DepositModel> get rejectedDeposits => 
      _deposits.where((d) => d.status == 'rejected').toList();
  
  bool get isLoading => _isLoading.value;
  bool get isSubmitting => _isSubmitting.value;
  String get selectedPaymentMethod => _selectedPaymentMethod.value;
  File? get selectedProofImage => _selectedProofImage.value;
  String get proofImageUrl => _proofImageUrl.value;
  double get depositAmount => _depositAmount.value;
  bool get showInstructions => _showInstructions.value;
  int get currentStep => _currentStep.value;
  
  bool get canSubmitDeposit => 
      _selectedPaymentMethod.value.isNotEmpty &&
      _depositAmount.value >= AppConfig.minDepositAmount &&
      _depositAmount.value <= AppConfig.maxDepositAmount &&
      (_selectedProofImage.value != null || _proofImageUrl.value.isNotEmpty) &&
      !_isSubmitting.value;

  double get totalDeposited => _deposits
      .where((d) => d.status == 'approved')
      .fold(0.0, (sum, d) => sum + d.amount);

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  // Inicializar controlador
  Future<void> _initializeController() async {
    await loadDeposits();
    
    // Configurar listeners
    amountController.addListener(_validateAmount);
  }

  // Liberar controladores
  void _disposeControllers() {
    amountController.dispose();
    referenceController.dispose();
    notesController.dispose();
  }

  // Cargar depósitos del usuario
  Future<void> loadDeposits() async {
    try {
      _isLoading.value = true;
      final deposits = await _supabaseService.getUserDeposits();
      _deposits.assignAll(deposits);
    } catch (e) {
      _showError('Error cargando depósitos: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Refrescar depósitos
  Future<void> refreshDeposits() async {
    await loadDeposits();
  }

  // Seleccionar método de pago
  void selectPaymentMethod(String method) {
    _selectedPaymentMethod.value = method;
    _showInstructions.value = true;
    _currentStep.value = 1;
    
    // Generar código de referencia automático para algunos métodos
    if (method == 'bizum' || method == 'bank_transfer') {
      referenceController.text = _generateReferenceCode();
    }
  }

  // Validar monto en tiempo real
  void _validateAmount() {
    final amount = double.tryParse(amountController.text) ?? 0.0;
    _depositAmount.value = amount;
  }

  // Seleccionar imagen de comprobante
  Future<void> selectProofImage({bool fromCamera = false}) async {
    try {
      // Solicitar permisos
      final permission = fromCamera ? Permission.camera : Permission.photos;
      final status = await permission.request();
      
      if (!status.isGranted) {
        _showError('Permisos necesarios no concedidos');
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedProofImage.value = File(image.path);
        _currentStep.value = 2;
      }
    } catch (e) {
      _showError('Error seleccionando imagen: $e');
    }
  }

  // Remover imagen seleccionada
  void removeProofImage() {
    _selectedProofImage.value = null;
    _proofImageUrl.value = '';
  }

  // Crear solicitud de depósito
  Future<void> createDepositRequest() async {
    if (!depositFormKey.currentState!.validate()) return;
    if (!canSubmitDeposit) return;

    try {
      _isSubmitting.value = true;

      // Subir comprobante de pago
      String? proofUrl;
      if (_selectedProofImage.value != null) {
        final fileName = 'proof_${DateTime.now().millisecondsSinceEpoch}.jpg';
        proofUrl = await _supabaseService.uploadPaymentProof(
          _selectedProofImage.value!.path,
          fileName,
        );

        if (proofUrl == null) {
          _showError('Error subiendo comprobante');
          return;
        }
      }

      // Crear solicitud
      final deposit = await _supabaseService.createDepositRequest(
        amount: _depositAmount.value,
        paymentMethod: _selectedPaymentMethod.value,
        paymentProof: proofUrl ?? _proofImageUrl.value,
        referenceCode: referenceController.text.trim(),
      );

      if (deposit != null) {
        _showSuccess('Solicitud de depósito enviada exitosamente');
        _clearForm();
        await loadDeposits();
        Get.back(); // Cerrar pantalla de nuevo depósito
      } else {
        _showError('Error creando solicitud de depósito');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      _isSubmitting.value = false;
    }
  }

  // Procesar depósito con tarjeta (Stripe)
  Future<void> processCardDeposit() async {
    if (!depositFormKey.currentState!.validate()) return;

    try {
      _isSubmitting.value = true;

      final result = await _paymentService.processCardDeposit(
        amount: _depositAmount.value,
        currency: 'eur',
        description: 'Depósito SorteosMicro - €${_depositAmount.value}',
      );

      if (result.success) {
        _showSuccess(result.message);
        await _authService.refreshUser();
        await loadDeposits();
        _clearForm();
        Get.back();
      } else {
        _showError(result.message);
      }
    } catch (e) {
      _showError('Error procesando pago: $e');
    } finally {
      _isSubmitting.value = false;
    }
  }

  // Obtener instrucciones de pago
  String getPaymentInstructions(String method) {
    switch (method) {
      case 'bizum':
        return '''
1. Abre tu app de Bizum
2. Envía €${_depositAmount.value} al número: ${AppConfig.bizumNumber}
3. Usa como concepto: ${referenceController.text}
4. Haz captura del comprobante
5. Súbela aquí para verificación
        ''';
      case 'bank_transfer':
        return '''
1. Realiza transferencia a:
   IBAN: ${AppConfig.bankIban}
   Titular: ${AppConfig.bankAccountName}
2. Importe: €${_depositAmount.value}
3. Concepto: ${referenceController.text}
4. Sube el comprobante bancario
        ''';
      case 'paypal':
        return '''
1. Envía €${_depositAmount.value} a: ${AppConfig.paypalEmail}
2. Selecciona "Enviar a amigos y familiares"
3. Usa como nota: ${referenceController.text}
4. Haz captura del comprobante
        ''';
      default:
        return 'Selecciona un método de pago para ver las instrucciones';
    }
  }

  // Obtener estado del depósito con color
  Color getDepositStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Obtener texto del estado
  String getDepositStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'approved':
        return 'Aprobado';
      case 'rejected':
        return 'Rechazado';
      default:
        return 'Desconocido';
    }
  }

  // Obtener icono del método de pago
  IconData getPaymentMethodIcon(String method) {
    switch (method) {
      case 'bizum':
        return Icons.phone_android;
      case 'bank_transfer':
        return Icons.account_balance;
      case 'paypal':
        return Icons.payment;
      case 'card':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

  // Navegar a nuevo depósito
  void goToNewDeposit() {
    _clearForm();
    Get.toNamed('/new-deposit');
  }

  // Ver detalles del depósito
  void viewDepositDetails(DepositModel deposit) {
    Get.toNamed('/deposit-detail', arguments: {'deposit': deposit});
  }

  // Limpiar formulario
  void _clearForm() {
    amountController.clear();
    referenceController.clear();
    notesController.clear();
    _selectedPaymentMethod.value = '';
    _selectedProofImage.value = null;
    _proofImageUrl.value = '';
    _depositAmount.value = 0.0;
    _showInstructions.value = false;
    _currentStep.value = 0;
  }

  // Generar código de referencia
  String _generateReferenceCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'DEP$random';
  }

  // Validadores
  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'El monto es requerido';
    }
    
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Ingresa un monto válido';
    }
    
    if (amount < AppConfig.minDepositAmount) {
      return 'Monto mínimo: €${AppConfig.minDepositAmount}';
    }
    
    if (amount > AppConfig.maxDepositAmount) {
      return 'Monto máximo: €${AppConfig.maxDepositAmount}';
    }
    
    return null;
  }

  String? validateReference(String? value) {
    if (_selectedPaymentMethod.value == 'bizum' || 
        _selectedPaymentMethod.value == 'bank_transfer') {
      if (value == null || value.isEmpty) {
        return 'El código de referencia es requerido';
      }
    }
    return null;
  }

  // Métodos de utilidad
  void _showSuccess(String message) {
    Get.snackbar(
      'Éxito',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }
} 