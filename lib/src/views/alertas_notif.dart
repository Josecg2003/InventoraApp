import 'package:flutter/material.dart';
import 'package:inventora_app/src/views/login.dart';
// ✅ 1. IMPORTACIONES AÑADIDAS
import 'package:provider/provider.dart';
import 'package:inventora_app/src/controllers/product_controller.dart';
import 'package:inventora_app/src/views/prediccion.dart';
import 'package:inventora_app/src/models/product_model.dart';
import 'package:inventora_app/src/views/home.dart';
import 'package:inventora_app/src/views/inventario.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 3; // Alertas seleccionado

  // ⛔ 2. ELIMINAMOS ESTAS VARIABLES (AHORA VIENEN DEL CONTROLLER)
  // int unreadNotifications = 3;
  // int highPriorityCount = 2;
// ✅ Función para mostrar el diálogo y cerrar sesión
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas salir?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cierra el diálogo
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              // 1. Cierra el diálogo
              Navigator.pop(context);
              
              // 2. Navega al Login y BORRA el historial anterior
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()), 
                (Route<dynamic> route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444), // Rojo para indicar salida
              foregroundColor: Colors.white,
            ),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 3. LEEMOS EL CONTROLADOR Y CALCULAMOS LOS DATOS
    final controller = context.watch<ProductController>();
    
    // Filtramos solo los productos que son alertas
    final List<Product> alertProducts = controller.products.where((p) {
      return p.status == 'Bajo' || p.status == 'Crítico';
    }).toList();
    
    // Contamos cuántos son de alta prioridad (Crítico)
    final int criticalStockCount = alertProducts
        .where((p) => p.status == 'Crítico')
        .length;
    
    // El total de alertas
    final int totalAlerts = alertProducts.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // ✅ 4. PASAMOS LOS DATOS A LOS WIDGETS HIJOS
          _buildHeader(totalAlerts, criticalStockCount),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAlertsTab(alertProducts), // <-- Pasamos la lista filtrada
                _buildHistoryTab(),
                _buildConfigTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(totalAlerts), // <-- Pasamos el conteo
    );
  }

    PreferredSizeWidget _buildAppBar() {
    // ... (Tu código de AppBar - sin cambios)
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      elevation: 0,
      // ✅ Hacemos que el botón "Home" funcione
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'InventarApp',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Alertas y Notificaciones',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
            icon: const Icon(Icons.logout, color: Colors.white), // Cambié el icono a 'logout' para que sea más claro
            tooltip: 'Cerrar Sesión',
            onPressed: _showLogoutDialog, // <-- Llamamos a la función
          ),
      ],
    );
  }

  // ✅ 5. ACTUALIZAMOS EL HEADER PARA USAR DATOS REALES
