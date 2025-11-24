import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProyeccionFuturaChart extends StatelessWidget {
  final double prediccion;

  const ProyeccionFuturaChart({Key? key, required this.prediccion})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double maxY = prediccion * 1.25;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          "📈 Proyección Futura de Demanda",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 260,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: maxY,

              // ======== TITULOS ========
              titlesData: FlTitlesData(
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 11),
                      );
                    },
                  ),
                ),

                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      switch (value.toInt()) {
                        case 0:
                          return const Text("Hoy");
                        case 1:
                          return const Text("+1 mes");
                        case 2:
                          return const Text("+2 meses");
                        case 3:
                          return const Text("+3 meses");
                        default:
                          return const SizedBox();
                      }
                    },
                  ),
                ),
              ),

              // ======== LÍNEA ========
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  barWidth: 4,
                  color: Colors.blueAccent,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blueAccent.withOpacity(0.25),
                  ),

                  spots: [
                    FlSpot(0, prediccion),
                    FlSpot(1, prediccion * 1.05),
                    FlSpot(2, prediccion * 1.12),
                    FlSpot(3, prediccion * 1.18),
                  ],
                ),
              ],

              // ======== GRILLA ========
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withOpacity(0.2),
                  strokeWidth: 1,
                ),
              ),

              // ======== BORDES ========
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.black26, width: 1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
