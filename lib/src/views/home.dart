import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:inventora_app/src/views/inventario.dart';
import 'package:inventora_app/src/views/alertas_notif.dart';
import 'package:inventora_app/src/views/prediccion.dart';
import 'package:provider/provider.dart';
import 'package:inventora_app/src/models/stats_model.dart';
import 'package:inventora_app/src/controllers/product_controller.dart';
import 'package:inventora_app/src/views/sales_history_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ⛔ 1. ELIMINAMOS LA VARIABLE DE ESTADO LOCAL
  // String selectedPeriod = 'Semana';
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    const darkBackgroundColor = Color(0xFF1C1C2D);
    
    return Consumer<ProductController>(
      builder: (context, productController, child) {
        final int totalAlerts = productController.products.where((p) => p.status == 'Bajo' || p.status == 'Crítico').length;
        
        return Scaffold(
          backgroundColor: darkBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: Container(
                      color: const Color(0xFFF4F6FA),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            _buildDashboardTitle(), // <--- Esta función llama a _buildPeriodButton
                            const SizedBox(height: 20),
                            
                            if (productController.isLoading && productController.products.isEmpty)
                              const Center(child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(),
                              ))
                            else if (productController.errorMessage != null && productController.products.isEmpty)
                              Center(child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text('Error: ${productController.errorMessage}'),
                              ))
                            else
                              Column(
  children: [
    _buildMetricsCards(productController),

    const SizedBox(height: 24),

    // -------------------------------
    //  NUEVA SECCIÓN: GRÁFICA DE HISTORIAL
    // -------------------------------
  Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Historial de Ventas (Automático)",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // ✔ GRÁFICA: siempre mostrará el primer producto de la BD
          if (productController.products.isNotEmpty)
            SalesHistoryChart(
              producto: productController.products.first.name,
            )
          else
            const Text("Cargando productos..."),
        ],
      ),
    ),

    const SizedBox(height: 24),

    _buildCategoryDistribution(),
    const SizedBox(height: 24),
    _buildInventoryStatus(),
    const SizedBox(height: 80),
  ],
)

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(totalAlerts),
        );

      },
    );
  }

  Widget _buildHeader() {
    // ... (Tu código de Header - sin cambios)
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
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
                    'InventorApp',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Hola, Administrador',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Inicio',
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                _buildPeriodButton('Día'),
                _buildPeriodButton('Semana'),
                _buildPeriodButton('Mes'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ 2. REEMPLAZA _buildPeriodButton
  Widget _buildPeriodButton(String period) {
    // Leemos el período actual desde el controller
    // Usamos 'context.watch' para que el botón SE REDIBUJE
    final controller = context.watch<ProductController>();
    final isSelected = controller.selectedPeriod == period;
    
    return GestureDetector(
      onTap: () {
        // Al tocar, le decimos al controller que cambie
        // Usamos 'context.read' dentro de un onTap
        context.read<ProductController>().changePeriod(period);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          period,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ✅ 3. REEMPLAZA _buildMetricsCards
  Widget _buildMetricsCards(ProductController productController) {
    
    final totalStock = productController.products.fold<int>(
      0, (sum, product) => sum + product.stock
    );
    final totalAlerts = productController.products
        .where((p) => p.status == 'Bajo' || p.status == 'Crítico')
        .length;
        
    final double salesData = productController.salesData;
    final String salesPeriod = productController.selectedPeriod;
    
    // ✅ Leemos el nuevo valor de rotación
    final double rotation = productController.weeklyRotation;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.2,
        children: [
          _buildMetricCard(
            icon: Icons.attach_money,
            iconColor: const Color(0xFF4ADE80),
            value: 'S/ ${salesData.toStringAsFixed(2)}', 
            label: 'Ventas del $salesPeriod',
            percentage: '+0.0%',
            isPositive: true,
          ),
          _buildMetricCard(
            icon: Icons.inventory_2_outlined,
            iconColor: const Color(0xFF60A5FA),
            value: totalStock.toString(), 
            label: 'Unidades en Stock',
            percentage: '',
            isPositive: true,
          ),
          
          // --- TARJETA DE ROTACIÓN ACTUALIZADA ---
          _buildMetricCard(
            icon: Icons.trending_up,
            iconColor: const Color(0xFFF472B6),
            // ✅ Dato real (formateado a 1 decimal)
            value: '${rotation.toStringAsFixed(1)}%', 
            label: 'Rotación Semanal',
            percentage: '', // Ya no necesitamos el % secundario
            isPositive: true,
          ),
          
          _buildMetricCard(
            icon: Icons.warning_amber_outlined,
            iconColor: const Color(0xFFFBBF24),
            value: totalAlerts.toString(), 
            label: 'Alertas Activas',
            percentage: '',
            isPositive: false,
            showBadge: totalAlerts > 0,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required String percentage,
    required bool isPositive,
    bool showBadge = false,
  }) {
    // ... (Tu código de MetricCard - sin cambios)
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              if (percentage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPositive && !showBadge
                        ? const Color(0xFF4ADE80).withOpacity(0.1)
                        : const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    percentage,
                    style: TextStyle(
                      color: isPositive && !showBadge
                          ? const Color(0xFF4ADE80)
                          : const Color(0xFFEF4444),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalesChart() {
    // ... (Tu código de SalesChart - sin cambios, Oculto)
    return Container();
  }

  BarChartGroupData _makeGroupData(int x, double y1, double y2) {
    // ... (Tu código de GroupData - sin cambios)
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: const Color(0xFF8B5CF6),
          width: 12,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
        BarChartRodData(
          toY: y2,
          color: const Color(0xFF4ADE80),
          width: 12,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildHighRotationProducts() {
    // ... (Tu código de HighRotation - sin cambios, Oculto)
    return Container();
  }

  Widget _buildProductProgress(String name, int current, int total) {
    // ... (Tu código de ProductProgress - sin cambios)
    final percentage = (current / total);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$current/$total',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDistribution() {
    // ... (Tu código de CategoryDistribution - sin cambios)
    final controller = context.read<ProductController>();
    final List<CategoryDistribution> data = controller.categoriesDistribution;
    if (data.isEmpty) {
    return Container(); 
  }
  
  final List<Color> colors = [
    const Color(0xFF8B5CF6),
    const Color(0xFF4ADE80),
    const Color(0xFFFBBF24),
    const Color(0xFFF97316),
    const Color(0xFF60A5FA),
  ];
    return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Distribución por Categorías',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              sections: List.generate(data.length, (i) {
                final item = data[i];
                final color = colors[i % colors.length];
                return PieChartSectionData(
                  value: item.count.toDouble(),
                  title: '${item.count}', 
                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  color: color,
                  radius: 50,
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: List.generate(data.length, (i) {
             final item = data[i];
             final color = colors[i % colors.length];
             return _buildLegendItem(item.name, '${item.count} unid.', color);
          }),
        ),
      ],
    ),
  );
}

  Widget _buildLegendItem(String label, String percentage, Color color) {
    // ... (Tu código de LegendItem - sin cambios)
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ($percentage)',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildInventoryStatus() {
    // ... (Tu código de InventoryStatus - sin cambios)
    final controller = context.read<ProductController>();
    final int lowStockCount = controller.products
      .where((p) => p.status == 'Bajo' || p.status == 'Crítico')
      .length;
      
  final int optimalCount = controller.products
      .where((p) => p.status == 'Óptimo')
      .length;
      
  final double optimalPercentage = (controller.products.isEmpty)
      ? 0.0
      : (optimalCount / controller.products.length) * 100;
    
    return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estado del Inventario',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildStatusCard(
          icon: Icons.warning_amber_rounded,
          iconColor: const Color(0xFFEF4444),
          bgColor: const Color(0xFFFEE2E2),
          title: 'Stock Bajo / Crítico',
          subtitle: '$lowStockCount productos necesitan reabastecimiento',
        ),
        const SizedBox(height: 12),
        _buildStatusCard(
          icon: Icons.schedule,
          iconColor: const Color(0xFFFBBF24),
          bgColor: const Color(0xFFFEF3C7),
          title: 'Próximos a Vencer',
          subtitle: '0 productos (Función no implementada)',
        ),
        const SizedBox(height: 12),
        _buildStatusCard(
          icon: Icons.check_circle_outline,
          iconColor: const Color(0xFF4ADE80),
          bgColor: const Color(0xFFD1FAE5),
          title: 'Inventario Óptimo',
          subtitle: '${optimalPercentage.toStringAsFixed(0)}% de productos en nivel ideal',
        ),
      ],
    ),
  );
}

  Widget _buildStatusCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
  }) {
    // ... (Tu código de StatusCard - sin cambios)
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(int totalAlerts) {
    // ... (Tu código de BottomNav - sin cambios)
     return Container(
      decoration: BoxDecoration(
        color: Colors.black, // Fondo negro
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
              _buildNavItem(Icons.home, 'Inicio', 0,totalAlerts),
              _buildNavItem(Icons.inventory_2_outlined, 'Inventario', 1,totalAlerts),
              _buildNavItem(Icons.trending_up, 'Predicción', 2,totalAlerts),
              _buildNavItem(Icons.notifications_outlined, 'Alertas', 3,totalAlerts),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, int totalAlerts) {
    // ... (Tu código de NavItem - sin cambios)
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
              MaterialPageRoute(builder: (context) => const PrediccionPage()),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            // ✅ ENVUELVE EL ICONO CON UN STACK
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.black : Colors.white,
                  size: 24,
                ),
                // ✅ LÓGICA DEL BADGE
                if (index == 3 && totalAlerts > 0)
                  Positioned(
                    right: -25, // Ajusta esto para tu diseño
                    top: -10,   // Ajusta esto para tu diseño
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444), // Rojo
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
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
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}