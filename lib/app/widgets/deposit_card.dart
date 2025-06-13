import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/deposit_model.dart';
import '../controllers/deposit_controller.dart';

class DepositCard extends StatelessWidget {
  final DepositModel deposit;
  final VoidCallback? onTap;
  final bool showActions;

  const DepositCard({
    Key? key,
    required this.deposit,
    this.onTap,
    this.showActions = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final depositController = DepositController.to;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap ?? () => depositController.viewDepositDetails(deposit),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con estado y fecha
              _buildHeader(theme, depositController),
              
              const SizedBox(height: 12),
              
              // Información principal
              _buildMainInfo(theme, depositController),
              
              const SizedBox(height: 12),
              
              // Método de pago y referencia
              _buildPaymentInfo(theme, depositController),
              
              if (deposit.notes != null && deposit.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildNotes(theme),
              ],
              
              if (showActions) ...[
                const SizedBox(height: 16),
                _buildActions(theme, depositController),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, DepositController depositController) {
    final statusColor = depositController.getDepositStatusColor(deposit.status);
    final statusText = depositController.getDepositStatusText(deposit.status);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Estado del depósito
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getStatusIcon(),
                size: 16,
                color: statusColor,
              ),
              const SizedBox(width: 6),
              Text(
                statusText,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        // Fecha
        Text(
          _formatDate(deposit.createdAt),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildMainInfo(ThemeData theme, DepositController depositController) {
    return Row(
      children: [
        // Monto
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monto',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '€${deposit.amount.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // ID del depósito
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '#${deposit.id.substring(0, 8)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentInfo(ThemeData theme, DepositController depositController) {
    final paymentIcon = depositController.getPaymentMethodIcon(deposit.paymentMethod);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Método de pago
          Row(
            children: [
              Icon(
                paymentIcon,
                size: 20,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(width: 8),
              Text(
                _getPaymentMethodName(deposit.paymentMethod),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          // Referencia si existe
          if (deposit.referenceCode != null && deposit.referenceCode!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.tag,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  'Referencia: ${deposit.referenceCode}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
          
          // Comprobante si existe
          if (deposit.paymentProof != null && deposit.paymentProof!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.receipt,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  'Comprobante adjunto',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotes(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.note,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 6),
              Text(
                'Notas',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            deposit.notes!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(ThemeData theme, DepositController depositController) {
    return Row(
      children: [
        // Ver detalles
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => depositController.viewDepositDetails(deposit),
            icon: const Icon(Icons.visibility, size: 18),
            label: const Text('Ver detalles'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Acción específica según estado
        Expanded(
          child: _buildStatusSpecificAction(theme, depositController),
        ),
      ],
    );
  }

  Widget _buildStatusSpecificAction(ThemeData theme, DepositController depositController) {
    switch (deposit.status) {
      case 'pending':
        return ElevatedButton.icon(
          onPressed: () => _showPendingInfo(theme),
          icon: const Icon(Icons.hourglass_empty, size: 18),
          label: const Text('Pendiente'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        );
        
      case 'approved':
        return ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.check_circle, size: 18),
          label: const Text('Aprobado'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        );
        
      case 'rejected':
        return ElevatedButton.icon(
          onPressed: () => _showRejectedInfo(theme),
          icon: const Icon(Icons.error, size: 18),
          label: const Text('Rechazado'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        );
        
      default:
        return ElevatedButton.icon(
          onPressed: () => depositController.viewDepositDetails(deposit),
          icon: const Icon(Icons.info, size: 18),
          label: const Text('Info'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        );
    }
  }

  IconData _getStatusIcon() {
    switch (deposit.status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'bizum':
        return 'Bizum';
      case 'bank_transfer':
        return 'Transferencia bancaria';
      case 'paypal':
        return 'PayPal';
      case 'card':
        return 'Tarjeta de crédito';
      default:
        return method.toUpperCase();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showPendingInfo(ThemeData theme) {
    Get.dialog(
      AlertDialog(
        title: const Text('Depósito pendiente'),
        content: const Text(
          'Tu depósito está siendo revisado. Normalmente procesamos los depósitos en menos de 24 horas.'
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showRejectedInfo(ThemeData theme) {
    Get.dialog(
      AlertDialog(
        title: const Text('Depósito rechazado'),
        content: const Text(
          'Tu depósito fue rechazado. Por favor, contacta con soporte para más información.'
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Aquí podrías abrir el chat de soporte
            },
            child: const Text('Contactar soporte'),
          ),
        ],
      ),
    );
  }
} 