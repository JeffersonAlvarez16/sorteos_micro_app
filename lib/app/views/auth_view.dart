import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_widget.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Logo y título
              _buildHeader(theme),
              
              const SizedBox(height: 40),
              
              // Formulario de autenticación
              _buildAuthForm(theme),
              
              const SizedBox(height: 20),
              
              // Enlaces adicionales
              _buildFooterLinks(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        // Logo
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.celebration,
            size: 60,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Título
        Text(
          'Sorteos App',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Subtítulo
        Obx(() => Text(
          _getSubtitle(),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onBackground.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        )),
      ],
    );
  }

  Widget _buildAuthForm(ThemeData theme) {
    return Obx(() => AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: controller.isLoginMode.value
        ? _buildLoginForm(theme)
        : controller.isRecoveryMode.value
          ? _buildRecoveryForm(theme)
          : _buildRegisterForm(theme),
    ));
  }

  Widget _buildLoginForm(ThemeData theme) {
    return Form(
      key: controller.loginFormKey,
      child: Column(
        key: const ValueKey('login'),
        children: [
          // Email
          CustomTextField(
            controller: controller.emailController,
            label: 'Correo electrónico',
            hint: 'tu@email.com',
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: controller.validateEmail,
            onChanged: controller.onEmailChanged,
            textInputAction: TextInputAction.next,
          ),
          
          const SizedBox(height: 16),
          
          // Contraseña
          PasswordTextField(
            controller: controller.passwordController,
            label: 'Contraseña',
            hint: 'Tu contraseña',
            validator: controller.validatePassword,
            onChanged: controller.onPasswordChanged,
            onSubmitted: (_) => controller.login(),
          ),
          
          const SizedBox(height: 8),
          
          // Recordar sesión y olvidé contraseña
          Row(
            children: [
              Obx(() => Checkbox(
                value: controller.rememberMe.value,
                onChanged: controller.toggleRememberMe,
              )),
              Text(
                'Recordar sesión',
                style: theme.textTheme.bodyMedium,
              ),
              const Spacer(),
              TextButton(
                onPressed: controller.goToRecovery,
                child: Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Botón de login
          Obx(() => CustomButton(
            text: 'Iniciar sesión',
            onPressed: controller.canLogin.value ? controller.login : null,
            isLoading: controller.isLoading.value,
            width: double.infinity,
            type: ButtonType.primary,
            size: ButtonSize.large,
          )),
          
          const SizedBox(height: 16),
          
          // Cambiar a registro
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¿No tienes cuenta? ',
                style: theme.textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: controller.toggleAuthMode,
                child: Text(
                  'Regístrate',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm(ThemeData theme) {
    return Form(
      key: controller.registerFormKey,
      child: Column(
        key: const ValueKey('register'),
        children: [
          // Nombre completo
          CustomTextField(
            controller: controller.fullNameController,
            label: 'Nombre completo',
            hint: 'Tu nombre completo',
            prefixIcon: Icons.person,
            validator: controller.validateFullName,
            onChanged: controller.onFullNameChanged,
            textInputAction: TextInputAction.next,
          ),
          
          const SizedBox(height: 16),
          
          // Email
          CustomTextField(
            controller: controller.emailController,
            label: 'Correo electrónico',
            hint: 'tu@email.com',
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: controller.validateEmail,
            onChanged: controller.onEmailChanged,
            textInputAction: TextInputAction.next,
          ),
          
          const SizedBox(height: 16),
          
          // Teléfono
          CustomTextField(
            controller: controller.phoneController,
            label: 'Teléfono',
            hint: '+34 600 000 000',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: controller.validatePhone,
            onChanged: controller.onPhoneChanged,
            textInputAction: TextInputAction.next,
          ),
          
          const SizedBox(height: 16),
          
          // Contraseña
          PasswordTextField(
            controller: controller.passwordController,
            label: 'Contraseña',
            hint: 'Mínimo 8 caracteres',
            validator: controller.validatePassword,
            onChanged: controller.onPasswordChanged,
            showStrengthIndicator: true,
          ),
          
          const SizedBox(height: 16),
          
          // Confirmar contraseña
          PasswordTextField(
            controller: controller.confirmPasswordController,
            label: 'Confirmar contraseña',
            hint: 'Repite tu contraseña',
            validator: controller.validateConfirmPassword,
            onChanged: controller.onConfirmPasswordChanged,
            onSubmitted: (_) => controller.register(),
          ),
          
          const SizedBox(height: 16),
          
          // Términos y condiciones
          Row(
            children: [
              Obx(() => Checkbox(
                value: controller.acceptTerms.value,
                onChanged: controller.toggleAcceptTerms,
              )),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium,
                    children: [
                      const TextSpan(text: 'Acepto los '),
                      TextSpan(
                        text: 'términos y condiciones',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: ' y la '),
                      TextSpan(
                        text: 'política de privacidad',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Botón de registro
          Obx(() => CustomButton(
            text: 'Crear cuenta',
            onPressed: controller.canRegister.value ? controller.register : null,
            isLoading: controller.isLoading.value,
            width: double.infinity,
            type: ButtonType.primary,
            size: ButtonSize.large,
          )),
          
          const SizedBox(height: 16),
          
          // Cambiar a login
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¿Ya tienes cuenta? ',
                style: theme.textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: controller.toggleAuthMode,
                child: Text(
                  'Inicia sesión',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryForm(ThemeData theme) {
    return Form(
      key: controller.recoveryFormKey,
      child: Column(
        key: const ValueKey('recovery'),
        children: [
          // Descripción
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Email
          CustomTextField(
            controller: controller.emailController,
            label: 'Correo electrónico',
            hint: 'tu@email.com',
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: controller.validateEmail,
            onChanged: controller.onEmailChanged,
            onSubmitted: (_) => controller.sendPasswordReset(),
          ),
          
          const SizedBox(height: 24),
          
          // Botón de envío
          Obx(() => CustomButton(
            text: 'Enviar enlace',
            onPressed: controller.canSendReset.value ? controller.sendPasswordReset : null,
            isLoading: controller.isLoading.value,
            width: double.infinity,
            type: ButtonType.primary,
            size: ButtonSize.large,
          )),
          
          const SizedBox(height: 16),
          
          // Volver al login
          TextButton(
            onPressed: controller.backToLogin,
            child: Text(
              'Volver al inicio de sesión',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLinks(ThemeData theme) {
    return Column(
      children: [
        // Divider con "O"
        Row(
          children: [
            Expanded(child: Divider(color: theme.colorScheme.outline)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'O',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            Expanded(child: Divider(color: theme.colorScheme.outline)),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Botones de redes sociales (si están disponibles)
        if (!controller.isRecoveryMode.value) ...[
          CustomButton(
            text: 'Continuar con Google',
            onPressed: controller.signInWithGoogle,
            type: ButtonType.outlined,
            width: double.infinity,
            icon: Icons.g_mobiledata,
          ),
          
          const SizedBox(height: 12),
          
          CustomButton(
            text: 'Continuar con Apple',
            onPressed: controller.signInWithApple,
            type: ButtonType.outlined,
            width: double.infinity,
            icon: Icons.apple,
          ),
        ],
        
        const SizedBox(height: 20),
        
        // Enlaces de ayuda
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: controller.openSupport,
              child: Text(
                'Ayuda',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
            Text(
              '•',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            TextButton(
              onPressed: controller.openPrivacyPolicy,
              child: Text(
                'Privacidad',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
            Text(
              '•',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            TextButton(
              onPressed: controller.openTerms,
              child: Text(
                'Términos',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getSubtitle() {
    if (controller.isRecoveryMode.value) {
      return 'Recupera tu contraseña';
    }
    return controller.isLoginMode.value
      ? 'Inicia sesión para participar en sorteos'
      : 'Crea tu cuenta y comienza a ganar';
  }
} 