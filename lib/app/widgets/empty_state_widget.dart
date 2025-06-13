import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? imagePath;
  final Widget? customIcon;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final Color? iconColor;
  final double iconSize;
  final EdgeInsetsGeometry? padding;
  final bool showAction;

  const EmptyStateWidget({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
    this.imagePath,
    this.customIcon,
    this.actionText,
    this.onActionPressed,
    this.iconColor,
    this.iconSize = 80.0,
    this.padding,
    this.showAction = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: padding ?? const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono o imagen
            _buildIcon(theme),
            
            const SizedBox(height: 24),
            
            // Título
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Subtítulo
            if (subtitle != null) ...[
              const SizedBox(height: 12),
              Text(
                subtitle!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            // Botón de acción
            if (showAction && actionText != null && onActionPressed != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onActionPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  actionText!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(ThemeData theme) {
    if (customIcon != null) {
      return customIcon!;
    }
    
    if (imagePath != null) {
      return Image.asset(
        imagePath!,
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
      );
    }
    
    return Icon(
      icon ?? Icons.inbox_outlined,
      size: iconSize,
      color: iconColor ?? theme.colorScheme.primary.withOpacity(0.6),
    );
  }
}

class NoDataWidget extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const NoDataWidget({
    Key? key,
    this.title,
    this.subtitle,
    this.actionText,
    this.onActionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: title ?? 'No hay datos disponibles',
      subtitle: subtitle ?? 'No se encontraron elementos para mostrar.',
      icon: Icons.inbox_outlined,
      actionText: actionText,
      onActionPressed: onActionPressed,
    );
  }
}

class NoRafflesWidget extends StatelessWidget {
  final VoidCallback? onRefresh;

  const NoRafflesWidget({
    Key? key,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No hay sorteos disponibles',
      subtitle: 'Actualmente no hay sorteos activos. ¡Vuelve pronto para participar!',
      icon: Icons.celebration_outlined,
      actionText: onRefresh != null ? 'Actualizar' : null,
      onActionPressed: onRefresh,
    );
  }
}

class NoDepositsWidget extends StatelessWidget {
  final VoidCallback? onCreateDeposit;

  const NoDepositsWidget({
    Key? key,
    this.onCreateDeposit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No tienes depósitos',
      subtitle: 'Realiza tu primer depósito para comenzar a participar en los sorteos.',
      icon: Icons.account_balance_wallet_outlined,
      actionText: onCreateDeposit != null ? 'Hacer depósito' : null,
      onActionPressed: onCreateDeposit,
    );
  }
}

class NoTicketsWidget extends StatelessWidget {
  final VoidCallback? onBuyTickets;

  const NoTicketsWidget({
    Key? key,
    this.onBuyTickets,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No tienes boletos',
      subtitle: 'Compra boletos para participar en este sorteo y tener la oportunidad de ganar.',
      icon: Icons.confirmation_number_outlined,
      actionText: onBuyTickets != null ? 'Comprar boletos' : null,
      onActionPressed: onBuyTickets,
    );
  }
}

class NoNotificationsWidget extends StatelessWidget {
  const NoNotificationsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      title: 'No hay notificaciones',
      subtitle: 'Todas las notificaciones aparecerán aquí.',
      icon: Icons.notifications_none_outlined,
      showAction: false,
    );
  }
}

class NoSearchResultsWidget extends StatelessWidget {
  final String searchQuery;
  final VoidCallback? onClearSearch;

  const NoSearchResultsWidget({
    Key? key,
    required this.searchQuery,
    this.onClearSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'Sin resultados',
      subtitle: 'No se encontraron resultados para "$searchQuery".\nIntenta con otros términos de búsqueda.',
      icon: Icons.search_off_outlined,
      actionText: onClearSearch != null ? 'Limpiar búsqueda' : null,
      onActionPressed: onClearSearch,
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final IconData? icon;

  const ErrorStateWidget({
    Key? key,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onActionPressed,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return EmptyStateWidget(
      title: title,
      subtitle: subtitle,
      icon: icon ?? Icons.error_outline,
      iconColor: theme.colorScheme.error,
      actionText: actionText,
      onActionPressed: onActionPressed,
    );
  }
}

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({
    Key? key,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      title: 'Error de conexión',
      subtitle: 'No se pudo conectar al servidor.\nVerifica tu conexión a internet e intenta nuevamente.',
      icon: Icons.wifi_off_outlined,
      actionText: onRetry != null ? 'Reintentar' : null,
      onActionPressed: onRetry,
    );
  }
}

class MaintenanceWidget extends StatelessWidget {
  final String? message;

  const MaintenanceWidget({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'Mantenimiento',
      subtitle: message ?? 'La aplicación está en mantenimiento.\nVuelve en unos minutos.',
      icon: Icons.build_outlined,
      showAction: false,
    );
  }
}

class ComingSoonWidget extends StatelessWidget {
  final String feature;
  final String? description;

  const ComingSoonWidget({
    Key? key,
    required this.feature,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'Próximamente',
      subtitle: description ?? '$feature estará disponible pronto.\n¡Mantente atento a las actualizaciones!',
      icon: Icons.upcoming_outlined,
      showAction: false,
    );
  }
}

class AnimatedEmptyStateWidget extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final Duration animationDuration;

  const AnimatedEmptyStateWidget({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actionText,
    this.onActionPressed,
    this.animationDuration = const Duration(milliseconds: 800),
  }) : super(key: key);

  @override
  State<AnimatedEmptyStateWidget> createState() => _AnimatedEmptyStateWidgetState();
}

class _AnimatedEmptyStateWidgetState extends State<AnimatedEmptyStateWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: EmptyStateWidget(
                title: widget.title,
                subtitle: widget.subtitle,
                icon: widget.icon,
                actionText: widget.actionText,
                onActionPressed: widget.onActionPressed,
              ),
            ),
          ),
        );
      },
    );
  }
} 