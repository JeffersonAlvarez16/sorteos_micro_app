import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../widgets/raffle_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/custom_button.dart';
import '../widgets/stat_card.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: CustomScrollView(
          slivers: [
            // App Bar personalizado
            _buildSliverAppBar(theme),
            
            // Estadísticas rápidas
            SliverToBoxAdapter(
              child: _buildQuickStats(theme),
            ),
            
            // Filtros y búsqueda
            SliverToBoxAdapter(
              child: _buildFiltersSection(theme),
            ),
            
            // Lista de sorteos
            _buildRafflesList(theme),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(theme),
      bottomNavigationBar: _buildBottomNavigationBar(theme),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      flexibleSpace: FlexibleSpaceBar(
        title: Obx(() => Text(
          controller.isSearching.value ? 'Buscar sorteos' : 'Sorteos',
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
                theme.colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() => Text(
                          controller.getGreeting(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimary.withOpacity(0.9),
                          ),
                        )),
                      ),
                      IconButton(
                        onPressed: controller.goToNotifications,
                        icon: Stack(
                          children: [
                            Icon(
                              Icons.notifications_outlined,
                              color: theme.colorScheme.onPrimary,
                            ),
                            Obx(() => controller.hasUnreadNotifications.value
                              ? Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        Obx(() => IconButton(
          onPressed: controller.toggleSearch,
          icon: Icon(
            controller.isSearching.value ? Icons.close : Icons.search,
          ),
        )),
        PopupMenuButton<String>(
          onSelected: controller.handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'profile',
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text('Mi perfil'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'deposits',
              child: ListTile(
                leading: Icon(Icons.account_balance_wallet),
                title: Text('Mis depósitos'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'history',
              child: ListTile(
                leading: Icon(Icons.history),
                title: Text('Historial'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Configuración'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStats(ThemeData theme) {
    return Obx(() {
      if (controller.isLoadingStats.value) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: LoadingWidget(message: 'Cargando estadísticas...'),
        );
      }

      return Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: CompactStatCard(
                title: 'Sorteos activos',
                value: controller.activeRafflesCount.value.toString(),
                icon: Icons.celebration,
                color: Colors.green,
                onTap: () => controller.filterByStatus('active'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CompactStatCard(
                title: 'Mis participaciones',
                value: controller.userParticipationsCount.value.toString(),
                icon: Icons.confirmation_number,
                color: theme.colorScheme.primary,
                onTap: controller.goToMyParticipations,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CompactStatCard(
                title: 'Balance',
                value: '€${controller.userBalance.value.toStringAsFixed(2)}',
                icon: Icons.account_balance_wallet,
                color: Colors.blue,
                onTap: controller.goToDeposits,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFiltersSection(ThemeData theme) {
    return Obx(() => AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: controller.isSearching.value ? 120 : 60,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Barra de búsqueda
          if (controller.isSearching.value) ...[
            Container(
              height: 50,
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Buscar sorteos...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        onPressed: controller.clearSearch,
                        icon: const Icon(Icons.clear),
                      )
                    : const SizedBox.shrink()),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          
          // Filtros de estado
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('Todos', 'all', theme),
                const SizedBox(width: 8),
                _buildFilterChip('Activos', 'active', theme),
                const SizedBox(width: 8),
                _buildFilterChip('Completados', 'completed', theme),
                const SizedBox(width: 8),
                _buildFilterChip('Mis participaciones', 'my_participations', theme),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildFilterChip(String label, String value, ThemeData theme) {
    return Obx(() => FilterChip(
      label: Text(label),
      selected: controller.selectedFilter.value == value,
      onSelected: (_) => controller.setFilter(value),
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: controller.selectedFilter.value == value
          ? theme.colorScheme.primary
          : theme.colorScheme.onSurface,
        fontWeight: controller.selectedFilter.value == value
          ? FontWeight.w600
          : FontWeight.normal,
      ),
    ));
  }

  Widget _buildRafflesList(ThemeData theme) {
    return Obx(() {
      if (controller.isLoading.value && controller.filteredRaffles.isEmpty) {
        return const SliverFillRemaining(
          child: LoadingWidget(message: 'Cargando sorteos...'),
        );
      }

      if (controller.filteredRaffles.isEmpty) {
        if (controller.searchQuery.value.isNotEmpty) {
          return SliverFillRemaining(
            child: NoSearchResultsWidget(
              searchQuery: controller.searchQuery.value,
              onClearSearch: controller.clearSearch,
            ),
          );
        }
        
        return SliverFillRemaining(
          child: NoRafflesWidget(
            onRefresh: controller.refreshData,
          ),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == controller.filteredRaffles.length) {
              // Indicador de carga al final si hay más datos
              return Obx(() => controller.isLoadingMore.value
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: LoadingWidget(message: 'Cargando más sorteos...'),
                  )
                : const SizedBox.shrink());
            }

            final raffle = controller.filteredRaffles[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: RaffleCard(
                raffle: raffle,
                onTap: () => controller.goToRaffleDetail(raffle.id),
                showQuickBuy: true,
              ),
            );
          },
          childCount: controller.filteredRaffles.length + 1,
        ),
      );
    });
  }

  Widget _buildFloatingActionButton(ThemeData theme) {
    return Obx(() => FloatingActionCustomButton(
      onPressed: controller.goToDeposits,
      icon: Icons.add,
      tooltip: 'Hacer depósito',
      isExtended: !controller.isScrollingDown.value,
      label: 'Depositar',
      backgroundColor: theme.colorScheme.secondary,
    ));
  }

  Widget _buildBottomNavigationBar(ThemeData theme) {
    return Obx(() => BottomNavigationBar(
      currentIndex: controller.currentBottomNavIndex.value,
      onTap: controller.onBottomNavTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: theme.colorScheme.surface,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.celebration),
          label: 'Sorteos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Depósitos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    ));
  }
} 