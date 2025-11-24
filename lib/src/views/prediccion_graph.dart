import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PrediccionGraph extends StatelessWidget {
  final double stockActual;
  final double demanda;
  
  const PrediccionGraph({
    Key? key,
    required this.stockActual,
    required this.demanda,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // Proyecciones simples (puedes ajustarlas con tu modelo real)
    double proy7dias = demanda * 1.10;
    double proy30dias = demanda * 1.25;

    List<double> puntos = [
      stockActual,
      demanda,
      proy7dias,
      proy30dias,
    ];

    return Container(
      height: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: (puntos.reduce((a, b) => a > b ? a : b)) + 10,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0:
                      return const Text("Stock");
                    case 1:
                      return const Text("Hoy");
                    case 2:
                      return const Text("7 días");
                    case 3:
                      return const Text("30 días");
                  }
                  return const Text("");
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                puntos.length,
                (i) => FlSpot(i.toDouble(), puntos[i]),
              ),
              isCurved: true,
              color: Colors.blueAccent,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blueAccent.withOpacity(0.2),
              ),
            )
          ],
        ),
      ),
    );
  }
}
