import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final bool showTrend;
  final double? trendValue;
  final bool isPositiveTrend;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.backgroundColor,
    this.textColor,
    this.onTap,
    this.showTrend = false,
    this.trendValue,
    this.isPositiveTrend = true,
    this.padding,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: width,
      height: height,
      child: Card(
        elevation: 2,
        color: backgroundColor ?? theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeader(theme),
                const SizedBox(height: 8),
                _buildValue(theme),
                if (subtitle != null || showTrend) ...[
                  const SizedBox(height: 4),
                  _buildFooter(theme),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor ?? theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (icon != null)
          Icon(
            icon,
            size: 24,
            color: iconColor ?? theme.colorScheme.primary,
          ),
      ],
    );
  }

  Widget _buildValue(ThemeData theme) {
    return Text(
      value,
      style: theme.textTheme.headlineMedium?.copyWith(
        color: textColor ?? theme.colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Row(
      children: [
        if (subtitle != null)
          Expanded(
            child: Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: textColor ?? theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (showTrend && trendValue != null)
          _buildTrend(theme),
      ],
    );
  }

  Widget _buildTrend(ThemeData theme) {
    final trendColor = isPositiveTrend ? Colors.green : Colors.red;
    final trendIcon = isPositiveTrend ? Icons.trending_up : Icons.trending_down;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: trendColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            trendIcon,
            size: 12,
            color: trendColor,
          ),
          const SizedBox(width: 2),
          Text(
            '${trendValue!.abs().toStringAsFixed(1)}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: trendColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedStatCard extends StatefulWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final Duration animationDuration;

  const AnimatedStatCard({
    Key? key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 800),
  }) : super(key: key);

  @override
  State<AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<AnimatedStatCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: StatCard(
              title: widget.title,
              value: widget.value,
              subtitle: widget.subtitle,
              icon: widget.icon,
              iconColor: widget.iconColor,
              backgroundColor: widget.backgroundColor,
              onTap: widget.onTap,
            ),
          ),
        );
      },
    );
  }
}

class GradientStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final List<Color> gradientColors;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const GradientStatCard({
    Key? key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    required this.gradientColors,
    this.onTap,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (icon != null)
                      Icon(
                        icon,
                        size: 24,
                        color: Colors.white,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CompactStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;

  const CompactStatCard({
    Key? key,
    required this.title,
    required this.value,
    this.icon,
    this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.colorScheme.primary;
    
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: cardColor,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CircularStatCard extends StatelessWidget {
  final String title;
  final double value;
  final double maxValue;
  final String? subtitle;
  final Color? progressColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const CircularStatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.maxValue,
    this.subtitle,
    this.progressColor,
    this.backgroundColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).toInt();
    
    return Card(
      elevation: 2,
      color: backgroundColor ?? theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progressColor ?? theme.colorScheme.primary,
                      ),
                    ),
                    Center(
                      child: Text(
                        '$percentage%',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class StatCardGrid extends StatelessWidget {
  final List<StatCardData> stats;
  final int crossAxisCount;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const StatCardGrid({
    Key? key,
    required this.stats,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.5,
    this.padding,
    this.mainAxisSpacing = 16,
    this.crossAxisSpacing = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          return StatCard(
            title: stat.title,
            value: stat.value,
            subtitle: stat.subtitle,
            icon: stat.icon,
            iconColor: stat.iconColor,
            backgroundColor: stat.backgroundColor,
            onTap: stat.onTap,
            showTrend: stat.showTrend,
            trendValue: stat.trendValue,
            isPositiveTrend: stat.isPositiveTrend,
          );
        },
      ),
    );
  }
}

class StatCardData {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool showTrend;
  final double? trendValue;
  final bool isPositiveTrend;

  const StatCardData({
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
    this.showTrend = false,
    this.trendValue,
    this.isPositiveTrend = true,
  });
} 