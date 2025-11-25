import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inventora_app/src/controllers/prediccion_inventario_controller.dart';
import 'package:inventora_app/src/controllers/product_controller.dart';
import 'package:inventora_app/src/models/prediccion_model.dart';
import 'package:inventora_app/src/views/home.dart';
import 'package:inventora_app/src/views/inventario.dart';
import 'package:inventora_app/src/views/alertas_notif.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({Key? key}) : super(key: key);

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PredictionController>();
    final productController = context.watch<ProductController>();
    
    final int totalAlerts = productController.products
        .where((p) => p.status == 'Bajo' || p.status == 'Crítico')
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: _buildBody(controller),
      bottomNavigationBar: _buildBottomNavigationBar(totalAlerts),
    );
  }

  // ==================================================
  // 1. APP BAR
  // ==================================================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.inventory_2_outlined, 
              color: Colors.white, 
              size: 24
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inventora App', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)
              ),
              Text(
                'Predicción de la demanda', 
                style: TextStyle(fontSize: 11, color: Colors.white70)
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================================================
  // 2. BODY
  // ==================================================
  Widget _buildBody(PredictionController controller) {
    if (controller.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color.fromARGB(255, 0, 0, 0)),
            SizedBox(height: 16),
            Text("Analizando datos con IA...", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    if (controller.predictedData.isEmpty && !controller.isLoadingOptions) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildPredictionForm(controller),
            const SizedBox(height: 24),
            _buildEmptyState(),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildPredictionForm(controller),
          const SizedBox(height: 24),
          if (controller.predictedData.isNotEmpty)
            _buildChartCard(controller),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Configurar Predicción',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color.fromARGB(255, 0, 0, 0), letterSpacing: -0.5),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.5)),
          ),
          child: const Row(
            children: [
              Icon(Icons.auto_awesome, size: 12, color: Color(0xFF8B5CF6)),
              SizedBox(width: 4),
              Text('ML Activo', style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold, fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          children: [
            Icon(Icons.query_stats, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text("Configura los parámetros y pulsa 'Predecir'", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  // ==================================================
  // 3. FORMULARIO
  // ==================================================
  Widget _buildPredictionForm(PredictionController controller) {
    if (controller.isLoadingOptions) {
      return const Center(child: Text("Cargando productos..."));
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdown("Producto", controller.selectedProducto, controller.listProductos, (v) => controller.setProducto(v)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildInput("Precio (S/)", Icons.attach_money, controller.precioController)),
              const SizedBox(width: 16),
              Expanded(child: _buildInput("Stock Actual", Icons.inventory_2_outlined, controller.stockController)),
            ],
          ),
          const SizedBox(height: 16),
          _buildDropdown("Temporada", controller.selectedTemporada, controller.listTemporadas, (v) => controller.setTemporada(v)),
          const SizedBox(height: 16),
          const Text("¿Producto en oferta?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Row(
            children: [
              _buildRadio("No", 0, controller),
              _buildRadio("Sí", 1, controller),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.isLoading ? null : () => controller.makePrediction(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A0E27),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.auto_awesome),
              label: const Text("Predecir Demanda", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================
  // 4. GRÁFICO Y RESULTADOS (ESTILO RESTAURADO)
  // ==================================================
  // ==================================================
  // 4. GRÁFICO Y RESULTADOS (CORREGIDO CON HEADER Y STOCK)
  // ==================================================
  Widget _buildChartCard(PredictionController controller) {
    // Definimos el color azul objetivo
    const Color targetBlue = Color(0xFF8B5CF6); // Morado/Azul (El de tu diseño)

    double minY = 999999;
    double maxY = 0;
    for (var p in controller.predictedData) {
      if (p.y < minY) minY = p.y;
      if (p.y > maxY) maxY = p.y;
    }
    minY = (minY * 0.9).floorToDouble();
    maxY = (maxY * 1.1).ceilToDouble();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          // ✅ 1. ENCABEZADO: NOMBRE DEL PRODUCTO Y "30 DÍAS"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // Muestra el producto seleccionado o un texto por defecto
                      controller.selectedProducto ?? 'Producto', 
                      style: const TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold, 
                        color: Color.fromARGB(255, 0, 0, 0)
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Proyección de Ventas",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "30 días",
                  style: TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.black54
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height: 32),

          // ✅ 2. GRÁFICO (ESTILO AZUL/MORADO)
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false), // Sin cuadrícula para limpieza visual
                titlesData: FlTitlesData(show: false), // Sin títulos en ejes
                borderData: FlBorderData(show: false),
                minX: -4, maxX: 30, minY: minY, maxY: maxY,
                lineBarsData: [
                  // Línea Histórica
                  LineChartBarData(
                    spots: controller.historicalData.map((p) => FlSpot(p.x, p.y)).toList(),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: Colors.grey.shade300,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                  ),
                  // Línea de Predicción
                  LineChartBarData(
                    spots: controller.predictedData.map((p) => FlSpot(p.x, p.y)).toList(),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: targetBlue,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false), // Sin puntos para que se vea limpio como en la imagen
                    belowBarData: BarAreaData(
                      show: true,
                      color: targetBlue.withOpacity(0.15), // Relleno plano suave
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 24),

          // ✅ 3. MÉTRICAS INFERIORES (AHORA CON STOCK ACTUAL)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MetricItem(
                label: "Demanda Est.",
                value: "${controller.predictedDemand}",
                color: const Color(0xFF2563EB), // Azul
                icon: Icons.people_outline,
              ),
              _MetricItem(
                label: "Compra Rec.",
                value: controller.recommendedPurchase.toStringAsFixed(0),
                color: const Color(0xFF16A34A), // Verde
                icon: Icons.shopping_cart_outlined,
              ),
              // Aquí agregamos el Stock Actual
              _MetricItem(
                label: "Stock Actual",
                value: controller.stockController.text, // Leemos del input
                color: const Color.fromARGB(255, 0, 0, 0), // Negro/Azul oscuro
                icon: Icons.inventory_2_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================================================
  // 5. BOTTOM NAVIGATION BAR
  // ==================================================
  Widget _buildBottomNavigationBar(int totalAlerts) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 0, 0),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
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
        if (_selectedIndex == index) return;
        if (index == 0) {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false);
        } else if (index == 1) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const InventoryScreen()));
        } else if (index == 3) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: isSelected ? const Color.fromARGB(255, 0, 0, 0) : Colors.white, size: 24),
                if (index == 3 && totalAlerts > 0)
                  Positioned(
                    right: -6, top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text('$totalAlerts', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label, 
            style: TextStyle(
              color: Colors.white,
              fontSize: 11, 
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
            )
            ),
        ],
      ),
    );
  }

  // ==================================================
  // 6. WIDGETS AUXILIARES
  // ==================================================
  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: onChanged,
          decoration: _inputDecoration(),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
          isExpanded: true,
        ),
      ],
    );
  }

  Widget _buildInput(String label, IconData icon, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          decoration: _inputDecoration().copyWith(prefixIcon: Icon(icon, size: 18)),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color.fromARGB(255, 0, 0, 0), width: 1.5)),
    );
  }

  Widget _buildRadio(String label, int val, PredictionController controller) {
    return Row(
      children: [
        Radio<int>(
          value: val,
          groupValue: controller.selectedOferta,
          onChanged: (v) => controller.setOferta(v!),
          activeColor: const Color.fromARGB(255, 0, 0, 0),
        ),
        Text(label),
        const SizedBox(width: 10),
      ],
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool isHighlight;

  const _MetricItem({required this.label, required this.value, required this.color, required this.icon, this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: isHighlight ? color.withOpacity(0.1) : Colors.grey.shade50, shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }
}