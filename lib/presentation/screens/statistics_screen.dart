import 'package:flutter/material.dart';
import 'package:inventario_app/presentation/screens/product_variation_screen.dart';
import 'package:inventario_app/presentation/screens/movements_history_screen.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Estadísticas")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductVariationScreen()),
                );
              },
              child: const Text("Variación de Productos"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MovementsHistoryScreen()),
                );
              },
              child: const Text("Registro de Movimientos"),
            ),
          ],
        ),
      ),
    );
  }
}
