import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:inventario_app/domain/managers/inventory_manager.dart';
import 'package:inventario_app/data/models/inventory_item.dart';

class ProductVariationScreen extends StatefulWidget {
  const ProductVariationScreen({super.key});

  @override
  _ProductVariationScreenState createState() => _ProductVariationScreenState();
}

class _ProductVariationScreenState extends State<ProductVariationScreen> {
  List<InventoryItem> selectedProducts = [];

  @override
  Widget build(BuildContext context) {
    List<InventoryItem> allProducts = InventoryManager.instance.inventoryItems;

    return Scaffold(
      appBar: AppBar(title: const Text("📊 Variación de Productos")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (allProducts.isEmpty)
              const Center(child: Text("No hay productos disponibles."))
            else
              DropdownButtonFormField<InventoryItem>(
                decoration: const InputDecoration(labelText: "Seleccionar Producto"),
                items: allProducts.map((product) {
                  return DropdownMenuItem(
                    value: product,
                    child: Text(product.description),
                  );
                }).toList(),
                onChanged: (InventoryItem? selectedProduct) {
                  if (selectedProduct != null && !selectedProducts.contains(selectedProduct)) {
                    setState(() {
                      selectedProducts.add(selectedProduct);
                    });
                  }
                },
              ),
            const SizedBox(height: 20),
            Expanded(
              child: selectedProducts.isEmpty
                  ? const Center(child: Text("Selecciona al menos un producto para ver su evolución."))
                  : LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString(), style: const TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            "${value.toInt()}",
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: selectedProducts.map((product) {
                    List<Map<String, dynamic>> history =
                    InventoryManager.instance.getStockHistory(product.id);
                    
                    if (history.isEmpty) return LineChartBarData(spots: []);

                    List<FlSpot> spots = history
                        .asMap()
                        .entries
                        .map((entry) => FlSpot(entry.key.toDouble(), entry.value["quantity"].toDouble()))
                        .toList();

                    return LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 4,
                      belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
