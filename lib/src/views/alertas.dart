import 'package:flutter/material.dart';
import 'package:inventora_app/src/views/home.dart';
class AlertasScreen extends StatefulWidget {
  const AlertasScreen({Key? key}) : super(key: key);

  @override
  State<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends State<AlertasScreen> {
  int _selectedIndex = 3; // Alertas seleccionado
  String _filterType = 'Todas'; // Filtro actual: Todas, Stock Bajo, Próximos a Vencer, Sugerencias

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.notifications_outlined, color: Colors.white),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alertas y Notificaciones',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '11 alertas activas',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Resumen de alertas
          Container(
            color: const Color(0xFF1A1A1A),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildAlertSummaryCard(
                    icon: Icons.warning_amber,
                    count: '3',
                    label: 'Stock Bajo',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAlertSummaryCard(
                    icon: Icons.calendar_today,
                    count: '2',
                    label: 'Por Vencer',
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAlertSummaryCard(
                    icon: Icons.trending_up,
                    count: '5',
                    label: 'Sugerencias',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAlertSummaryCard(
                    icon: Icons.show_chart,
                    count: '1',
                    label: 'Variaciones',
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ),

          // Filtros
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Todas', Icons.notifications_outlined),
                  const SizedBox(width: 8),
                  _buildFilterChip('Stock Bajo', Icons.warning_amber_outlined),
                  const SizedBox(width: 8),
                  _buildFilterChip('Próximos a Vencer', Icons.calendar_today_outlined),
                  const SizedBox(width: 8),
                  _buildFilterChip('Sugerencias', Icons.trending_up),
                  const SizedBox(width: 8),
                  _buildFilterChip('Variaciones', Icons.show_chart),
                ],
              ),
            ),
          ),

          // Lista de alertas
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Alertas Críticas
                _buildSectionHeader('Alertas Críticas', Colors.red),
                const SizedBox(height: 12),
                _buildAlertCard(
                  icon: Icons.error_outline,
                  iconColor: Colors.red,
                  iconBgColor: Colors.red.withOpacity(0.1),
                  title: 'Stock Crítico',
                  product: 'Camiseta Deportiva',
                  description: 'Stock actual: 2 unidades • Mínimo: 5 unidades',
                  time: 'Hace 15 minutos',
                  priority: 'Alta',
                  priorityColor: Colors.red,
                  actions: [
                    _buildActionButton('Reordenar', Colors.red, () {}),
                    _buildActionButton('Ver Detalles', Colors.grey[300]!, () {}, textColor: Colors.black),
                  ],
                ),
                const SizedBox(height: 12),
                _buildAlertCard(
                  icon: Icons.calendar_today,
                  iconColor: Colors.red,
                  iconBgColor: Colors.red.withOpacity(0.1),
                  title: 'Vencimiento Próximo',
                  product: 'Yogurt Natural',
                  description: 'Vence el 2025-10-01 • Quedan 18 días',
                  time: 'Hace 1 hora',
                  priority: 'Alta',
                  priorityColor: Colors.red,
                  actions: [
                    _buildActionButton('Ofertar', Colors.red, () {}),
                    _buildActionButton('Descartar', Colors.grey[300]!, () {}, textColor: Colors.black),
                  ],
                ),

                const SizedBox(height: 24),

                // Alertas Importantes
                _buildSectionHeader('Alertas Importantes', Colors.orange),
                const SizedBox(height: 12),
                _buildAlertCard(
                  icon: Icons.warning_amber_outlined,
                  iconColor: Colors.orange,
                  iconBgColor: Colors.orange.withOpacity(0.1),
                  title: 'Stock Bajo',
                  product: 'Auriculares Pro',
                  description: 'Stock actual: 5 unidades • Mínimo: 10 unidades',
                  time: 'Hace 2 horas',
                  priority: 'Media',
                  priorityColor: Colors.orange,
                  actions: [
                    _buildActionButton('Reordenar', Colors.orange, () {}),
                    _buildActionButton('Posponer', Colors.grey[300]!, () {}, textColor: Colors.black),
                  ],
                ),
                const SizedBox(height: 12),
                _buildAlertCard(
                  icon: Icons.warning_amber_outlined,
                  iconColor: Colors.orange,
                  iconBgColor: Colors.orange.withOpacity(0.1),
                  title: 'Stock Bajo',
                  product: 'Mouse Inalámbrico',
                  description: 'Stock actual: 8 unidades • Mínimo: 10 unidades',
                  time: 'Hace 3 horas',
                  priority: 'Media',
                  priorityColor: Colors.orange,
                  actions: [
                    _buildActionButton('Reordenar', Colors.orange, () {}),
                    _buildActionButton('Ignorar', Colors.grey[300]!, () {}, textColor: Colors.black),
                  ],
                ),
                const SizedBox(height: 12),
                _buildAlertCard(
                  icon: Icons.calendar_today_outlined,
                  iconColor: Colors.orange,
                  iconBgColor: Colors.orange.withOpacity(0.1),
                  title: 'Vencimiento Cercano',
                  product: 'Pan Integral',
                  description: 'Vence el 2025-10-11 • Quedan 28 días',
                  time: 'Hace 4 horas',
                  priority: 'Media',
                  priorityColor: Colors.orange,
                  actions: [
                    _buildActionButton('Planificar Oferta', Colors.orange, () {}),
                    _buildActionButton('Ver Más', Colors.grey[300]!, () {}, textColor: Colors.black),
                  ],
                ),

