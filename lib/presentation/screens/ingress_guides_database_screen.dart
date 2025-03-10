import 'package:flutter/material.dart';
import 'package:inventario_app/domain/managers/order_manager.dart';
import 'ingress_guide_details_screen.dart';

class IngressGuidesDatabaseScreen extends StatelessWidget {
  const IngressGuidesDatabaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = OrderManager.instance.orders;

    return Scaffold(
      appBar: AppBar(title: const Text("Guías de Ingreso Guardadas")),
      body: orders.isEmpty
          ? const Center(child: Text("No hay guías registradas."))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  child: ListTile(
                    title: Text("Guía #${order.guiaIngreso} - ${order.proveedor}"),
                    subtitle: Text("Placa: ${order.truckPlate} | Conductor: ${order.driverName}"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IngressGuideDetailsScreen(order: order),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
