import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final ButtonType type;
  final ButtonSize size;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = !isEnabled || isLoading;
    
    return SizedBox(
      width: width,
      height: _getButtonHeight(),
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: _getButtonStyle(theme),
        child: _buildButtonContent(),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        width: _getLoadingSize(),
        height: _getLoadingSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getLoadingColor(),
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getIconSize()),
          const SizedBox(width: 8),
          Text(text, style: _getTextStyle()),
        ],
      );
    }

    return Text(text, style: _getTextStyle());
  }

  ButtonStyle _getButtonStyle(ThemeData theme) {
    final colors = _getButtonColors(theme);
    
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? colors.background,
      foregroundColor: textColor ?? colors.foreground,
      disabledBackgroundColor: colors.disabledBackground,
      disabledForegroundColor: colors.disabledForeground,
      elevation: type == ButtonType.flat ? 0 : 2,
      shadowColor: Colors.black26,
      padding: padding ?? _getButtonPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(_getBorderRadius()),
        side: type == ButtonType.outlined 
          ? BorderSide(color: backgroundColor ?? theme.colorScheme.primary)
          : BorderSide.none,
      ),
    );
  }

  _ButtonColors _getButtonColors(ThemeData theme) {
    switch (type) {
      case ButtonType.primary:
        return _ButtonColors(
          background: theme.colorScheme.primary,
          foreground: theme.colorScheme.onPrimary,
          disabledBackground: theme.colorScheme.primary.withOpacity(0.3),
          disabledForeground: theme.colorScheme.onPrimary.withOpacity(0.5),
        );
      
      case ButtonType.secondary:
        return _ButtonColors(
          background: theme.colorScheme.secondary,
          foreground: theme.colorScheme.onSecondary,
          disabledBackground: theme.colorScheme.secondary.withOpacity(0.3),
          disabledForeground: theme.colorScheme.onSecondary.withOpacity(0.5),
        );
      
      case ButtonType.success:
        return _ButtonColors(
          background: Colors.green,
          foreground: Colors.white,
          disabledBackground: Colors.green.withOpacity(0.3),
          disabledForeground: Colors.white.withOpacity(0.5),
        );
      
      case ButtonType.danger:
        return _ButtonColors(
          background: theme.colorScheme.error,
          foreground: theme.colorScheme.onError,
          disabledBackground: theme.colorScheme.error.withOpacity(0.3),
          disabledForeground: theme.colorScheme.onError.withOpacity(0.5),
        );
      
      case ButtonType.warning:
        return _ButtonColors(
          background: Colors.orange,
          foreground: Colors.white,
          disabledBackground: Colors.orange.withOpacity(0.3),
          disabledForeground: Colors.white.withOpacity(0.5),
        );
      
      case ButtonType.outlined:
        return _ButtonColors(
          background: Colors.transparent,
          foreground: theme.colorScheme.primary,
          disabledBackground: Colors.transparent,
          disabledForeground: theme.colorScheme.primary.withOpacity(0.5),
        );
      
      case ButtonType.flat:
        return _ButtonColors(
          background: Colors.transparent,
          foreground: theme.colorScheme.primary,
          disabledBackground: Colors.transparent,
          disabledForeground: theme.colorScheme.primary.withOpacity(0.5),
        );
    }
  }

  double _getButtonHeight() {
    switch (size) {
      case ButtonSize.small:
        return 36.0;
      case ButtonSize.medium:
        return 48.0;
      case ButtonSize.large:
        return 56.0;
    }
  }

  EdgeInsetsGeometry _getButtonPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case ButtonSize.small:
        return 6.0;
      case ButtonSize.medium:
        return 8.0;
      case ButtonSize.large:
        return 12.0;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16.0;
      case ButtonSize.medium:
        return 20.0;
      case ButtonSize.large:
        return 24.0;
    }
  }

  double _getLoadingSize() {
    switch (size) {
      case ButtonSize.small:
        return 16.0;
      case ButtonSize.medium:
        return 20.0;
      case ButtonSize.large:
        return 24.0;
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case ButtonSize.small:
        return const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
      case ButtonSize.medium:
        return const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
      case ButtonSize.large:
        return const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
    }
  }

  Color _getLoadingColor() {
    switch (type) {
      case ButtonType.outlined:
      case ButtonType.flat:
        return backgroundColor ?? Colors.blue;
      default:
        return textColor ?? Colors.white;
    }
  }
}

