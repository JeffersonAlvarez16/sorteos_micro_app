import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/raffle_model.dart';
import '../controllers/home_controller.dart';

class RaffleCard extends StatelessWidget {
  final RaffleModel raffle;
  final VoidCallback? onTap;
  final bool showQuickBuy;
  final bool isCompact;

  const RaffleCard({
    Key? key,
    required this.raffle,
    this.onTap,
    this.showQuickBuy = true,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeController = HomeController.to;
    
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 16,
        vertical: isCompact ? 4 : 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap ?? () => homeController.goToRaffleDetail(raffle.id),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isCompact ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con estado y tiempo
              _buildHeader(theme, homeController),
              
              if (!isCompact) const SizedBox(height: 12),
              
              // Título y descripción
              _buildTitleSection(theme),
              
              const SizedBox(height: 12),
              
              // Información del premio y tickets
              _buildPrizeInfo(theme),
              
              if (!isCompact) ...[
                const SizedBox(height: 12),
                
                // Barra de progreso
                _buildProgressBar(theme),
                
                const SizedBox(height: 12),
                
                // Estadísticas
                _buildStats(theme),
                
                if (showQuickBuy && raffle.status == 'active') ...[
                  const SizedBox(height: 16),
                  _buildQuickBuySection(theme, homeController),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, HomeController homeController) {
    final timeRemaining = homeController.getTimeRemaining(raffle.endDate);
    final statusColor = _getStatusColor();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Estado del sorteo
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor, width: 1),
          ),
          child: Text(
            _getStatusText(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Tiempo restante
        if (raffle.status == 'active')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  timeRemaining,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTitleSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          raffle.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: isCompact ? 1 : 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (!isCompact && raffle.description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            raffle.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildPrizeInfo(ThemeData theme) {
    return Row(
      children: [
        // Premio
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premio',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '€${raffle.prizeAmount.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Precio del ticket
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ticket',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '€${raffle.ticketPrice.toStringAsFixed(2)}',
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

  Widget _buildProgressBar(ThemeData theme) {
    final progress = raffle.maxTickets > 0 ? raffle.soldTickets / raffle.maxTickets : 0.0;
    final progressColor = _getProgressColor(progress);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progreso',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${raffle.soldTickets}/${raffle.maxTickets}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toStringAsFixed(1)}% vendido',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(ThemeData theme) {
    return Row(
      children: [
        // Participantes
        _buildStatItem(
          theme,
          Icons.people,
          'Participantes',
          raffle.participantCount.toString(),
        ),
        
        const SizedBox(width: 16),
        
        // Tickets del usuario
        if (raffle.userTicketCount != null && raffle.userTicketCount! > 0)
          _buildStatItem(
            theme,
            Icons.confirmation_number,
            'Mis tickets',
            raffle.userTicketCount.toString(),
          ),
      ],
    );
  }

  Widget _buildStatItem(ThemeData theme, IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Text(
              value,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickBuySection(ThemeData theme, HomeController homeController) {
    final canParticipate = homeController.canUserParticipate(raffle);
    final recommendedTickets = homeController.getRecommendedTickets(raffle);
    
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => homeController.goToRaffleDetail(raffle.id),
            icon: const Icon(Icons.info_outline, size: 18),
            label: const Text('Ver detalles'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: ElevatedButton.icon(
            onPressed: canParticipate 
                ? () => homeController.quickPurchaseTickets(raffle.id, recommendedTickets)
                : null,
            icon: const Icon(Icons.shopping_cart, size: 18),
            label: Text('Comprar ($recommendedTickets)'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (raffle.status) {
      case 'active':
        final timeLeft = raffle.endDate.difference(DateTime.now());
        if (timeLeft.inHours < 1) return Colors.red;
        if (timeLeft.inHours < 6) return Colors.orange;
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (raffle.status) {
      case 'active':
        return 'Activo';
      case 'completed':
        return 'Completado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return raffle.status.name.toUpperCase();
    }
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) return Colors.green;
    if (progress < 0.7) return Colors.orange;
    return Colors.red;
  }
} 