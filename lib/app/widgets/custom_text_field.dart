import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? helperText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool readOnly;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final bool showCounter;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final void Function(String)? onSubmitted;
  final bool autofocus;
  final String? errorText;
  final bool showBorder;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.hint,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.showCounter = false,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.autofocus = false,
    this.errorText,
    this.showBorder = true,
    this.fillColor,
    this.contentPadding,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: _isFocused 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        
        // Text Field
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          maxLength: widget.showCounter ? widget.maxLength : null,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onSubmitted,
          autofocus: widget.autofocus,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: widget.enabled 
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helperText,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: _isFocused
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.6),
                  )
                : null,
            suffixIcon: widget.suffixIcon,
            filled: true,
            fillColor: widget.fillColor ?? 
                (widget.enabled 
                    ? theme.colorScheme.surface
                    : theme.colorScheme.surface.withOpacity(0.5)),
            contentPadding: widget.contentPadding ?? 
                EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: widget.maxLines > 1 ? 16 : 12,
                ),
            border: widget.showBorder ? _buildBorder(theme, false, false) : InputBorder.none,
            enabledBorder: widget.showBorder ? _buildBorder(theme, false, false) : InputBorder.none,
            focusedBorder: widget.showBorder ? _buildBorder(theme, true, false) : InputBorder.none,
            errorBorder: widget.showBorder ? _buildBorder(theme, false, true) : InputBorder.none,
            focusedErrorBorder: widget.showBorder ? _buildBorder(theme, true, true) : InputBorder.none,
            disabledBorder: widget.showBorder ? _buildBorder(theme, false, false, disabled: true) : InputBorder.none,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            helperStyle: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            errorStyle: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
            counterStyle: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _buildBorder(
    ThemeData theme, 
    bool focused, 
    bool error, {
    bool disabled = false,
  }) {
    Color borderColor;
    double borderWidth;

    if (error) {
      borderColor = theme.colorScheme.error;
      borderWidth = focused ? 2.0 : 1.5;
    } else if (focused) {
      borderColor = theme.colorScheme.primary;
      borderWidth = 2.0;
    } else if (disabled) {
      borderColor = theme.colorScheme.outline.withOpacity(0.3);
      borderWidth = 1.0;
    } else {
      borderColor = theme.colorScheme.outline.withOpacity(0.5);
      borderWidth = 1.0;
    }

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: borderColor,
        width: borderWidth,
      ),
    );
  }
}

// Widget especializado para contraseñas
class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final void Function(String)? onSubmitted;
  final bool showStrengthIndicator;

  const PasswordTextField({
    Key? key,
    required this.controller,
    this.label = 'Contraseña',
    this.hint,
    this.validator,
    this.onChanged,
    this.focusNode,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.showStrengthIndicator = false,
  }) : super(key: key);

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;
  double _strength = 0.0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateStrength);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateStrength);
    super.dispose();
  }

  void _updateStrength() {
    if (widget.showStrengthIndicator) {
      setState(() {
        _strength = _calculatePasswordStrength(widget.controller.text);
      });
    }
  }

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    
    double strength = 0.0;
    
    // Longitud
    if (password.length >= 8) strength += 0.25;
    if (password.length >= 12) strength += 0.25;
    
    // Mayúsculas
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.15;
    
    // Minúsculas
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.15;
    
    // Números
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.1;
    
    // Caracteres especiales
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.1;
    
    return strength.clamp(0.0, 1.0);
  }

  Color _getStrengthColor() {
    if (_strength < 0.3) return Colors.red;
    if (_strength < 0.6) return Colors.orange;
    if (_strength < 0.8) return Colors.yellow;
    return Colors.green;
  }

  String _getStrengthText() {
    if (_strength < 0.3) return 'Débil';
    if (_strength < 0.6) return 'Regular';
    if (_strength < 0.8) return 'Buena';
    return 'Fuerte';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: widget.controller,
          label: widget.label,
          hint: widget.hint,
          prefixIcon: Icons.lock,
          suffixIcon: IconButton(
            icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
          obscureText: _obscureText,
          validator: widget.validator,
          onChanged: widget.onChanged,
          focusNode: widget.focusNode,
          textInputAction: widget.textInputAction,
          onSubmitted: widget.onSubmitted,
        ),
        
        // Indicador de fortaleza
        if (widget.showStrengthIndicator && widget.controller.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: _strength,
                  backgroundColor: Colors.grey.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(_getStrengthColor()),
                  minHeight: 4,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _getStrengthText(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _getStrengthColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// Widget especializado para montos
class AmountTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String currency;
  final double? minAmount;
  final double? maxAmount;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;

  const AmountTextField({
    Key? key,
    required this.controller,
    this.label = 'Monto',
    this.hint,
    this.currency = '€',
    this.minAmount,
    this.maxAmount,
    this.validator,
    this.onChanged,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label,
      hint: hint,
      prefixIcon: Icons.euro,
      suffixIcon: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          currency,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: validator ?? _defaultValidator,
      onChanged: onChanged,
      focusNode: focusNode,
    );
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'El monto es requerido';
    }
    
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Ingresa un monto válido';
    }
    
    if (minAmount != null && amount < minAmount!) {
      return 'Monto mínimo: $currency${minAmount!.toStringAsFixed(2)}';
    }
    
    if (maxAmount != null && amount > maxAmount!) {
      return 'Monto máximo: $currency${maxAmount!.toStringAsFixed(2)}';
    }
    
    return null;
  }
} 