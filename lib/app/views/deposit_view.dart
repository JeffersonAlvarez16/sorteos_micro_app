import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/deposit_controller.dart';
import '../widgets/deposit_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/stat_card.dart';

class DepositView extends GetView<DepositController> {
  const DepositView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: _buildAppBar(theme),
      body: RefreshIndicator(
        onRefresh: controller.refreshDeposits,
        child: CustomScrollView(
          slivers: [
            // Balance y estadísticas
            SliverToBoxAdapter(
              child: _buildBalanceSection(theme),
            ),
            
            // Botones de acción rápida
            SliverToBoxAdapter(
              child: _buildQuickActions(theme),
            ),
            
            // Filtros
            SliverToBoxAdapter(
              child: _buildFilters(theme),
            ),
            
            // Lista de depósitos
            _buildDepositsList(theme),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(theme),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      title: const Text('Mis Depósitos'),
      backgroundColor: Colors.white,
      foregroundColor: Colors.grey.shade800,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: () => controller.toggleInstructions(),
          icon: Icon(Icons.help_outline, color: Colors.grey.shade600),
          tooltip: 'Ayuda',
        ),
        PopupMenuButton<String>(
          onSelected: controller.handleMenuAction,
          icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'export',
              child: ListTile(
                leading: Icon(Icons.download),
                title: Text('Exportar historial'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
           /*  const PopupMenuItem(
              value: 'payment_methods',
              child: ListTile(
                leading: Icon(Icons.payment),
                title: Text('Métodos de pago'),
                contentPadding: EdgeInsets.zero,
              ),
            ), */
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Balance principal
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Column(
              children: [
                Text(
                  'Balance disponible',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => Text(
                  '\$${controller.userBalance.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                )),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBalanceAction(
                      theme,
                      'Depositar',
                      Icons.add,
                      controller.showDepositFormAction,
                    ),
                    const SizedBox(width: 24),
                    _buildBalanceAction(
                      theme,
                      'Métodos',
                      Icons.credit_card,
                      () => Get.toNamed('/payment-methods'),
                    ),
                    const SizedBox(width: 24),
                    _buildBalanceAction(
                      theme,
                      'Historial',
                      Icons.history,
                      controller.showDepositHistoryAction,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Estadísticas rápidas
          Obx(() => Row(
            children: [
              Expanded(
                child: CompactStatCard(
                  title: 'Total depositado',
                  value: '\$${controller.totalDeposited.toStringAsFixed(2)}',
                  icon: Icons.trending_up,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CompactStatCard(
                  title: 'Depósitos pendientes',
                  value: controller.pendingDepositsCount.toString(),
                  icon: Icons.hourglass_empty,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildBalanceAction(
    ThemeData theme,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.grey.shade700,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Nuevo depósito',
              onPressed: controller.goToNewDeposit,
              type: ButtonType.primary,
              icon: Icons.add,
            ),
          ),
          const SizedBox(width: 12),
          /* Expanded(
            child: CustomButton(
              text: 'Métodos de pago',
              onPressed: controller.managePaymentMethods,
              type: ButtonType.outlined,
              icon: Icons.payment,
            ),
          ), */
        ],
      ),
    );
  }

  Widget _buildFilters(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrar por estado',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('Todos', 'all', theme),
                const SizedBox(width: 8),
                _buildFilterChip('Pendientes', 'pending', theme),
                const SizedBox(width: 8),
                _buildFilterChip('Aprobados', 'approved', theme),
                const SizedBox(width: 8),
                _buildFilterChip('Rechazados', 'rejected', theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, ThemeData theme) {
    return Obx(() => FilterChip(
      label: Text(label),
      selected: controller.selectedFilter == value,
      onSelected: (_) => controller.setFilter(value),
      backgroundColor: Colors.grey.shade100,
      selectedColor: Colors.grey.shade200,
      checkmarkColor: Colors.grey.shade700,
      side: BorderSide(color: Colors.grey.shade300, width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      labelStyle: TextStyle(
        color: controller.selectedFilter == value
          ? Colors.grey.shade800
          : Colors.grey.shade600,
        fontWeight: controller.selectedFilter == value
          ? FontWeight.w500
          : FontWeight.normal,
        fontSize: 13,
      ),
    ));
  }

  Widget _buildDepositsList(ThemeData theme) {
    return Obx(() {
      if (controller.isLoading && controller.filteredDeposits.isEmpty) {
        return const SliverFillRemaining(
          child: LoadingWidget(message: 'Cargando depósitos...'),
        );
      }

      if (controller.filteredDeposits.isEmpty) {
        return SliverFillRemaining(
          child: NoDepositsWidget(
            onCreateDeposit: controller.showDepositFormCallback,
          ),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == controller.filteredDeposits.length) {
              return Obx(() => controller.isLoadingMore
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: LoadingWidget(message: 'Cargando más depósitos...'),
                  )
                : const SizedBox.shrink());
            }

            final deposit = controller.filteredDeposits[index];
            return DepositCard(
              deposit: deposit,
              onTap: () => controller.viewDepositDetails(deposit),
            );
          },
          childCount: controller.filteredDeposits.length + 1,
        ),
      );
    });
  }

  Widget _buildFloatingActionButton(ThemeData theme) {
    return FloatingActionCustomButton(
      onPressed: controller.showDepositFormAction,
      icon: Icons.add,
      tooltip: 'Nuevo depósito',
      backgroundColor: Colors.grey.shade800,
    );
  }
}

// Pantalla del formulario de depósito
class DepositFormView extends GetView<DepositController> {
  const DepositFormView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Nuevo Depósito'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
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
        AmountTextField(
          controller: controller.amountController,
          label: 'Monto a depositar',
          hint: '10.00',
          minAmount: 10.0,
          maxAmount: 10000.0,
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
            onPressed: controller.selectProofImage,
            type: ButtonType.outlined,
            icon: Icons.photo_library,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(ThemeData theme) {
    return CustomTextField(
      controller: controller.notesController,
      label: 'Notas adicionales (opcional)',
      hint: 'Información adicional sobre el depósito...',
      maxLines: 3,
      prefixIcon: Icons.note,
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