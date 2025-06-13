import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_widget.dart';
import '../widgets/stat_card.dart';
import '../widgets/custom_text_field.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Obx(() {
        if (controller.isLoading) {
          return const LoadingWidget(message: 'Cargando perfil...');
        }

        return CustomScrollView(
          slivers: [
            // App Bar con información del usuario
            _buildSliverAppBar(theme),
            
            // Estadísticas del usuario
            SliverToBoxAdapter(
              child: _buildUserStats(theme),
            ),
            
            // Opciones de perfil
            SliverToBoxAdapter(
              child: _buildProfileOptions(theme),
            ),
            
            // Configuraciones
            SliverToBoxAdapter(
              child: _buildSettings(theme),
            ),
            
            // Información de la cuenta
            SliverToBoxAdapter(
              child: _buildAccountInfo(theme),
            ),
            
            // Acciones de cuenta
            SliverToBoxAdapter(
              child: _buildAccountActions(theme),
            ),
          ],
        );
      }),
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
          controller.user?.fullName ?? 'Usuario',
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        )),
        background: Container(
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // Avatar del usuario
              Obx(() => GestureDetector(
                onTap: controller.changeAvatar,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      backgroundImage: controller.user?.avatar != null
                          ? NetworkImage(controller.user!.avatar!)
                          : null,
                      child: controller.user?.avatar == null
                          ? Icon(
                              Icons.person,
                              size: 50,
                              color: theme.colorScheme.onPrimary,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
              
              const SizedBox(height: 16),
              
              // Email del usuario
              Obx(() => Text(
                controller.user?.email ?? '',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary.withOpacity(0.8),
                  fontSize: 14,
                ),
              )),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: controller.editProfile,
          icon: const Icon(Icons.edit),
          tooltip: 'Editar perfil',
        ),
        PopupMenuButton<String>(
          onSelected: controller.handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'help',
              child: ListTile(
                leading: Icon(Icons.help),
                title: Text('Ayuda'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'privacy',
              child: ListTile(
                leading: Icon(Icons.privacy_tip),
                title: Text('Privacidad'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'terms',
              child: ListTile(
                leading: Icon(Icons.description),
                title: Text('Términos'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserStats(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mis estadísticas',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          Obx(() => GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              CompactStatCard(
                title: 'Sorteos participados',
                value: controller.userStats['total_raffles']?.toString() ?? '0',
                icon: Icons.confirmation_number,
                color: theme.colorScheme.primary,
              ),
              CompactStatCard(
                title: 'Boletos comprados',
                value: controller.userStats['total_tickets']?.toString() ?? '0',
                icon: Icons.local_activity,
                color: Colors.blue,
              ),
              CompactStatCard(
                title: 'Premios ganados',
                value: controller.userStats['prizes_won']?.toString() ?? '0',
                icon: Icons.emoji_events,
                color: Colors.amber,
              ),
              CompactStatCard(
                title: 'Total invertido',
                value: '€${(controller.userStats['total_spent'] as double?)?.toStringAsFixed(2) ?? '0.00'}',
                icon: Icons.account_balance_wallet,
                color: Colors.green,
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildProfileOptions(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          _buildOptionTile(
            theme,
            'Mis sorteos',
            'Ver sorteos en los que participo',
            Icons.confirmation_number,
            controller.viewMyRaffles,
          ),
          _buildDivider(theme),
          _buildOptionTile(
            theme,
            'Historial de depósitos',
            'Ver mis depósitos y retiros',
            Icons.account_balance,
            controller.viewDepositHistory,
          ),
          _buildDivider(theme),
          _buildOptionTile(
            theme,
            'Métodos de pago',
            'Gestionar mis métodos de pago',
            Icons.payment,
            controller.managePaymentMethods,
          ),
          _buildDivider(theme),
          _buildOptionTile(
            theme,
            'Notificaciones',
            'Configurar notificaciones',
            Icons.notifications,
            controller.configureNotifications,
          ),
        ],
      ),
    );
  }

  Widget _buildSettings(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Configuración',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Tema oscuro/claro
          Obx(() => SwitchListTile(
            title: const Text('Tema oscuro'),
            subtitle: const Text('Cambiar entre tema claro y oscuro'),
            value: controller.isDarkMode,
            onChanged: (_) => controller.toggleDarkMode(),
            secondary: Icon(
              controller.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
          )),
          
          _buildDivider(theme),
          
          // Notificaciones push
          Obx(() => SwitchListTile(
            title: const Text('Notificaciones push'),
            subtitle: const Text('Recibir notificaciones en el dispositivo'),
            value: controller.pushNotificationsEnabled,
            onChanged: (value) => controller.togglePushNotifications(value),
            secondary: const Icon(Icons.notifications_active),
          )),
          
          _buildDivider(theme),
          
          // Notificaciones por email
          Obx(() => SwitchListTile(
            title: const Text('Notificaciones por email'),
            subtitle: const Text('Recibir notificaciones por correo'),
            value: controller.emailNotificationsEnabled,
            onChanged: (value) => controller.toggleEmailNotifications(value),
            secondary: const Icon(Icons.email),
          )),
          
          _buildDivider(theme),
          
          // Biometría
          Obx(() => SwitchListTile(
            title: const Text('Autenticación biométrica'),
            subtitle: const Text('Usar huella dactilar o Face ID'),
            value: controller.biometricEnabled,
            onChanged: (value) => controller.toggleBiometric(value),
            secondary: const Icon(Icons.fingerprint),
          )),
        ],
      ),
    );
  }

  Widget _buildAccountInfo(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Información de la cuenta',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Usar un solo Obx para toda la sección de información
          Obx(() => Column(
            children: [
              _buildInfoRow(
                theme,
                'Miembro desde',
                controller.user?.createdAt != null ? controller.formatDate(controller.user!.createdAt) : 'N/A',
                Icons.calendar_today,
              ),
              
              _buildInfoRow(
                theme,
                'Último acceso',
                controller.user?.lastLogin != null ? controller.formatDate(controller.user!.lastLogin!) : 'N/A',
                Icons.access_time,
              ),
              
              _buildInfoRow(
                theme,
                'Estado de la cuenta',
                controller.user?.emailVerified == true ? 'Verificada' : 'Pendiente',
                controller.user?.emailVerified == true ? Icons.verified : Icons.pending,
              ),
              
              _buildInfoRow(
                theme,
                'Nivel de usuario',
                'Básico', // Level is not in UserModel, defaulting to 'Básico'
                Icons.star,
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildAccountActions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CustomButton(
            text: 'Cambiar contraseña',
            onPressed: controller.changePassword,
            type: ButtonType.outlined,
            width: double.infinity,
            icon: Icons.lock,
          ),
          
          const SizedBox(height: 12),
          
          CustomButton(
            text: 'Verificar cuenta',
            onPressed: controller.verifyAccount,
            type: ButtonType.secondary,
            width: double.infinity,
            icon: Icons.verified_user,
          ),
          
          const SizedBox(height: 12),
          
          CustomButton(
            text: 'Exportar datos',
            onPressed: controller.exportData,
            type: ButtonType.flat,
            width: double.infinity,
            icon: Icons.download,
          ),
          
          const SizedBox(height: 24),
          
          CustomButton(
            text: 'Cerrar sesión',
            onPressed: controller.logout,
            type: ButtonType.danger,
            width: double.infinity,
            icon: Icons.logout,
          ),
          
          const SizedBox(height: 12),
          
          TextButton(
            onPressed: controller.deleteAccount,
            child: Text(
              'Eliminar cuenta',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: theme.colorScheme.primary,
      ),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    String label,
    String? value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 1,
      color: theme.colorScheme.outline.withOpacity(0.2),
    );
  }
}

// Pantalla de edición de perfil
class EditProfileView extends GetView<ProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: controller.saveProfile,
            child: Obx(() => controller.isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar')),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            Center(
              child: GestureDetector(
                onTap: controller.changeAvatar,
                child: Stack(
                  children: [
                    Obx(() => CircleAvatar(
                      radius: 60,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      backgroundImage: controller.user?.avatar != null
                          ? NetworkImage(controller.user!.avatar!)
                          : null,
                      child: controller.user?.avatar == null
                          ? Icon(
                              Icons.person,
                              size: 60,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                    )),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.surface,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Formulario
            Form(
              key: controller.formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: controller.nameController,
                    label: 'Nombre completo',
                    hint: 'Ingresa tu nombre completo',
                    prefixIcon: Icons.person,
                    validator: controller.validateName,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    controller: controller.emailController,
                    label: 'Correo electrónico',
                    hint: 'Ingresa tu email',
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: controller.validateEmail,
                    readOnly: true, // Email no se puede cambiar
                  ),
                  
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    controller: controller.phoneController,
                    label: 'Teléfono',
                    hint: 'Ingresa tu número de teléfono',
                    prefixIcon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: controller.validatePhone,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    controller: controller.bioController,
                    label: 'Biografía',
                    hint: 'Cuéntanos algo sobre ti (opcional)',
                    prefixIcon: Icons.info,
                    maxLines: 3,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Información adicional
                  Container(
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
                              Icons.info,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Información importante',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• El correo electrónico no se puede modificar\n'
                          '• Los cambios se aplicarán inmediatamente\n'
                          '• Tu información está protegida y segura',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 