import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/raffle_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/stat_card.dart';

class RaffleDetailView extends GetView<RaffleController> {
  const RaffleDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Obx(() {
        if (controller.isLoading.value && controller.currentRaffle.value == null) {
          return const LoadingWidget(message: 'Cargando sorteo...');
        }

        if (controller.currentRaffle.value == null) {
          return const ErrorStateWidget(
            title: 'Sorteo no encontrado',
            subtitle: 'No se pudo cargar la información del sorteo.',
          );
        }

        return CustomScrollView(
          slivers: [
            // App Bar con imagen de fondo
            _buildSliverAppBar(theme),
            
            // Información principal
            SliverToBoxAdapter(
              child: _buildMainInfo(theme),
            ),
            
            // Estadísticas en tiempo real
            SliverToBoxAdapter(
              child: _buildRealTimeStats(theme),
            ),
            
            // Selector de boletos
            SliverToBoxAdapter(
              child: _buildTicketSelector(theme),
            ),
            
            // Información adicional
            SliverToBoxAdapter(
              child: _buildAdditionalInfo(theme),
            ),
            
            // Participantes recientes
            SliverToBoxAdapter(
              child: _buildRecentParticipants(theme),
            ),
          ],
        );
      }),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 250.0,
      floating: false,
      pinned: true,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      flexibleSpace: FlexibleSpaceBar(
        title: Obx(() => Text(
          controller.currentRaffle.value?.title ?? '',
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 4,
              ),
            ],
          ),
        )),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen de fondo o gradiente
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
              ),
            ),
            
            // Overlay con información del estado
            Positioned(
              top: 100,
              right: 16,
              child: Obx(() => _buildStatusBadge(theme)),
            ),
            
            // Tiempo restante
            Positioned(
              bottom: 60,
              left: 16,
              child: Obx(() => _buildTimeRemaining(theme)),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: controller.shareRaffle,
          icon: const Icon(Icons.share),
          tooltip: 'Compartir',
        ),
        PopupMenuButton<String>(
          onSelected: controller.handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'rules',
              child: ListTile(
                leading: Icon(Icons.rule),
                title: Text('Ver reglas'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'history',
              child: ListTile(
                leading: Icon(Icons.history),
                title: Text('Mi historial'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'report',
              child: ListTile(
                leading: Icon(Icons.report),
                title: Text('Reportar'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(ThemeData theme) {
    final raffle = controller.currentRaffle.value!;
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (raffle.status) {
      case 'active':
        statusColor = Colors.green;
        statusText = 'Activo';
        statusIcon = Icons.play_circle;
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusText = 'Completado';
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = 'Cancelado';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Desconocido';
        statusIcon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRemaining(ThemeData theme) {
    return Obx(() {
      final timeRemaining = controller.timeRemaining.value;
      if (timeRemaining.isEmpty) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.access_time,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              timeRemaining,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMainInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Descripción
          Obx(() {
            final description = controller.currentRaffle.value?.description ?? '';
            if (description.isEmpty) return const SizedBox.shrink();
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Descripción',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          }),
          
          // Información del premio y tickets
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  theme,
                  'Premio',
                  '€${controller.currentRaffle.value?.prizeAmount.toStringAsFixed(2) ?? '0.00'}',
                  Icons.emoji_events,
                  theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  theme,
                  'Precio por boleto',
                  '€${controller.currentRaffle.value?.ticketPrice.toStringAsFixed(2) ?? '0.00'}',
                  Icons.confirmation_number,
                  theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealTimeStats(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estadísticas en tiempo real',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Barra de progreso
          Obx(() => _buildProgressSection(theme)),
          
          const SizedBox(height: 16),
          
          // Grid de estadísticas
          Obx(() => _buildStatsGrid(theme)),
        ],
      ),
    );
  }

  Widget _buildProgressSection(ThemeData theme) {
    final raffle = controller.currentRaffle.value!;
    final progress = raffle.maxTickets > 0 ? raffle.soldTickets / raffle.maxTickets : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progreso de venta',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${raffle.soldTickets}/${raffle.maxTickets}',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
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
            valueColor: AlwaysStoppedAnimation<Color>(
              progress < 0.5 ? Colors.green : 
              progress < 0.8 ? Colors.orange : Colors.red,
            ),
            minHeight: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toStringAsFixed(1)}% vendido',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(ThemeData theme) {
    final stats = controller.raffleStats.value;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        CompactStatCard(
          title: 'Participantes',
          value: stats?.participantCount.toString() ?? '0',
          icon: Icons.people,
          color: Colors.blue,
        ),
        CompactStatCard(
          title: 'Mis boletos',
          value: controller.userTicketCount.value.toString(),
          icon: Icons.confirmation_number,
          color: theme.colorScheme.primary,
        ),
        CompactStatCard(
          title: 'Probabilidad',
          value: '${controller.winProbability.value.toStringAsFixed(2)}%',
          icon: Icons.trending_up,
          color: Colors.green,
        ),
        CompactStatCard(
          title: 'Inversión',
          value: '€${controller.totalInvestment.value.toStringAsFixed(2)}',
          icon: Icons.account_balance_wallet,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildTicketSelector(ThemeData theme) {
    return Obx(() {
      if (!controller.canPurchaseTickets.value) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comprar boletos',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Selector de cantidad
            Row(
              children: [
                Text(
                  'Cantidad:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: controller.decreaseTicketCount,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: theme.colorScheme.primary,
                ),
                Container(
                  width: 60,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      controller.selectedTicketCount.value.toString(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: controller.increaseTicketCount,
                  icon: const Icon(Icons.add_circle_outline),
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Botones de cantidad rápida
            Wrap(
              spacing: 8,
              children: [1, 5, 10, 25].map((count) {
                return ChoiceChip(
                  label: Text('$count'),
                  selected: controller.selectedTicketCount.value == count,
                  onSelected: (_) => controller.setTicketCount(count),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // Resumen del costo
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total a pagar:',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '€${controller.totalCost.value.toStringAsFixed(2)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAdditionalInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información adicional',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildInfoRow(
            theme,
            'Fecha de inicio',
            controller.formatDate(controller.currentRaffle.value?.startDate),
            Icons.calendar_today,
          ),
          
          _buildInfoRow(
            theme,
            'Fecha de finalización',
            controller.formatDate(controller.currentRaffle.value?.endDate),
            Icons.event,
          ),
          
          _buildInfoRow(
            theme,
            'Método de sorteo',
            'Aleatorio verificable',
            Icons.shuffle,
          ),
          
          _buildInfoRow(
            theme,
            'Comisión de la plataforma',
            '5%',
            Icons.percent,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    String label,
    String? value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
          Text(
            value ?? 'N/A',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentParticipants(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Participantes recientes',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: controller.viewAllParticipants,
                child: const Text('Ver todos'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Lista de participantes recientes
          Obx(() {
            if (controller.isLoadingParticipants.value) {
              return const LoadingWidget(message: 'Cargando participantes...');
            }
            
            if (controller.recentParticipants.isEmpty) {
              return const NoDataWidget(
                title: 'Sin participantes aún',
                subtitle: '¡Sé el primero en participar!',
              );
            }
            
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.recentParticipants.length.clamp(0, 5),
              itemBuilder: (context, index) {
                final participant = controller.recentParticipants[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      participant.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(participant.name),
                  subtitle: Text('${participant.ticketCount} boletos'),
                  trailing: Text(
                    controller.formatTimeAgo(participant.purchaseDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    return Obx(() {
      if (!controller.canPurchaseTickets.value) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: CustomButton(
            text: _getDisabledButtonText(),
            onPressed: null,
            width: double.infinity,
            type: ButtonType.primary,
            size: ButtonSize.large,
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Ver reglas',
                onPressed: controller.viewRules,
                type: ButtonType.outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: CustomButton(
                text: 'Comprar boletos (€${controller.totalCost.value.toStringAsFixed(2)})',
                onPressed: controller.purchaseTickets,
                isLoading: controller.isPurchasing.value,
                type: ButtonType.primary,
                size: ButtonSize.large,
              ),
            ),
          ],
        ),
      );
    });
  }

  String _getDisabledButtonText() {
    final raffle = controller.currentRaffle.value;
    if (raffle == null) return 'Cargando...';
    
    switch (raffle.status) {
      case 'completed':
        return 'Sorteo finalizado';
      case 'cancelled':
        return 'Sorteo cancelado';
      default:
        return 'No disponible';
    }
  }
} 