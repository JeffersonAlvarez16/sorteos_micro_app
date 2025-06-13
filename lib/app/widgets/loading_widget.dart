import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;
  final bool showMessage;

  const LoadingWidget({
    Key? key,
    this.message,
    this.size = 50.0,
    this.color,
    this.showMessage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3.0,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? theme.colorScheme.primary,
              ),
            ),
          ),
          if (showMessage && message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class CustomLoadingWidget extends StatefulWidget {
  final String? message;
  final double size;
  final Color? color;
  final bool showMessage;
  final LoadingType type;

  const CustomLoadingWidget({
    Key? key,
    this.message,
    this.size = 50.0,
    this.color,
    this.showMessage = true,
    this.type = LoadingType.circular,
  }) : super(key: key);

  @override
  State<CustomLoadingWidget> createState() => _CustomLoadingWidgetState();
}

class _CustomLoadingWidgetState extends State<CustomLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loadingColor = widget.color ?? theme.colorScheme.primary;
    
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: _buildLoadingAnimation(loadingColor),
          ),
          if (widget.showMessage && widget.message != null) ...[
            const SizedBox(height: 16),
            Text(
              widget.message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingAnimation(Color color) {
    switch (widget.type) {
      case LoadingType.circular:
        return CircularProgressIndicator(
          strokeWidth: 3.0,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        );
      
      case LoadingType.dots:
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final delay = index * 0.2;
                final animationValue = (_animation.value - delay).clamp(0.0, 1.0);
                final scale = 0.5 + (0.5 * (1 - (animationValue - 0.5).abs() * 2));
                
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: widget.size / 6,
                    height: widget.size / 6,
                    margin: EdgeInsets.symmetric(horizontal: widget.size / 20),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            );
          },
        );
      
      case LoadingType.pulse:
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final scale = 0.8 + (0.4 * _animation.value);
            final opacity = 1.0 - _animation.value;
            
            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      
      case LoadingType.spinner:
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * 3.14159,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 3,
                  ),
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 6,
                    height: widget.size / 4,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            );
          },
        );
    }
  }
}

enum LoadingType {
  circular,
  dots,
  pulse,
  spinner,
}

class OverlayLoadingWidget extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;
  final Color? overlayColor;
  final LoadingType loadingType;

  const OverlayLoadingWidget({
    Key? key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
    this.overlayColor,
    this.loadingType = LoadingType.circular,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: overlayColor ?? Colors.black.withOpacity(0.5),
            child: CustomLoadingWidget(
              message: loadingMessage,
              type: loadingType,
            ),
          ),
      ],
    );
  }
}

class ShimmerLoadingWidget extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoadingWidget({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<ShimmerLoadingWidget> createState() => _ShimmerLoadingWidgetState();
}

class _ShimmerLoadingWidgetState extends State<ShimmerLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
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
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
              colors: [
                theme.colorScheme.surface.withOpacity(0.3),
                theme.colorScheme.surface.withOpacity(0.6),
                theme.colorScheme.surface.withOpacity(0.3),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ListLoadingWidget extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry? padding;

  const ListLoadingWidget({
    Key? key,
    this.itemCount = 5,
    this.itemHeight = 80.0,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          height: itemHeight,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Avatar shimmer
              ShimmerLoadingWidget(
                width: 50,
                height: 50,
                borderRadius: BorderRadius.circular(25),
              ),
              
              const SizedBox(width: 16),
              
              // Content shimmer
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShimmerLoadingWidget(
                      width: double.infinity,
                      height: 16,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(height: 8),
                    ShimmerLoadingWidget(
                      width: 200,
                      height: 12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CardLoadingWidget extends StatelessWidget {
  final double? width;
  final double height;
  final EdgeInsetsGeometry? margin;

  const CardLoadingWidget({
    Key? key,
    this.width,
    this.height = 200.0,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerLoadingWidget(
                    width: 80,
                    height: 20,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  ShimmerLoadingWidget(
                    width: 60,
                    height: 16,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Title
              ShimmerLoadingWidget(
                width: double.infinity,
                height: 24,
                borderRadius: BorderRadius.circular(12),
              ),
              
              const SizedBox(height: 8),
              
              // Subtitle
              ShimmerLoadingWidget(
                width: 250,
                height: 16,
                borderRadius: BorderRadius.circular(8),
              ),
              
              const Spacer(),
              
              // Bottom content
              Row(
                children: [
                  Expanded(
                    child: ShimmerLoadingWidget(
                      width: double.infinity,
                      height: 40,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ShimmerLoadingWidget(
                      width: double.infinity,
                      height: 40,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 