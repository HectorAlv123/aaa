import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear la fecha
import 'package:inventario_app/data/models/order.dart';

class IngressGuideDetailsScreen extends StatelessWidget {
  final Order order;

  const IngressGuideDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalle de Guía: ${order.guiaIngreso}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información general de la guía
            Card(
              color: Colors.blue.shade100,
              child: ListTile(
                title: Text("Proveedor: ${order.proveedor}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Número de Guía: ${order.guiaIngreso}"),
                    Text("Patente del Camión: ${order.truckPlate}"),
                    Text("Conductor: ${order.driverName}"),
                    Text("Fecha de Ingreso: ${DateFormat('dd/MM/yyyy HH:mm').format(order.products.first.receptionDateTime)}"),
                    Text("Ubicación: ${order.ubicacionRecepcion}"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Imagen adjunta de la guía (si existe)
            if (order.fotoGuia != null && order.fotoGuia!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Foto adjunta:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Image.file(
                    File(order.fotoGuia!),
                    height: 150,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text("Error al cargar la imagen.");
                    },
                  ),
                ],
              ),
            
            const SizedBox(height: 20),

            // Sección de productos ingresados
            const Text(
              "Productos ingresados",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            Expanded(
              child: order.products.isEmpty
                  ? const Center(child: Text("No hay productos en esta guía."))
                  : ListView.builder(
                      itemCount: order.products.length,
                      itemBuilder: (context, index) {
                        final item = order.products[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(item.description),
                            subtitle: Text(
                              "Cantidad: ${item.quantity}\nCategoría: ${item.category}\nUbicación: ${item.location}",
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
