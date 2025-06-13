import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/deposit_controller.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
// import '../widgets/loading_widget.dart'; // No es necesario por ahora

class NewDepositView extends GetView<DepositController> {
  const NewDepositView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Nuevo Depósito'),
       backgroundColor: Colors.white,
      foregroundColor: Colors.grey.shade800,
      elevation: 5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.depositFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información del depósito
              _buildDepositInfo(theme),
              
              const SizedBox(height: 24),
              
              // Selección del banco
              _buildBankSelection(theme),
              
              const SizedBox(height: 24),
              
              // Método de pago
              _buildPaymentMethodSection(theme),
              
              const SizedBox(height: 24),
              
              // Monto
              _buildAmountSection(theme),
              
              const SizedBox(height: 24),
              
              // Referencia (si es necesaria)
              _buildReferenceSection(theme),
              
              const SizedBox(height: 24),
              
              // Comprobante de pago
              _buildProofSection(theme),
              
              const SizedBox(height: 24),
              
              // Notas adicionales
              _buildNotesSection(theme),
              
              const SizedBox(height: 32),
              
              // Botones de acción
              _buildActionButtons(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDepositInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Información importante',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Los depósitos se procesan en un máximo de 24 horas\n'
            '• El monto mínimo es \$10.00\n'
            '• Asegúrate de adjuntar el comprobante de pago\n'
            '• Usa la referencia proporcionada para identificar tu depósito',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankSelection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona el banco',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Wrap(
          spacing: 12,
          runSpacing: 8,
          children: controller.availableBanks.map((bank) {
            final isSelected = controller.selectedBank == bank.id;
            return ChoiceChip(
              label: Text(bank.name),
              selected: isSelected,
              onSelected: (_) => controller.selectBank(bank),
              avatar: isSelected 
                ? Icon(
                    Icons.check_circle,
                    size: 18,
                    color: theme.colorScheme.onPrimary,
                  )
                : null,
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected 
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
              ),
            );
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildPaymentMethodSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Método de pago',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Wrap(
          spacing: 12,
          runSpacing: 8,
          children: controller.availablePaymentMethods.map((method) {
            final isSelected = controller.selectedPaymentMethod == method.name;
            return ChoiceChip(
              label: Text(controller.getPaymentMethodName(method)),
              selected: isSelected,
              onSelected: (_) => controller.selectPaymentMethod(method),
              avatar: Icon(
                controller.getPaymentMethodIcon(method),
                size: 18,
                color: isSelected 
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
              ),
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected 
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
              ),
            );
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildAmountSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monto a depositar',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: controller.amountController,
          label: 'Monto',
          hint: '10.00',
          prefixIcon: Icons.attach_money,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          validator: controller.validateAmount,
          onChanged: controller.onAmountChanged,
        ),
        const SizedBox(height: 8),
        Obx(() => controller.depositAmount > 0
          ? Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calculate,
                    color: theme.colorScheme.secondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recibirás: \$${controller.depositAmount.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildReferenceSection(ThemeData theme) {
    return Obx(() => controller.showReferenceField
      ? CustomTextField(
          controller: controller.referenceController,
          label: 'Referencia de pago',
          hint: 'Código de referencia o número de transacción',
          prefixIcon: Icons.tag,
          validator: controller.validateReference,
          helperText: controller.getReferenceHelperText(),
        )
      : const SizedBox.shrink());
  }

  Widget _buildProofSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comprobante de pago',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => controller.selectedProofImage != null
          ? _buildSelectedProof(theme)
          : _buildProofSelector(theme)),
      ],
    );
  }

  Widget _buildSelectedProof(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.image,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comprobante seleccionado',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Imagen adjunta correctamente',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: controller.removeProofImage,
            icon: Icon(
              Icons.close,
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProofSelector(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Tomar foto',
            onPressed: controller.takeProofPhoto,
            type: ButtonType.outlined,
            icon: Icons.camera_alt,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            text: 'Seleccionar imagen',
            onPressed: controller.selectProofImageCallback,
            type: ButtonType.outlined,
            icon: Icons.photo_library,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notas adicionales (opcional)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: controller.notesController,
          label: 'Información adicional',
          hint: 'Información adicional sobre el depósito...',
          maxLines: 3,
          prefixIcon: Icons.note,
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        Obx(() => CustomButton(
          text: 'Crear depósito',
          onPressed: controller.canSubmitDeposit 
            ? controller.submitDeposit 
            : null,
          isLoading: controller.isSubmitting,
          width: double.infinity,
          type: ButtonType.primary,
          size: ButtonSize.large,
        )),
        
        const SizedBox(height: 12),
        
        CustomButton(
          text: 'Cancelar',
          onPressed: () => Get.back(),
          width: double.infinity,
          type: ButtonType.outlined,
        ),
      ],
    );
  }
}