                const SizedBox(height: 24),

                // Sugerencias
                _buildSectionHeader('Sugerencias Automáticas', Colors.blue),
                const SizedBox(height: 12),
                _buildAlertCard(
                  icon: Icons.lightbulb_outline,
                  iconColor: Colors.blue,
                  iconBgColor: Colors.blue.withOpacity(0.1),
                  title: 'Sugerencia de Pedido',
                  product: 'Laptop HP ProBook',
                  description: 'Basado en tendencias de venta • Cantidad sugerida: 15 unidades',
                  time: 'Hoy',
                  priority: 'Baja',
                  priorityColor: Colors.blue,
                  actions: [
                    _buildActionButton('Revisar', Colors.blue, () {}),
                    _buildActionButton('Omitir', Colors.grey[300]!, () {}, textColor: Colors.black),
                  ],
                ),
                const SizedBox(height: 12),
                _buildAlertCard(
                  icon: Icons.trending_up,
                  iconColor: Colors.blue,
                  iconBgColor: Colors.blue.withOpacity(0.1),
                  title: 'Incremento de Demanda',
                  product: 'Teclado Mecánico RGB',
                  description: 'Ventas aumentaron 45% esta semana',
                  time: 'Hoy',
                  priority: 'Baja',
                  priorityColor: Colors.blue,
                  actions: [
                    _buildActionButton('Ver Análisis', Colors.blue, () {}),
                  ],
                ),

                const SizedBox(height: 24),

                // Variaciones
                _buildSectionHeader('Variaciones de Desempeño', Colors.purple),
                const SizedBox(height: 12),
                _buildAlertCard(
                  icon: Icons.show_chart,
                  iconColor: Colors.purple,
                  iconBgColor: Colors.purple.withOpacity(0.1),
                  title: 'Cambio Significativo Detectado',
                  product: 'Monitor 24" Full HD',
                  description: 'Rotación de inventario disminuyó 30% en el último mes',
                  time: 'Hace 1 día',
                  priority: 'Baja',
                  priorityColor: Colors.purple,
                  actions: [
                    _buildActionButton('Ver Detalles', Colors.purple, () {}),
                    _buildActionButton('Descartar', Colors.grey[300]!, () {}, textColor: Colors.black),
                  ],
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (index != _selectedIndex) {
              // Aquí puedes agregar la navegación a otras pantallas
              if (index == 0) {
                // Ir a Inicio
                Navigator.pop(context);
              } else if (index == 1) {
                // Ir a Inventario
                // Navigator.push(context, MaterialPageRoute(builder: (context) => const InventoryScreen()));
              } else if (index == 2) {
                // Ir a Predicción
                // Navigator.push(context, MaterialPageRoute(builder: (context) => const PredictionScreen()));
              }
              setState(() {
                _selectedIndex = index;
              });
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
          backgroundColor: const Color(0xFF1A1A1A),
          selectedLabelStyle: const TextStyle(fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              label: 'Inventario',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              label: 'Predicción',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Alertas',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertSummaryCard({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final isSelected = _filterType == label;
    return InkWell(
      onTap: () {
        setState(() {
          _filterType = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A1A1A) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.black87,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAlertCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String product,
    required String description,
    required String time,
    required String priority,
    required Color priorityColor,
    required List<Widget> actions,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: priorityColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            priority,
                            style: TextStyle(
                              color: priorityColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: actions,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onPressed, {Color? textColor}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor ?? Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filtrar Alertas'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Todas las Alertas'),
                onTap: () {
                  setState(() {
                    _filterType = 'Todas';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.warning_amber_outlined, color: Colors.orange),
                title: const Text('Stock Bajo'),
                onTap: () {
                  setState(() {
                    _filterType = 'Stock Bajo';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today_outlined, color: Colors.red),
                title: const Text('Próximos a Vencer'),
                onTap: () {
                  setState(() {
                    _filterType = 'Próximos a Vencer';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}


