import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/models/deposit_model.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import '../services/payment_service.dart';
import '../data/models/bank_model.dart';
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
  final RxList<BankModel> _availableBanks = <BankModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isSubmitting = false.obs;
  final RxString _selectedPaymentMethod = ''.obs;
  final RxString _selectedBankId = ''.obs;
  final Rx<File?> _selectedProofImage = Rx<File?>(null);
  final RxString _proofImageUrl = ''.obs;
  final RxDouble _depositAmount = 0.0.obs;
  final RxBool _showInstructions = false.obs;
  final RxInt _currentStep = 0.obs;
  final RxString _selectedFilter = 'all'.obs;
  final RxBool _showDepositFormView = false.obs;
  final RxBool _showDepositHistoryView = true.obs;
  final RxBool _isLoadingMore = false.obs;

  // Getters
  List<DepositModel> get deposits => _deposits;
  List<DepositModel> get pendingDeposits => 
      _deposits.where((d) => d.status == DepositStatus.pending).toList();
  List<DepositModel> get approvedDeposits => 
      _deposits.where((d) => d.status == DepositStatus.approved).toList();
  List<DepositModel> get rejectedDeposits => 
      _deposits.where((d) => d.status == DepositStatus.rejected).toList();
  
  // Bancos disponibles
  List<BankModel> get availableBanks => _availableBanks;
  String get selectedBank => _selectedBankId.value;
  
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
      .where((d) => d.status == DepositStatus.approved)
      .fold(0.0, (sum, d) => sum + d.amount);

  // Additional getters for the view
  List<DepositModel> get filteredDeposits {
    switch (_selectedFilter.value) {
      case 'pending':
        return pendingDeposits;
      case 'approved':
        return approvedDeposits;
      case 'rejected':
        return rejectedDeposits;
      case 'all':
      default:
        return _deposits;
    }
  }

  List<PaymentMethod> get availablePaymentMethods => PaymentMethod.values;
  
  bool get isLoadingMore => _isLoadingMore.value;
  String get selectedFilter => _selectedFilter.value;
  bool get showDepositForm => _showDepositFormView.value;
  bool get showDepositHistory => _showDepositHistoryView.value;
  bool get showDepositInstructions => _showInstructions.value;
  
  // User balance from auth service
  double get userBalance => _authService.currentUser?.balance ?? 0.0;
  
  // Counts
  int get pendingDepositsCount => pendingDeposits.length;
  
  // Payment method helpers
  bool get showReferenceField => 
      _selectedPaymentMethod.value == PaymentMethod.bizum.name || 
      _selectedPaymentMethod.value == PaymentMethod.transfer.name;
  
  // Form action getters
  void Function(String)? get onAmountChanged => (String value) => _validateAmount();
  void Function()? get takeProofPhoto => () => selectProofImage(fromCamera: true);
  void Function()? get submitDeposit => canSubmitDeposit ? createDepositRequest : null;
  void Function()? get managePaymentMethods => () => Get.toNamed('/payment-methods');
  void Function() get showDepositFormAction => () {
    _showDepositFormView.value = true;
    _showDepositHistoryView.value = false;
  };
  void Function() get showDepositHistoryAction => () {
    _showDepositFormView.value = false;
    _showDepositHistoryView.value = true;
  };
  
  // VoidCallback methods for the view
  void Function() get showDepositFormCallback => () {
    _showDepositFormView.value = true;
    _showDepositHistoryView.value = false;
  };
  
  void Function() get selectProofImageCallback => () => selectProofImage(fromCamera: false);
  
  void Function() get removeProofImageCallback => () => removeProofImage();
  void Function(String) get handleMenuAction => (String action) {
    switch (action) {
      case 'refresh':
        refreshDeposits();
        break;
      case 'new_deposit':
        goToNewDeposit();
        break;
      case 'filter':
        _showDepositHistoryView.value = !_showDepositHistoryView.value;
        break;
    }
  };

  @override
  void onInit() {
    super.onInit();
    loadDeposits();
    loadAvailableBanks();
  }

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
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

  // Cargar bancos disponibles
  Future<void> loadAvailableBanks() async {
    try {
      final banks = await _paymentService.getBanks();
      _availableBanks.assignAll(banks);
    } catch (e) {
      print('Error cargando bancos: $e');
      _showError('Error cargando bancos: $e');
    }
  }
  
  // Seleccionar banco
  void selectBank(BankModel bank) {
    _selectedBankId.value = bank.id;
  }
  
  // Seleccionar método de pago
  void selectPaymentMethod(PaymentMethod method) {
    _selectedPaymentMethod.value = method.name;
    
    // Mostrar instrucciones si es necesario
    if (method == PaymentMethod.bizum || method == PaymentMethod.transfer) {
      _showInstructions.value = true;
    } else {
      _showInstructions.value = false;
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
      case 'transfer':
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
  Color getDepositStatusColor(DepositStatus status) {
    switch (status) {
      case DepositStatus.pending:
        return Colors.orange;
      case DepositStatus.approved:
        return Colors.green;
      case DepositStatus.rejected:
        return Colors.red;
      case DepositStatus.cancelled:
        return Colors.grey;
    }
  }

  // Obtener texto del estado
  String getDepositStatusText(DepositStatus status) {
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

  // Obtener icono del método de pago
  IconData getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.bizum:
        return Icons.phone_android;
      case PaymentMethod.transfer:
        return Icons.account_balance;
      case PaymentMethod.paypal:
        return Icons.payment;
      default:
        return Icons.payment;
    }
  }

  // Navegar a nuevo depósito
  void goToNewDeposit() {
    _clearForm();
    // Usamos la ruta directamente para evitar problemas de null check
    Get.toNamed('/deposit-request');
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
    _selectedBankId.value = '';
    _selectedProofImage.value = null;
    _proofImageUrl.value = '';
    _depositAmount.value = 0.0;
    _showInstructions.value = false;
    _currentStep.value = 0;
  }

  // Esta función muestra mensajes de error
  // El método _showError ya está definido más arriba

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
        _selectedPaymentMethod.value == 'transfer') {
      if (value == null || value.isEmpty) {
        return 'El código de referencia es requerido';
      }
    }
    return null;
  }

  // Additional methods for the view
  void setFilter(String filter) {
    _selectedFilter.value = filter;
  }

  String getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.bizum:
        return 'Bizum';
      case PaymentMethod.transfer:
        return 'Transferencia';
      case PaymentMethod.paypal:
        return 'PayPal';
    }
  }

  String getReferenceHelperText() {
    switch (_selectedPaymentMethod.value) {
      case 'bizum':
        return 'Código que usarás como concepto en Bizum';
      case 'transfer':
        return 'Código que usarás como concepto en la transferencia';
      default:
        return 'Código de referencia del depósito';
    }
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

  void toggleDepositForm() {
    _showDepositFormView.value = !_showDepositFormView.value;
    _showDepositHistoryView.value = !_showDepositFormView.value;
  }

  void toggleDepositHistory() {
    _showDepositHistoryView.value = !_showDepositHistoryView.value;
    _showDepositFormView.value = !_showDepositHistoryView.value;
  }

  void toggleInstructions() {
    _showInstructions.value = !_showInstructions.value;
  }

  String get depositReference => _proofImageUrl.value;
} 