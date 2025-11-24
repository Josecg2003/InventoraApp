import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SalesHistoryChart extends StatefulWidget {
  final String producto;

  const SalesHistoryChart({Key? key, required this.producto}) : super(key: key);

  @override
  State<SalesHistoryChart> createState() => _SalesHistoryChartState();
}

class _SalesHistoryChartState extends State<SalesHistoryChart> {
  List<double> cantidades = [];
  List<String> fechas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
  try {
    final url = Uri.parse("http://localhost:3000/api/sales-history/${widget.producto}");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);

      setState(() {
        cantidades = data.map<double>((e) {
          final raw = e["total"];

          if (raw == null) return 0.0;
          if (raw is int) return raw.toDouble();
          if (raw is double) return raw;

          return double.tryParse(raw.toString()) ?? 0.0;
        }).toList();

        fechas = data.map<String>((e) {
          final d = DateTime.parse(e["fecha"]);
          return DateFormat("dd MMM").format(d);
        }).toList();

        isLoading = false;
      });
    }
  } catch (e) {
    print("❌ ERROR cargando historial: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (cantidades.isEmpty) {
      return const Text("No hay historial disponible.");
    }

    double maxY = cantidades.reduce((a, b) => a > b ? a : b) + 5;

    return SizedBox(
      height: 260,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= fechas.length) return Container();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      fechas[index],
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.grey.shade200, strokeWidth: 1),
            getDrawingVerticalLine: (value) =>
                FlLine(color: Colors.grey.shade200, strokeWidth: 1),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                cantidades.length,
                (i) => FlSpot(i.toDouble(), cantidades[i]),
              ),
              isCurved: true,
              color: Colors.deepPurple,
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.deepPurple.withOpacity(0.15),
              ),
              dotData: FlDotData(show: true),
            )
          ],
        ),
      ),
    );
  }
}