Widget _buildHeader(int totalAlerts, int criticalCount) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ✅ 1. Envolvemos la Columna en Expanded
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notificaciones',
                  style: TextStyle(
                    fontSize: 22, // Puedes bajar a 20 si sigue muy grande
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A0E27),
                  ),
                ),
                const SizedBox(height: 4),
                // Usamos Wrap para que si no cabe en una línea, baje
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '$totalAlerts alertas', // Texto más corto
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const Text(' • ', style: TextStyle(color: Colors.grey)),
                    Text(
                      '$criticalCount prioridad', // Texto más corto
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ✅ 2. Botón con texto más corto o ajustado
          TextButton(
            onPressed: _markAllAsRead,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8), // Menos padding
              minimumSize: Size.zero, // Ocupar menos espacio
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Marcar leídas', // Texto más corto para que quepa
              style: TextStyle(
                color: Color(0xFF0A0E27),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    // ... (Tu código de TabBar no necesita cambios)
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color.fromARGB(255, 0, 0, 0),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color.fromARGB(255, 0, 0, 0),
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Alertas'),
          Tab(text: 'Historial'),
          Tab(text: 'Configuración'),
        ],
      ),
    );
  }

  // ✅ 6. ACTUALIZAMOS EL TAB DE ALERTAS
  Widget _buildAlertsTab(List<Product> alertProducts) {
    // Obtenemos los conteos de la lista ya filtrada
    final lowStockCount = alertProducts
        .where((p) => p.status == 'Bajo')
        .length;
    final criticalStockCount = alertProducts
        .where((p) => p.status == 'Crítico')
        .length;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildSummaryCards(lowStockCount, criticalStockCount), // <-- Pasamos datos
          const SizedBox(height: 20),
          _buildAlertsList(alertProducts), // <-- Pasamos datos
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ✅ 7. ACTUALIZAMOS LAS TARJETAS DE RESUMEN
  Widget _buildSummaryCards(int lowStockCount, int criticalStockCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.9,
        children: [
          _buildSummaryCard(
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFFBBF24),
            bgColor: const Color(0xFFFEF3C7),
            // ✅ DATO REAL
            number: (lowStockCount + criticalStockCount).toString(),
            title: 'Stock Bajo/Crítico',
            subtitle: 'Productos necesitan\nreabastecimiento',
          ),
          _buildSummaryCard(
            icon: Icons.event_outlined,
            iconColor: const Color(0xFFEF4444),
            bgColor: const Color(0xFFFEE2E2),
            // (Dato estático por ahora)
            number: '0',
            title: 'Próximos a Vencer',
            subtitle: '',
          ),
          _buildSummaryCard(
            icon: Icons.trending_up,
            iconColor: const Color(0xFF60A5FA),
            bgColor: const Color(0xFFDBEAFE),
            number: '0',
            title: 'Sugerencias de\nPedido',
            subtitle: '',
          ),
          _buildSummaryCard(
            icon: Icons.show_chart,
            iconColor: const Color(0xFFF472B6),
            bgColor: const Color(0xFFFCE7F3),
            number: '0',
            title: 'Variaciones de\nDesempeño',
            subtitle: '',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    // ... (Tu código de SummaryCard no necesita cambios)
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String number,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                number,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 0, 0, 0),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black54,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ 8. ACTUALIZAMOS LA LISTA DE ALERTAS
  Widget _buildAlertsList(List<Product> alertProducts) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Productos con Stock Bajo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // --- REEMPLAZAMOS LOS ITEMS ESTÁTICOS ---
          if (alertProducts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  '¡Todo bien! No hay alertas de stock.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: alertProducts.length,
              itemBuilder: (context, index) {
                final product = alertProducts[index];
                final isCritico = product.status == 'Crítico';
                
                return _buildAlertItem(
                  productName: product.name,
                  stock: product.stock,
                  minStock: product.stockMinimo ?? 0,
                  status: product.status,
                  statusColor: isCritico ? const Color(0xFFEF4444) : const Color(0xFFFBBF24),
                );
              },
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, indent: 16, endIndent: 16),
            ),
          // --- FIN DEL REEMPLAZO ---
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAlertItem({
    // ... (Tu código de AlertItem no necesita cambios)
    required String productName,
    required int stock,
    required int minStock,
    required String status,
    required Color statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stock: $stock • Mínimo: $minStock',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              // TODO: Implementar lógica de Reordenar
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              elevation: 0,
            ),
            child: const Text(
              'Reordenar',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    // ... (Tu código de HistoryTab no necesita cambios)
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Historial de notificaciones',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Próximamente',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigTab() {
    // ... (Tu código de ConfigTab no necesita cambios)
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Preferencias de Notificaciones',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        const SizedBox(height: 16),
        _buildConfigItem(
          'Stock bajo',
          'Recibir alertas cuando productos estén por debajo del mínimo',
          true,
        ),
        _buildConfigItem(
          'Productos próximos a vencer',
          'Notificar cuando productos estén cerca de su fecha de vencimiento',
          true,
        ),
        _buildConfigItem(
          'Sugerencias de pedido',
          'Recibir recomendaciones automáticas de reabastecimiento',
          true,
        ),
        _buildConfigItem(
          'Variaciones de desempeño',
          'Alertas sobre cambios significativos en ventas o inventario',
          false,
        ),
        const SizedBox(height: 24),
        const Text(
          'Frecuencia de Notificaciones',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        const SizedBox(height: 16),
        _buildFrequencyOption('Inmediato', true),
        _buildFrequencyOption('Cada hora', false),
        _buildFrequencyOption('Diario', false),
      ],
    );
  }

  Widget _buildConfigItem(String title, String subtitle, bool value) {
    // ... (Tu código de ConfigItem no necesita cambios)
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (val) {},
            activeColor: const Color.fromARGB(255, 0, 0, 0),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyOption(String title, bool selected) {
    // ... (Tu código de FrequencyOption no necesita cambios)
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? const Color.fromARGB(255, 0, 0, 0) : Colors.grey.shade200,
          width: selected ? 2 : 1,
        ),
      ),
      child: RadioListTile<bool>(
        title: Text(title),
        value: selected,
        groupValue: true,
        onChanged: (val) {},
        activeColor: const Color.fromARGB(255, 0, 0, 0),
      ),
    );
  }

  void _markAllAsRead() {
    // setState(() {
    //   // Esta variable local ya no existe.
    //   // La lógica de "no leído" debería vivir en el controlador.
    // });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Marcar como leído'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ✅ 9. ACTUALIZAMOS EL BOTTOMNAV
  Widget _buildBottomNavigationBar(int totalAlerts) { // <-- Acepta el conteo
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 0, 0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Inicio', 0, totalAlerts),
              _buildNavItem(Icons.inventory_2_outlined, 'Inventario', 1, totalAlerts),
              _buildNavItem(Icons.trending_up, 'Predicción', 2, totalAlerts),
              _buildNavItem(Icons.notifications_outlined, 'Alertas', 3, totalAlerts),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, int totalAlerts) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
            onTap: () {
        if (_selectedIndex != index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const InventoryScreen()),
            ).then((_) {
              setState(() {
                _selectedIndex = 0;
              });
            });
          }
          else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PredictionScreen()),
            ).then((_) {
              setState(() {
                _selectedIndex = 0;
              });
            });
          }
          else if (index == 3) { 
          // ✅ IR A ALERTAS
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationsScreen()),
          ).then((_) {
            // Cuando regrese, resetea el ícono a "Inicio" (index 0)
            setState(() { _selectedIndex = 0; });
          });
        }
          else {
            setState(() {
              _selectedIndex = index;
            });
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected ? const Color.fromARGB(255, 0, 0, 0) : Colors.white,
                  size: 24,
                ),
                // ✅ DATO REAL
                if (index == 3 && totalAlerts > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        // ✅ DATO REAL
                        '$totalAlerts',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                // ✅ El label seleccionado debe ser oscuro
                color: isSelected ? const Color.fromARGB(255, 0, 0, 0) : Colors.white,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}