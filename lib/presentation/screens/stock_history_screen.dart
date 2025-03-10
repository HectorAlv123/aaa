import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:inventario_app/data/models/inventory_item.dart';
import 'dart:math';
import 'package:intl/intl.dart'; // ✅ Para formatear fechas

class StockHistoryScreen extends StatefulWidget {
  final InventoryItem product;

  const StockHistoryScreen({super.key, required this.product});

  @override
  _StockHistoryScreenState createState() => _StockHistoryScreenState();
}

class _StockHistoryScreenState extends State<StockHistoryScreen> {
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    history = _generateStockHistory();
  }

  /// 🔹 Simulación de historial de stock con fechas reales
  List<Map<String, dynamic>> _generateStockHistory() {
    DateTime today = DateTime.now();
    Random random = Random();
    int stock = widget.product.quantity;

    return List.generate(15, (index) {
      DateTime date = today.subtract(Duration(days: index * 2)); // Cada 2 días
      int change = random.nextInt(10) - 5; // Cambio aleatorio de -5 a +5
      stock = max(0, stock + change); // Asegurar que no sea negativo

      return {
        "date": date,
        "quantity": stock,
      };
    }).reversed.toList(); // Ordenar de más antiguo a más reciente
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Historial de ${widget.product.description}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStockChart(),
            const SizedBox(height: 20),
            Expanded(child: _buildStockHistoryList()),
          ],
        ),
      ),
    );
  }

  /// 🔹 **Gráfico con Fecha en Eje X y Cantidad en Eje Y**
  Widget _buildStockChart() {
    return SizedBox(
      height: 250, // Ajusta la altura del gráfico
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true), // Muestra líneas de referencia
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40, // Espacio para etiquetas
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32, // Espacio para fechas
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < history.length) {
                    return Text(
                      DateFormat("dd/MM").format(history[index]["date"]),
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const Text("");
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: history.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value["quantity"].toDouble());
              }).toList(),
              isCurved: true, // 🔹 Hace la línea más suave
              color: Colors.blue,
              dotData: FlDotData(show: true), // 🔹 Muestra puntos en cada dato
              belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.2)), // 🔹 Sombreado bajo la línea
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 **Lista de Detalles del Stock**
  Widget _buildStockHistoryList() {
    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        final entry = history[index];
        return ListTile(
          leading: Text(DateFormat("dd/MM/yyyy").format(entry["date"])),
          title: Text("Stock: ${entry["quantity"]}"),
        );
      },
    );
  }
}
