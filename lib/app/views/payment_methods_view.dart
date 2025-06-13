import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/payment_methods_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_state_widget.dart';

class PaymentMethodsView extends GetView<PaymentMethodsController> {
  const PaymentMethodsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Métodos de Pago'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade800,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.paymentMethods.isEmpty) {
          return const LoadingWidget(message: 'Cargando métodos de pago...');
        }
        
        if (controller.isAddingMethod.value) {
          return _buildAddMethodForm(theme);
        }
        
        return _buildMethodsList(theme);
      }),
      floatingActionButton: Obx(() {
        if (controller.isAddingMethod.value) return const SizedBox.shrink();
        
        return FloatingActionCustomButton(
          onPressed: () => _showAddMethodDialog(context),
          icon: Icons.add,
          tooltip: 'Agregar método de pago',
          backgroundColor: Colors.grey.shade800,
        );
      }),
    );
  }
  
  Widget _buildMethodsList(ThemeData theme) {
    return Obx(() {
      if (controller.paymentMethods.isEmpty) {
        return EmptyStateWidget(
          icon: Icons.payment_outlined,
          title: 'No hay métodos de pago',
          message: 'Agrega tu primer método de pago para realizar depósitos',
          buttonText: 'Agregar método',
          onButtonPressed: () => _showAddMethodDialog(Get.context!),
        );
      }
      
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: controller.paymentMethods.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final method = controller.paymentMethods[index];
          return _buildPaymentMethodCard(method, theme);
        },
      );
    });
  }
  
  Widget _buildPaymentMethodCard(Map<String, dynamic> method, ThemeData theme) {
    final bool isDefault = method['is_default'] ?? false;
    final String methodType = method['type'] ?? '';
    
    IconData methodIcon;
    String methodTitle;
    
    switch (methodType.toLowerCase()) {
      case 'card':
        methodIcon = Icons.credit_card;
        methodTitle = 'Tarjeta terminada en ${method['last4'] ?? ''}';
        break;
      case 'bank':
        methodIcon = Icons.account_balance;
        methodTitle = 'Cuenta bancaria ${method['bank_name'] ?? ''}';
        break;
      case 'paypal':
        methodIcon = Icons.paypal;
        methodTitle = 'PayPal: ${method['email'] ?? ''}';
        break;
      case 'bizum':
        methodIcon = Icons.smartphone;
        methodTitle = 'Bizum: ${method['phone'] ?? ''}';
        break;
      default:
        methodIcon = Icons.payment;
        methodTitle = 'Método de pago';
    }
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(methodIcon, color: Colors.grey.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        methodTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      if (method['description'] != null)
                        Text(
                          method['description'],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Predeterminado',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isDefault)
                  TextButton(
                    onPressed: () => controller.setDefaultPaymentMethod(method['id']),
                    child: Text(
                      'Establecer como predeterminado',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _confirmDeleteMethod(method['id']),
                  icon: Icon(Icons.delete_outline, color: Colors.grey.shade600),
                  tooltip: 'Eliminar método',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showAddMethodDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Agregar método de pago',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 24),
              _buildMethodOption(
                context,
                'Tarjeta de crédito/débito',
                Icons.credit_card,
                () {
                  Get.back();
                  controller.startAddingMethod('card');
                },
              ),
              const SizedBox(height: 16),
              _buildMethodOption(
                context,
                'Cuenta bancaria',
                Icons.account_balance,
                () {
                  Get.back();
                  controller.startAddingMethod('bank');
                },
              ),
              const SizedBox(height: 16),
              _buildMethodOption(
                context,
                'PayPal',
                Icons.paypal,
                () {
                  Get.back();
                  controller.startAddingMethod('paypal');
                },
              ),
              const SizedBox(height: 16),
              _buildMethodOption(
                context,
                'Bizum',
                Icons.smartphone,
                () {
                  Get.back();
                  controller.startAddingMethod('bizum');
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildMethodOption(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade700),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAddMethodForm(ThemeData theme) {
    final methodType = controller.selectedMethodType.value;
    String title;
    List<Widget> formFields;
    
    switch (methodType) {
      case 'card':
        title = 'Agregar tarjeta';
        formFields = _buildCardForm(theme);
        break;
      case 'bank':
        title = 'Agregar cuenta bancaria';
        formFields = _buildBankForm(theme);
        break;
      case 'paypal':
        title = 'Agregar PayPal';
        formFields = _buildPaypalForm(theme);
        break;
      case 'bizum':
        title = 'Agregar Bizum';
        formFields = _buildBizumForm(theme);
        break;
      default:
        title = 'Agregar método de pago';
        formFields = [];
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 24),
          ...formFields,
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Cancelar',
                  onPressed: controller.cancelAddingMethod,
                  type: ButtonType.flat,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Guardar',
                  onPressed: controller.savePaymentMethod,
                  type: ButtonType.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  List<Widget> _buildCardForm(ThemeData theme) {
    return [
      _buildTextField(
        label: 'Nombre en la tarjeta',
        hint: 'Nombre como aparece en la tarjeta',
        icon: Icons.person_outline,
        onChanged: (value) => controller.updateFormField('card_holder', value),
      ),
      const SizedBox(height: 16),
      _buildTextField(
        label: 'Número de tarjeta',
        hint: 'XXXX XXXX XXXX XXXX',
        icon: Icons.credit_card,
        onChanged: (value) => controller.updateFormField('card_number', value),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _buildTextField(
              label: 'Fecha de expiración',
              hint: 'MM/AA',
              icon: Icons.calendar_today,
              onChanged: (value) => controller.updateFormField('expiry', value),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildTextField(
              label: 'CVV',
              hint: '123',
              icon: Icons.lock_outline,
              onChanged: (value) => controller.updateFormField('cvv', value),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      _buildTextField(
        label: 'Descripción (opcional)',
        hint: 'Ej: Tarjeta personal',
        icon: Icons.description_outlined,
        onChanged: (value) => controller.updateFormField('description', value),
      ),
    ];
  }
  
  List<Widget> _buildBankForm(ThemeData theme) {
    return [
      _buildTextField(
        label: 'Nombre del banco',
        hint: 'Ej: Santander, BBVA',
        icon: Icons.account_balance,
        onChanged: (value) => controller.updateFormField('bank_name', value),
      ),
      const SizedBox(height: 16),
      _buildTextField(
        label: 'Titular de la cuenta',
        hint: 'Nombre completo del titular',
        icon: Icons.person_outline,
        onChanged: (value) => controller.updateFormField('account_holder', value),
      ),
      const SizedBox(height: 16),
      _buildTextField(
        label: 'IBAN',
        hint: 'ESXX XXXX XXXX XXXX XXXX',
        icon: Icons.account_balance_wallet,
        onChanged: (value) => controller.updateFormField('iban', value),
      ),
      const SizedBox(height: 16),
      _buildTextField(
        label: 'Descripción (opcional)',
        hint: 'Ej: Cuenta principal',
        icon: Icons.description_outlined,
        onChanged: (value) => controller.updateFormField('description', value),
      ),
    ];
  }
  
  List<Widget> _buildPaypalForm(ThemeData theme) {
    return [
      _buildTextField(
        label: 'Correo electrónico de PayPal',
        hint: 'tu.email@ejemplo.com',
        icon: Icons.email_outlined,
        onChanged: (value) => controller.updateFormField('email', value),
      ),
      const SizedBox(height: 16),
      _buildTextField(
        label: 'Descripción (opcional)',
        hint: 'Ej: PayPal personal',
        icon: Icons.description_outlined,
        onChanged: (value) => controller.updateFormField('description', value),
      ),
    ];
  }
  
  List<Widget> _buildBizumForm(ThemeData theme) {
    return [
      _buildTextField(
        label: 'Número de teléfono',
        hint: '600 123 456',
        icon: Icons.phone_outlined,
        onChanged: (value) => controller.updateFormField('phone', value),
      ),
      const SizedBox(height: 16),
      _buildTextField(
        label: 'Nombre completo',
        hint: 'Nombre y apellidos',
        icon: Icons.person_outline,
        onChanged: (value) => controller.updateFormField('name', value),
      ),
      const SizedBox(height: 16),
      _buildTextField(
        label: 'Descripción (opcional)',
        hint: 'Ej: Bizum personal',
        icon: Icons.description_outlined,
        onChanged: (value) => controller.updateFormField('description', value),
      ),
    ];
  }
  
  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(icon, color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.grey.shade50,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
      ],
    );
  }
  
  void _confirmDeleteMethod(String id) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Eliminar método de pago',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este método de pago? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey.shade700)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deletePaymentMethod(id);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
