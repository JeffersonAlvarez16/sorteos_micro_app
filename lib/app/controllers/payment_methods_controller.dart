import 'package:get/get.dart';
import '../services/payment_service.dart';

class PaymentMethodsController extends GetxController {
  static PaymentMethodsController get to => Get.find();

  // Services
  final PaymentService _paymentService = PaymentService.to;

  // Observables
  final RxList<Map<String, dynamic>> paymentMethods = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isAddingMethod = false.obs;

  // Form
  final RxString selectedMethodType = ''.obs;
  final RxMap<String, dynamic> formData = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadPaymentMethods();
  }

  // Methods
  Future<void> loadPaymentMethods() async {
    isLoading.value = true;
    try {
      final methods = await _paymentService.getUserPaymentMethods();
      paymentMethods.value = methods;
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar los métodos de pago: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void startAddingMethod(String methodType) {
    selectedMethodType.value = methodType;
    formData.clear();
    isAddingMethod.value = true;
  }

  void cancelAddingMethod() {
    isAddingMethod.value = false;
    selectedMethodType.value = '';
    formData.clear();
  }

  Future<void> savePaymentMethod() async {
    if (formData.isEmpty || selectedMethodType.isEmpty) {
      Get.snackbar(
        'Error',
        'Por favor completa todos los campos requeridos',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      await _paymentService.addPaymentMethod(
        type: selectedMethodType.value,
        data: formData,
      );
      
      // Refresh the list
      await loadPaymentMethods();
      
      // Reset form
      cancelAddingMethod();
      
      Get.snackbar(
        'Éxito',
        'Método de pago agregado correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo guardar el método de pago: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePaymentMethod(String id) async {
    isLoading.value = true;
    try {
      await _paymentService.removePaymentMethod(id);
      await loadPaymentMethods();
      
      Get.snackbar(
        'Éxito',
        'Método de pago eliminado correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar el método de pago: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setDefaultPaymentMethod(String id) async {
    isLoading.value = true;
    try {
      await _paymentService.setDefaultPaymentMethod(id);
      await loadPaymentMethods();
      
      Get.snackbar(
        'Éxito',
        'Método de pago predeterminado actualizado',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar el método de pago predeterminado: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Form handling
  void updateFormField(String key, dynamic value) {
    formData[key] = value;
  }
}
