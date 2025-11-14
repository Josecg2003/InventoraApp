import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
// Importación del archivo 'inventario.dart' dentro de views
import 'package:inventora_app/src/views/inventario.dart'; 
// CORRECCIÓN: Importación del archivo 'prediccion.dart' dentro de views
import 'package:inventora_app/src/views/prediccion.dart'; // Asume que la clase es PrediccionPage
// Importación del controlador de la carpeta 'controllers'
import '../controllers/prediccion_inventario_controller.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedPeriod = 'Semana';
  int _selectedIndex = 0;

  // 🔹 Instancia del controlador de predicción
  final _prediccionController = PrediccionInventarioController();
  
  // --- Las listas y widgets de contenido van aquí ---

  @override
  Widget build(BuildContext context) {
    // Color principal oscuro del fondo
    const darkBackgroundColor = Color(0xFF1C1C2D);
    
    return Scaffold(
      backgroundColor: darkBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Content
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: Container(
                  color: const Color(0xFFF4F6FA), // Color de fondo para el contenido
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildDashboardTitle(),
                        const SizedBox(height: 20),
                        _buildMetricsCards(),
                        const SizedBox(height: 24),
                        _buildSalesChart(),
                        const SizedBox(height: 16),

                        // 🔹 Botón de predicción IA (CORRECCIÓN 1: De llamada a Navegación)
                        Center(
                          child: ElevatedButton.icon(
                            // ❌ ESTA LÍNEA ES LA QUE REEMPLAZAMOS: onPressed: () => _prediccionController.predecir(context),
                            onPressed: () { // ⬅️ CORRECCIÓN: Navega a la página de formulario
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const PrediccionPage()), 
                              );
                              // Opcional: Actualizar el índice para resaltar el ícono inferior
                              setState(() {
                                 _selectedIndex = 2; // Índice de Predicción
                              });
                            },
                            icon: const Icon(Icons.analytics_outlined, color: Colors.white),
                            label: const Text(
                              'Predecir Demanda',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                        _buildHighRotationProducts(),
                        const SizedBox(height: 24),
                        _buildCategoryDistribution(),
                        const SizedBox(height: 24),
                        _buildInventoryStatus(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // --- MÉTODOS DE CONSTRUCCIÓN (Widgets existentes) ---

  // (Todos los demás widgets intermedios como _buildHeader, _buildDashboardTitle, etc. van aquí)
  
  // (Debes pegar todos tus métodos auxiliares aquí: _makeGroupData, _buildMetricCard, _buildPeriodButton, etc.)

  Widget _buildHeader() {
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
                    'Inventario Pro',
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
            'Dashboard',
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

  Widget _buildPeriodButton(String period) {
    final isSelected = selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPeriod = period;
        });
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

  Widget _buildMetricsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.5,
        children: [
          _buildMetricCard(
            icon: Icons.attach_money,
            iconColor: const Color(0xFF4ADE80),
            value: '\$12,450',
            label: 'Ventas del Día',
            percentage: '+8.2%',
            isPositive: true,
          ),
          _buildMetricCard(
            icon: Icons.inventory_2_outlined,
            iconColor: const Color(0xFF60A5FA),
            value: '1,234',
            label: 'Productos en Stock',
            percentage: '-2.1%',
            isPositive: false,
          ),
          _buildMetricCard(
            icon: Icons.trending_up,
            iconColor: const Color(0xFFF472B6),
            value: '89%',
            label: 'Rotación Semanal',
            percentage: '+5.3%',
            isPositive: true,
          ),
          _buildMetricCard(
            icon: Icons.warning_amber_outlined,
            iconColor: const Color(0xFFFBBF24),
            value: '7',
            label: 'Alertas Activas',
            percentage: '+3',
            isPositive: false,
            showBadge: true,
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
    // Lógica para determinar el color del porcentaje/badge (mejorado para alertas)
    Color percentColor;
    Color percentBgColor;

    if (showBadge && !isPositive) {
      // Caso de Alerta
      percentColor = const Color(0xFFFBBF24); // Amarillo de alerta
      percentBgColor = const Color(0xFFFBBF24).withOpacity(0.1);
    } else if (isPositive) {
      // Caso Positivo
      percentColor = const Color(0xFF4ADE80); // Verde
      percentBgColor = const Color(0xFF4ADE80).withOpacity(0.1);
    } else {
      // Caso Negativo
      percentColor = const Color(0xFFEF4444); // Rojo
      percentBgColor = const Color(0xFFEF4444).withOpacity(0.1);
    }

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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: percentBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  percentage,
                  style: TextStyle(
                    color: percentColor,
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
          const Row(
            children: [
              Icon(Icons.bar_chart, size: 20),
              SizedBox(width: 8),
              Text(
                'Ventas vs Predicción',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 6000,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sáb', 'Dom'];
                        return Text(
                          days[value.toInt()],
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value % 1500 == 0) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1500,
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeGroupData(0, 4000, 4200),
                  _makeGroupData(1, 3000, 3200),
                  _makeGroupData(2, 2000, 2400),
                  _makeGroupData(3, 2800, 3000),
                  _makeGroupData(4, 2000, 2200),
                  _makeGroupData(5, 2500, 2800),
                  _makeGroupData(6, 3200, 3500),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y1, double y2) {
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
            'Productos de Alta Rotación',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildProductProgress('Producto A', 23, 45),
          const SizedBox(height: 12),
          _buildProductProgress('Producto B', 18, 32),
          const SizedBox(height: 12),
          _buildProductProgress('Producto C', 15, 28),
          const SizedBox(height: 12),
          _buildProductProgress('Producto D', 12, 15),
        ],
      ),
    );
  }

  Widget _buildProductProgress(String name, int current, int total) {
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
                sections: [
                  PieChartSectionData(
                    value: 35,
                    title: '',
                    color: const Color(0xFF8B5CF6),
                    radius: 50,
                  ),
                  PieChartSectionData(
                    value: 25,
                    title: '',
                    color: const Color(0xFF4ADE80),
                    radius: 50,
                  ),
                  PieChartSectionData(
                    value: 20,
                    title: '',
                    color: const Color(0xFFFBBF24),
                    radius: 50,
                  ),
                  PieChartSectionData(
                    value: 20,
                    title: '',
                    color: const Color(0xFFF97316),
                    radius: 50,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendItem('Electrónicos', '35%', const Color(0xFF8B5CF6)),
              _buildLegendItem('Ropa', '25%', const Color(0xFF4ADE80)),
              _buildLegendItem('Hogar', '20%', const Color(0xFFFBBF24)),
              _buildLegendItem('Deportes', '20%', const Color(0xFFF97316)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String percentage, Color color) {
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
          '$label $percentage',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildInventoryStatus() {
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
            title: 'Stock Bajo',
            subtitle: '3 productos necesitan reabastecimiento',
          ),
          const SizedBox(height: 12),
          _buildStatusCard(
            icon: Icons.schedule,
            iconColor: const Color(0xFFFBBF24),
            bgColor: const Color(0xFFFEF3C7),
            title: 'Próximos a Vencer',
            subtitle: '2 productos vencen esta semana',
          ),
          const SizedBox(height: 12),
          _buildStatusCard(
            icon: Icons.check_circle_outline,
            iconColor: const Color(0xFF4ADE80),
            bgColor: const Color(0xFFD1FAE5),
            title: 'Inventario Óptimo',
            subtitle: '89% de productos en nivel ideal',
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
  
  Widget _buildBottomNavigationBar() {
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
              _buildNavItem(Icons.home, 'Inicio', 0),
              _buildNavItem(Icons.inventory_2_outlined, 'Inventario', 1),
              _buildNavItem(Icons.trending_up, 'Predicción', 2),
              _buildNavItem(Icons.notifications_outlined, 'Alertas', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        // Lógica de navegación
        if (_selectedIndex != index) {
          if (index == 1) { // Navegar a Inventario
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const InventoryScreen()),
            ).then((_) {
              // Vuelve a Inicio cuando se regresa
              setState(() {
                _selectedIndex = 0; 
              });
            });
          } else if (index == 2) { // Navegar a Predicción (CORRECCIÓN 2: Nombre de la clase)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PrediccionPage()), // ⬅️ CORRECCIÓN: Usar PrediccionPage
            ).then((_) {
              // Vuelve a Inicio cuando se regresa
              setState(() {
                _selectedIndex = 0;
              });
            });
          } else {
            // Para otros íconos (Inicio y Alertas), solo actualizamos el estado
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
            child: Icon(
              icon,
              color: isSelected ? Colors.black : Colors.white,
              size: 24,
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
  }}