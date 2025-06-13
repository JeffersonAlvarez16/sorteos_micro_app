import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../widgets/raffle_card.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Configurar el estilo de la barra de estado para un look minimalista
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    
    return Scaffold(
      backgroundColor: Colors.grey[50], // Color de fondo muy sutil
      body: RefreshIndicator(
        color: Colors.black54, // Color sobrio para el indicador de recarga
        onRefresh: controller.refreshData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(theme),
            
            // Estadísticas rápidas con diseño minimalista
            SliverToBoxAdapter(
              child: _buildQuickStats(theme),
            ),
            
            // Filtros con diseño minimalista
            SliverToBoxAdapter(
              child: _buildFiltersSection(theme),
            ),
            
            // Lista de sorteos con diseño minimalista
            _buildRafflesList(),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
  
  // AppBar minimalista con título simple y botones
  SliverAppBar _buildAppBar(ThemeData theme) {
    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: Colors.white,
      title: Text(
        'Sorteos',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black54),
          onPressed: () => Get.toNamed('/search'),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.black54),
          onPressed: controller.goToNotifications,
        ),
      ],
    );
  }

  // Estadísticas rápidas del usuario
  Widget _buildQuickStats(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Participaciones',
              '${controller.userParticipationsCount}',
              Icons.confirmation_number_outlined,
              theme,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Saldo',
              '\$${controller.userBalance.toStringAsFixed(2)}',
              Icons.account_balance_wallet_outlined,
              theme,
            ),
          ),
        ],
      ),
    );
  }

  // Tarjeta individual de estadística
  Widget _buildStatCard(String title, String value, IconData icon, ThemeData theme) {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: Colors.black54, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sección de filtros
  Widget _buildFiltersSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categorías',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Todos', 'all', theme),
                _buildFilterChip('Activos', 'active', theme),
                _buildFilterChip('Completados', 'completed', theme),
                _buildFilterChip('Mis participaciones', 'my_participations', theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Chip de filtro individual
  Widget _buildFilterChip(String label, String filterValue, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Obx(() => ChoiceChip(
        label: Text(label),
        selected: controller.selectedFilter == filterValue,
        selectedColor: Colors.black12,
        backgroundColor: Colors.grey[100],
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: controller.selectedFilter == filterValue ? Colors.black87 : Colors.black54,
        ),
        onSelected: (_) => controller.setFilter(filterValue),
      )),
    );
  }

  // Lista de sorteos
  Widget _buildRafflesList() {
    return Obx(() {
      if (controller.isLoading && controller.filteredRaffles.isEmpty) {
        return const SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
            ),
          ),
        );
      }
      
      if (controller.filteredRaffles.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay sorteos disponibles',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Intenta más tarde o cambia los filtros',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.all(16.0),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index >= controller.filteredRaffles.length) {
                return null;
              }
              
              final raffle = controller.filteredRaffles[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: RaffleCard(raffle: raffle),
              );
            },
            childCount: controller.filteredRaffles.length,
          ),
        ),
      );
    });
  }

  // Botón flotante para hacer depósitos
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: Colors.black87,
      elevation: 2,
      child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
      onPressed: () => Get.toNamed('/deposit'),
    );
  }

  // Barra de navegación inferior
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: Colors.black87,
      unselectedItemColor: Colors.black38,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined),
          activeIcon: Icon(Icons.explore),
          label: 'Explorar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            // Ya estamos en Home
            break;
          case 1:
            Get.toNamed('/explore');
            break;
          case 2:
            controller.goToProfile();
            break;
        }
      },
    );
  }
}