class _ButtonColors {
  final Color background;
  final Color foreground;
  final Color disabledBackground;
  final Color disabledForeground;

  const _ButtonColors({
    required this.background,
    required this.foreground,
    required this.disabledBackground,
    required this.disabledForeground,
  });
}

enum ButtonType {
  primary,
  secondary,
  success,
  danger,
  warning,
  outlined,
  flat,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class FloatingActionCustomButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isExtended;
  final String? label;
  final bool isLoading;

  const FloatingActionCustomButton({
    Key? key,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.isExtended = false,
    this.label,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<FloatingActionCustomButton> createState() => _FloatingActionCustomButtonState();
}

class _FloatingActionCustomButtonState extends State<FloatingActionCustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.isExtended
            ? FloatingActionButton.extended(
                onPressed: widget.isLoading ? null : _handlePress,
                icon: widget.isLoading 
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.foregroundColor ?? theme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Icon(widget.icon),
                label: Text(widget.label ?? ''),
                backgroundColor: widget.backgroundColor ?? theme.colorScheme.primary,
                foregroundColor: widget.foregroundColor ?? theme.colorScheme.onPrimary,
                tooltip: widget.tooltip,
              )
            : FloatingActionButton(
                onPressed: widget.isLoading ? null : _handlePress,
                backgroundColor: widget.backgroundColor ?? theme.colorScheme.primary,
                foregroundColor: widget.foregroundColor ?? theme.colorScheme.onPrimary,
                tooltip: widget.tooltip,
                child: widget.isLoading 
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.foregroundColor ?? theme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Icon(widget.icon),
              ),
        );
      },
    );
  }

  void _handlePress() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    widget.onPressed?.call();
  }
}

class IconCustomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;

  const IconCustomButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
    this.backgroundColor,
    this.size = 24.0,
    this.padding,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return IconButton(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading 
        ? SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? theme.colorScheme.primary,
              ),
            ),
          )
        : Icon(icon, size: size),
      color: color,
      tooltip: tooltip,
      padding: padding ?? const EdgeInsets.all(8),
      style: backgroundColor != null 
        ? IconButton.styleFrom(backgroundColor: backgroundColor)
        : null,
    );
  }
}

class ToggleCustomButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;

  const ToggleCustomButton({
    Key? key,
    required this.isSelected,
    this.onPressed,
    required this.text,
    this.icon,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected 
            ? (selectedColor ?? theme.colorScheme.primary)
            : (unselectedColor ?? theme.colorScheme.surface),
          foregroundColor: isSelected 
            ? (selectedTextColor ?? theme.colorScheme.onPrimary)
            : (unselectedTextColor ?? theme.colorScheme.onSurface),
          elevation: isSelected ? 4 : 1,
          side: BorderSide(
            color: isSelected 
              ? (selectedColor ?? theme.colorScheme.primary)
              : theme.colorScheme.outline,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(text),
          ],
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final List<Color> gradientColors;
  final double height;
  final double? width;
  final BorderRadius? borderRadius;
  final bool isLoading;
  final IconData? icon;

  const GradientButton({
    Key? key,
    required this.text,
    this.onPressed,
    required this.gradientColors,
    this.height = 48.0,
    this.width,
    this.borderRadius,
    this.isLoading = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(8),
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
          onTap: isLoading ? null : onPressed,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          child: Center(
            child: isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
          ),
        ),
      ),
    );
  }
} 